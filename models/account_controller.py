"""Optional Project Tracker account for the desktop client."""

import json
import re

import keyring
from PySide6.QtCore import Property, QObject, QSettings, QUrl, Signal, Slot
from PySide6.QtNetwork import QNetworkAccessManager, QNetworkRequest

PROJECT_URL = "https://mjqyduegwtllzxgnmcit.supabase.co"
PUBLISHABLE_KEY = re.compile(r"sb_publishable_[A-Za-z0-9_-]+")
KEY_SETTING = "supabase/publishable_key"
KEYRING_SERVICE = "ProjectTrackerDesktop:mjqyduegwtllzxgnmcit"
KEYRING_ENTRY = "refresh-token"
EXPIRED_CODES = {
    "refresh_token_not_found", "refresh_token_already_used", "session_not_found",
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

    def __init__(self, parent=None):
        super().__init__(parent)
        self._network = QNetworkAccessManager(self)
        self._settings = QSettings()
        self._key = self._settings.value(KEY_SETTING, "", type=str)
        self._email = ""
        self._has_session = False
        self._busy = False
        self._message = ""

    @Property(str, notify=changed)
    def publishableKey(self):
        return self._key

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

    @Slot()
    def restore(self):
        if self._busy or self._email or not self._key:
            return
        try:
            refresh_token = platform_keyring().get_password(KEYRING_SERVICE, KEYRING_ENTRY)
        except Exception:
            self._finish("Secure session storage is unavailable. Check your system credential store.")
            return
        if not refresh_token:
            return
        self._has_session = True
        if not PUBLISHABLE_KEY.fullmatch(self._key):
            self._finish("The saved connection key is invalid. Sign out and enter the project’s publishable key.")
            return
        self._begin()
        self._token("refresh_token", {"refresh_token": refresh_token}, self._key, self._restore_finished)

    @Slot(str, str, str)
    def signIn(self, email, password, publishable_key):
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
            refresh_token = backend.get_password(KEYRING_SERVICE, KEYRING_ENTRY)
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

    def _restore_finished(self, session, status, code):
        if session:
            self._save_session(session, self._key)
        elif code in EXPIRED_CODES:
            try:
                platform_keyring().delete_password(KEYRING_SERVICE, KEYRING_ENTRY)
            except Exception:
                self._finish("Unable to clear the expired session from your system credential store.")
                return
            self._has_session = False
            self._finish("Session expired. Sign in again.")
        else:
            self._finish("Unable to restore the session. Check your connection and retry.")

    def _save_session(self, session, key):
        try:
            self._settings.setValue(KEY_SETTING, key)
            self._settings.sync()
            if self._settings.status() != QSettings.Status.NoError:
                raise OSError("Unable to save account connection settings")
            platform_keyring().set_password(KEYRING_SERVICE, KEYRING_ENTRY, session["refresh_token"])
        except Exception:
            self._finish("Secure session storage is unavailable. Check your system credential store.")
            return
        self._key = key
        self._email = session["user"]["email"]
        self._has_session = True
        self._finish()

    def _sign_out_finished(self, status, code, refreshed=True):
        confirmed = code in EXPIRED_CODES or (refreshed and 200 <= status < 300)
        self._finish("" if confirmed else "Signed out on this device. Server sign-out could not be confirmed.")

    def _token(self, grant, payload, key, callback):
        def finished(data, status, code):
            user = data.get("user")
            fields = (user.get("email") if isinstance(user, dict) else None,
                      data.get("access_token"), data.get("refresh_token"))
            valid = 200 <= status < 300 and all(isinstance(value, str) and value for value in fields)
            callback(data if valid else None, status, code)

        self._request(f"token?grant_type={grant}", payload, key, finished)

    def _request(self, path, payload, key, callback, bearer=None):
        request = QNetworkRequest(QUrl(f"{PROJECT_URL}/auth/v1/{path}"))
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
            if not isinstance(data, dict):
                data = {}
            reply.deleteLater()
            code = data.get("error_code")
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
