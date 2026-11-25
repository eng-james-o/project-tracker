"""Supabase authentication and workspace sync for the desktop client."""

import json
import re

import keyring
from PySide6.QtCore import Property, QObject, QSettings, QUrl, Signal, Slot
from PySide6.QtNetwork import QNetworkAccessManager, QNetworkRequest

from models.workspace_sync import WorkspaceAccountMismatch

PROJECT_URL = "https://mjqyduegwtllzxgnmcit.supabase.co"
DEFAULT_PUBLISHABLE_KEY = "sb_publishable_9ftGmjXokm_PgJKYk6xCUQ_0kWFoZy-"
PUBLISHABLE_KEY = re.compile(r"sb_publishable_[A-Za-z0-9_-]+")
SIGN_UP_CONFIRMATION = "If a new account was created, check your email to confirm it, then sign in."
KEY_SETTING = "supabase/publishable_key"
KEYRING_SERVICE = "ProjectTrackerDesktop:mjqyduegwtllzxgnmcit"
KEYRING_ENTRY = "refresh-token"
EXPIRED_CODES = {
    "bad_jwt", "invalid_grant", "refresh_token_not_found", "refresh_token_already_used", "session_not_found",
    "session_expired", "user_not_found", "user_banned",
}
PLATFORM_KEYRINGS = {
    "keyring.backends.Windows", "keyring.backends.macOS",
    "keyring.backends.SecretService", "keyring.backends.kwallet", "keyring.backends.libsecret",
}


def platform_keyring():
    backend = keyring.get_keyring()
    candidates = backend.backends if type(backend).__module__ == "keyring.backends.chainer" else [backend]
    for candidate in candidates:
        if type(candidate).__module__ in PLATFORM_KEYRINGS:
            return candidate
    raise RuntimeError("No supported operating-system credential store")


class AccountController(QObject):
    changed = Signal()

    def __init__(self, parent=None, workspace=None, on_refresh=None):
        super().__init__(parent)
        self._network = QNetworkAccessManager(self)
        self._workspace = workspace
        self._on_refresh = on_refresh
        self._settings = QSettings()
        self._key = self._settings.value(KEY_SETTING, DEFAULT_PUBLISHABLE_KEY, type=str)
        self._email = ""
        self._has_session = False
        self._busy = False
        self._message = ""

    @Property(str, notify=changed)
    def email(self):
        return self._email

    @Property(bool, notify=changed)
    def hasSession(self):
        return self._has_session

    @Property(bool, notify=changed)
    def busy(self):
        return self._busy

    @Property(str, notify=changed)
    def message(self):
        return self._message

    def _saved_account(self):
        raw = platform_keyring().get_password(KEYRING_SERVICE, KEYRING_ENTRY)
        if not raw:
            return {}
        if not raw.startswith("{"):
            return {"refresh_token": raw}
        credentials = json.loads(raw)
        if not all(isinstance(credentials.get(field), str) and credentials[field]
                   for field in ("refresh_token", "email", "user_id")):
            raise ValueError("Invalid saved session")
        return credentials

    @Slot()
    def restore(self):
        if self._busy:
            return
        try:
            saved = self._saved_account()
        except Exception:
            self._finish("Secure session storage is unavailable. Check your system credential store.")
            return
        if not saved:
            return
        self._has_session = True
        if not PUBLISHABLE_KEY.fullmatch(self._key):
            self._key = DEFAULT_PUBLISHABLE_KEY
        self._begin()
        self._token("refresh_token", {"refresh_token": saved["refresh_token"]}, self._key,
                    lambda session, status, code: self._restore_finished(session, status, code, saved))

    @Slot()
    def clearMessage(self):
        if not self._busy:
            self._finish()

    @Slot(str, str)
    def signUp(self, email, password):
        if self._busy or self._has_session:
            return
        email = email.strip()
        if not email or not password:
            self._finish("Enter your account email and password.")
            return
        self._begin()

        def completed(_, status, code):
            if 200 <= status < 300 or code in {"user_already_exists", "email_exists"}:
                message = SIGN_UP_CONFIRMATION
            elif code == "signup_disabled":
                message = "New account registration is disabled."
            elif code == "weak_password":
                message = "Choose a stronger password."
            elif code == "email_address_invalid":
                message = "Enter a valid email address."
            elif code == "validation_failed":
                message = "Check your email address and password."
            elif code == "email_address_not_authorized":
                message = "This project’s email service cannot send to this address."
            elif status == 429:
                message = "Too many attempts. Wait a moment and try again."
            else:
                message = "Unable to create the account. Check your connection and try again."
            self._finish(message)

        self._request("signup", {"email": email, "password": password}, DEFAULT_PUBLISHABLE_KEY, completed)

    @Slot(str, str)
    def signIn(self, email, password, publishable_key=DEFAULT_PUBLISHABLE_KEY):
        if self._busy or self._has_session:
            return
        email, publishable_key = email.strip(), publishable_key.strip()
        if not email or not password:
            self._finish("Enter your account email and password.")
            return
        if not PUBLISHABLE_KEY.fullmatch(publishable_key):
            self._finish("Enter the project’s sb_publishable_ key.")
            return
        try:
            platform_keyring()
        except Exception:
            self._finish("Enable your system credential store before signing in.")
            return

        self._begin()

        def completed(session, status, code):
            if session:
                self._save_session(session, publishable_key)
                return
            if code == "email_not_confirmed":
                self._finish("Confirm your email before signing in.")
            elif code == "invalid_credentials":
                self._finish("The email or password is incorrect.")
            elif status == 429:
                self._finish("Too many attempts. Wait a moment and try again.")
            elif status in (401, 403):
                self._finish("Check the project’s publishable key and Email provider.")
            else:
                self._finish("Unable to sign in. Check your connection and try again.")

        self._token("password", {"email": email, "password": password}, publishable_key, completed)

    @Slot()
    def signOut(self):
        if self._busy or not self._has_session:
            return
        try:
            backend = platform_keyring()
            refresh_token = self._saved_account().get("refresh_token")
            if refresh_token:
                backend.delete_password(KEYRING_SERVICE, KEYRING_ENTRY)
        except Exception:
            self._finish("Unable to clear the session from your system credential store.")
            return
        self._email = ""
        self._has_session = False
        if not refresh_token:
            self._finish()
            return
        if not PUBLISHABLE_KEY.fullmatch(self._key):
            self._finish("Signed out on this device. Server sign-out could not be confirmed.")
            return
        self._begin()

        def refreshed(session, status, code):
            if session:
                self._request("logout?scope=local", None, self._key,
                              lambda _, status, code: self._sign_out_finished(status, code),
                              bearer=session["access_token"])
            else:
                self._sign_out_finished(status, code, refreshed=False)

        self._token("refresh_token", {"refresh_token": refresh_token}, self._key, refreshed)

    def _restore_finished(self, session, status, code, saved):
        if session:
            if saved.get("user_id", session["user"]["id"]) != session["user"]["id"]:
                self._email = ""
                self._finish("The saved session belongs to a different account. Sign out and try again.")
            else:
                self._save_session(session, self._key)
        elif code in EXPIRED_CODES:
            try:
                platform_keyring().delete_password(KEYRING_SERVICE, KEYRING_ENTRY)
            except Exception:
                self._finish("Unable to clear the expired session from your system credential store.")
                return
            self._email = ""
            self._has_session = False
            self._finish("Session expired. Sign in again.")
        elif (status == 0 or status == 429 or status >= 500) and saved.get("user_id"):
            try:
                self._bind_workspace(saved["user_id"])
            except WorkspaceAccountMismatch:
                self._email = ""
                self._finish("Sign in with the account that owns this device’s local workspace.")
            except Exception:
                self._email = ""
                self._finish("The saved workspace could not be opened.")
            else:
                self._email = saved["email"]
                self._finish("Offline. Local edits are saved on this device.")
        else:
            self._finish("Unable to restore the session. Check your connection and retry.")

    def _bind_workspace(self, owner):
        if self._workspace is not None:
            self._workspace.bind_account(owner)

    def _save_session(self, session, key):
        user = session["user"]
        try:
            self._bind_workspace(user["id"])
        except WorkspaceAccountMismatch:
            self._email = ""
            self._finish("Sign in with the account that owns this device’s local workspace.")
            return
        except Exception:
            self._email = ""
            self._finish("The local workspace could not be opened.")
            return
        credentials = json.dumps({
            "refresh_token": session["refresh_token"], "email": user["email"], "user_id": user["id"],
        })
        try:
            self._settings.setValue(KEY_SETTING, key)
            self._settings.sync()
            if self._settings.status() != QSettings.Status.NoError:
                raise OSError("Unable to save account connection settings")
            platform_keyring().set_password(KEYRING_SERVICE, KEYRING_ENTRY, credentials)
        except Exception:
            self._finish("Secure session storage is unavailable. Check your system credential store.")
            return
        self._key = key
        self._email = session["user"]["email"]
        self._has_session = True
        if self._workspace is None:
            self._finish()
        else:
            self.changed.emit()
            self._sync_workspace(session)

    def _sync_workspace(self, session):
        owner = session["user"].get("id")
        if not owner:
            self._finish("Signed in. The cloud account could not be identified for sync.")
            return

        def snapshot(data, status, code):
            if status != 200 or not isinstance(data, dict):
                self._finish("Signed in. Cloud refresh failed. Try Sync now.")
                return
            try:
                writes, pulled, conflicts = self._workspace.prepare(owner, data)
            except WorkspaceAccountMismatch:
                self._finish("This local workspace is linked to another account. Its records were kept on this device.")
                return
            except Exception:
                self._finish("Signed in. The cloud snapshot could not be applied. Try Sync now.")
                return
            if self._on_refresh is not None:
                self._on_refresh()

            def push(offset):
                batch = writes[offset: offset + 100]
                if not batch:
                    suffix = f" {conflicts} conflict(s) kept on this device." if conflicts else ""
                    self._finish(f"Sync complete. {pulled} downloaded, {len(writes)} uploaded." + suffix)
                    return

                def acknowledge(receipts, status, code):
                    if status != 200 or not isinstance(receipts, list):
                        message = ("Cloud records changed during sync. Try Sync now."
                                   if code == "40001" else "Cloud upload failed. Local changes are saved for retry.")
                        self._finish(message)
                        return
                    try:
                        self._workspace.acknowledge(batch, receipts)
                    except Exception:
                        self._finish("Cloud response could not be saved. Try Sync now.")
                        return
                    push(offset + len(batch))

                self._request("rpc/tracker_sync_write", {"changes": batch}, self._key,
                              acknowledge, bearer=session["access_token"], api="rest/v1")
            push(0)

        self._request("rpc/tracker_sync_snapshot", {}, self._key, snapshot,
                      bearer=session["access_token"], api="rest/v1")

    def _sign_out_finished(self, status, code, refreshed=True):
        confirmed = code in EXPIRED_CODES or (refreshed and 200 <= status < 300)
        self._finish("" if confirmed else "Signed out on this device. Server sign-out could not be confirmed.")

    def _token(self, grant, payload, key, callback):
        def finished(data, status, code):
            if not isinstance(data, dict):
                data = {}
            user = data.get("user")
            fields = (user.get("email") if isinstance(user, dict) else None,
                      user.get("id") if isinstance(user, dict) else None,
                      data.get("access_token"), data.get("refresh_token"))
            valid = 200 <= status < 300 and all(isinstance(value, str) and value for value in fields)
            callback(data if valid else None, status, code)

        self._request(f"token?grant_type={grant}", payload, key, finished)

    def _request(self, path, payload, key, callback, bearer=None, api="auth/v1"):
        request = QNetworkRequest(QUrl(f"{PROJECT_URL}/{api}/{path}"))
        request.setTransferTimeout(10_000)
        request.setAttribute(QNetworkRequest.Attribute.RedirectPolicyAttribute,
                             QNetworkRequest.RedirectPolicy.ManualRedirectPolicy)
        request.setRawHeader(b"apikey", key.encode("ascii"))
        request.setRawHeader(b"Accept", b"application/json")
        request.setHeader(QNetworkRequest.KnownHeaders.ContentTypeHeader, "application/json")
        if bearer:
            request.setRawHeader(b"Authorization", f"Bearer {bearer}".encode("ascii"))
        body = json.dumps(payload).encode("utf-8") if payload is not None else b""
        reply = self._network.post(request, body)

        def finished():
            status = reply.attribute(QNetworkRequest.Attribute.HttpStatusCodeAttribute) or 0
            try:
                data = json.loads(bytes(reply.readAll()))
            except (UnicodeError, ValueError):
                data = {}
            reply.deleteLater()
            code = (data.get("error_code") or data.get("code")) if isinstance(data, dict) else None
            callback(data, status, code if isinstance(code, str) else "")

        reply.finished.connect(finished)

    def _begin(self):
        self._busy = True
        self._message = ""
        self.changed.emit()

    def _finish(self, message=""):
        self._busy = False
        self._message = message
        self.changed.emit()
