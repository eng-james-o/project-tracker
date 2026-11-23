import tempfile
import unittest
from unittest.mock import patch
from pathlib import Path

from PySide6.QtCore import QCoreApplication, QSettings

from models.account_controller import AccountController, KEY_SETTING


class MemoryCredentialStore:
    token = None

    def get_password(self, service, username):
        return self.token

    def set_password(self, service, username, token):
        self.token = token

    def delete_password(self, service, username):
        self.token = None


def session(refresh_token):
    return {"user": {"email": "test@example.com"}, "access_token": "access", "refresh_token": refresh_token}


class AccountControllerTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QCoreApplication.instance() or QCoreApplication([])
        cls.app.setOrganizationName("AccountControllerTest")
        cls.app.setApplicationName("ProjectTrackerTest")

    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.settings = QSettings(directory.name + "/settings.ini", QSettings.Format.IniFormat)
        self.store = MemoryCredentialStore()
        for path, replacement in (
            ("models.account_controller.QSettings", self.settings),
            ("models.account_controller.platform_keyring", self.store),
        ):
            patcher = patch(path, return_value=replacement)
            patched = patcher.start()
            if path.endswith(".QSettings"):
                patched.Status = QSettings.Status
            self.addCleanup(patcher.stop)

    def test_sign_in_and_rotate_token_on_restart(self):
        controller = AccountController()
        with patch.object(controller, "_request") as request:
            controller.signIn(" test@example.com ", "password", "sb_publishable_example")
            self.assertTrue(controller.busy)
            path, payload, key, callback = request.call_args.args
            self.assertEqual(path, "token?grant_type=password")
            self.assertEqual(payload["email"], "test@example.com")
            callback(session("first"), 200, "")
        self.assertTrue(controller.hasSession)
        self.assertEqual(self.settings.value(KEY_SETTING), "sb_publishable_example")
        self.assertEqual(self.store.token, "first")
        self.assertNotIn("first", Path(self.settings.fileName()).read_text(encoding="utf-8"))

        restarted = AccountController()
        with patch.object(restarted, "_request") as request:
            restarted.restore()
            path, payload, _, callback = request.call_args.args
            self.assertEqual(path, "token?grant_type=refresh_token")
            self.assertEqual(payload, {"refresh_token": "first"})
            callback(session("rotated"), 200, "")
        self.assertEqual(restarted.email, "test@example.com")
        self.assertEqual(self.store.token, "rotated")

    def test_offline_restore_retains_token_and_sign_out_clears_it(self):
        self.settings.setValue(KEY_SETTING, "sb_publishable_example")
        self.store.token = "saved"
        controller = AccountController()
        with patch.object(controller, "_request") as request:
            controller.restore()
            request.call_args.args[3]({}, 0, "")
            self.assertTrue(controller.hasSession)
            self.assertEqual(self.store.token, "saved")
            controller.signOut()
            self.assertIsNone(self.store.token)
            request.call_args.args[3](session("fresh"), 200, "")
            self.assertEqual(request.call_args.args[0], "logout?scope=local")
            self.assertEqual(request.call_args.kwargs["bearer"], "access")
            request.call_args.args[3]({}, 204, "")
        self.assertFalse(controller.hasSession)
        self.assertEqual(controller.message, "")

    def test_expired_session_is_cleared_and_secret_key_is_rejected(self):
        self.settings.setValue(KEY_SETTING, "sb_publishable_example")
        self.store.token = "expired"
        controller = AccountController()
        with patch.object(controller, "_request") as request:
            controller.restore()
            request.call_args.args[3]({}, 400, "refresh_token_not_found")
            self.assertFalse(controller.hasSession)
            self.assertIsNone(self.store.token)
            request.reset_mock()
            controller.signIn("test@example.com", "password", "sb_secret_example")
            request.assert_not_called()
