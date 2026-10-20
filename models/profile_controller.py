import json
from typing import Any, Dict, List, Optional, Tuple

from PySide6.QtCore import QObject, Property, QSettings, Signal, Slot

from db.database import DatabaseManager


class ProfileController(QObject):
    userProfileChanged = Signal()
    companiesChanged = Signal()
    onboardingCompletedChanged = Signal()

    def __init__(self, db: DatabaseManager, parent: Optional[QObject] = None):
        super().__init__(parent)
        self.db = db
        self._settings = QSettings()
        self._user_profile: Dict[str, Any] = {}
        self._companies: List[Dict[str, Any]] = []

    @Slot()
    def refresh_user_profile(self):
        profiles = self.db.get_user_profiles()
        self._user_profile = profiles[0] if profiles else {}
        if self._user_profile:
            profile = self._user_profile
            if not profile.get("first_name") and not profile.get("last_name"):
                name_parts = profile.get("name", "").split(maxsplit=1)
                profile["first_name"] = name_parts[0] if name_parts else ""
                profile["last_name"] = name_parts[1] if len(name_parts) > 1 else ""
            employment_history = profile.get("employment_history", "[]")
            try:
                entries = json.loads(employment_history)
            except (TypeError, json.JSONDecodeError):
                entries = []
            if not isinstance(entries, list) or not entries:
                old_jobs = [
                    value.strip()
                    for value in (profile.get("jobs") or "").split(",")
                ]
                old_companies = [
                    value.strip()
                    for value in (profile.get("companies") or "").split(",")
                ]
                entries = [
                    {"job": job, "company": company}
                    for job, company in zip(old_jobs, old_companies)
                    if job or company
                ]
            profile["employment_history"] = [
                {
                    "job": str(entry.get("job", "")).strip(),
                    "company": str(entry.get("company", "")).strip(),
                }
                for entry in entries
                if isinstance(entry, dict)
            ]
        self.userProfileChanged.emit()

    @Slot()
    def refresh_companies(self):
        companies = self.db.get_companies()
        known_names = {company["name"].strip().casefold() for company in companies}
        profile_companies = []
        profile_names = set()
        for entry in self._user_profile.get("employment_history", []):
            name = entry.get("company", "").strip()
            if name and name.casefold() not in profile_names:
                profile_companies.append(name)
                profile_names.add(name.casefold())
        for name in profile_companies:
            if name.casefold() not in known_names:
                self.db.add_company(name)
                known_names.add(name.casefold())
        self._companies = self.db.get_companies()
        self.companiesChanged.emit()

    @Property(dict, notify=userProfileChanged)
    def userProfile(self):
        return self._user_profile

    @Property(list, notify=companiesChanged)
    def companies(self):
        return self._companies

    @Property(list, notify=companiesChanged)
    def projectCompanyNames(self) -> List[str]:
        names = []
        seen = set()
        for entry in self._user_profile.get("employment_history", []):
            name = entry.get("company", "").strip()
            key = name.casefold()
            if name and key not in seen:
                names.append(name)
                seen.add(key)
        return ["Personal", *names]

    @Slot(str, result=int)
    def companyIdForName(self, name: str) -> int:
        normalized_name = name.strip().casefold()
        for company in self._companies:
            if company["name"].strip().casefold() == normalized_name:
                return int(company["id"])
        return -1

    @Slot(int, result=str)
    def companyNameForId(self, company_id: int) -> str:
        for company in self._companies:
            if int(company["id"]) == company_id:
                return str(company["name"])
        return ""

    @Property(bool, notify=onboardingCompletedChanged)
    def onboardingCompleted(self):
        return str(self._settings.value("onboarding/completed", "false")).lower() == "true"

    @Slot(str, str, str, str, str, result=int)
    def add_user_profile(
        self, name: str, gender: str, email: str, jobs: str, companies: str
    ) -> int:
        first_name, last_name, employment = self._parse_legacy_profile(
            name, jobs, companies
        )
        profile_id = self.db.add_user_profile(
            name,
            gender,
            email,
            jobs,
            companies,
            first_name,
            last_name,
            "",
            json.dumps(employment),
        )
        self.refresh_user_profile()
        self.refresh_companies()
        return profile_id

    @Slot(int, str, str, str, str, str, result=bool)
    def update_user_profile(
        self,
        profile_id: int,
        name: str,
        gender: str,
        email: str,
        jobs: str,
        companies: str,
    ) -> bool:
        first_name, last_name, employment = self._parse_legacy_profile(
            name, jobs, companies
        )
        existing = self.db.get_user_profile_by_id(profile_id)
        result = self.db.update_user_profile(
            profile_id,
            name,
            gender,
            email,
            jobs,
            companies,
            first_name,
            last_name,
            existing.get("nickname", "") if existing else "",
            json.dumps(employment),
        )
        self.refresh_user_profile()
        self.refresh_companies()
        return result

    @Slot(str, str, str, str, str, str, result=int)
    def create_profile(
        self,
        first_name: str,
        last_name: str,
        nickname: str,
        gender: str,
        email: str,
        employment_json: str,
    ) -> int:
        employment = self._parse_employment_history(employment_json)
        profile_id = self._save_profile(
            None, first_name, last_name, nickname, gender, email, employment
        )
        self.refresh_user_profile()
        self.refresh_companies()
        return profile_id

    @Slot(int, str, str, str, str, str, str, result=bool)
    def save_profile(
        self,
        profile_id: int,
        first_name: str,
        last_name: str,
        nickname: str,
        gender: str,
        email: str,
        employment_json: str,
    ) -> bool:
        employment = self._parse_employment_history(employment_json)
        result = self._save_profile(
            profile_id, first_name, last_name, nickname, gender, email, employment
        )
        self.refresh_user_profile()
        self.refresh_companies()
        return bool(result)

    @staticmethod
    def _parse_legacy_profile(
        name: str, jobs: str, companies: str
    ) -> Tuple[str, str, List[Dict[str, str]]]:
        name_parts = name.split(maxsplit=1)
        first_name = name_parts[0] if name_parts else ""
        last_name = name_parts[1] if len(name_parts) > 1 else ""
        job_values = [value.strip() for value in jobs.split(",")]
        company_values = [value.strip() for value in companies.split(",")]
        employment = [
            {"job": job, "company": company}
            for job, company in zip(job_values, company_values)
            if job and company
        ]
        return first_name, last_name, employment

    @staticmethod
    def _parse_employment_history(employment_json: str) -> List[Dict[str, str]]:
        entries = json.loads(employment_json)
        if not isinstance(entries, list):
            raise ValueError("Employment history must be a list")
        normalized = []
        for entry in entries:
            if not isinstance(entry, dict):
                raise ValueError("Each employment entry must contain a job and company")
            job = str(entry.get("job", "")).strip()
            company = str(entry.get("company", "")).strip()
            if job and company:
                normalized.append({"job": job, "company": company})
        return normalized

    def _save_profile(
        self,
        profile_id: Optional[int],
        first_name: str,
        last_name: str,
        nickname: str,
        gender: str,
        email: str,
        employment: List[Dict[str, str]],
    ) -> int:
        full_name = " ".join(part for part in (first_name.strip(), last_name.strip()) if part)
        jobs = ", ".join(entry["job"] for entry in employment)
        companies = ", ".join(entry["company"] for entry in employment)
        employment_json = json.dumps(employment)
        if profile_id is None:
            return self.db.add_user_profile(
                full_name,
                gender,
                email,
                jobs,
                companies,
                first_name.strip(),
                last_name.strip(),
                nickname.strip(),
                employment_json,
            )
        return int(self.db.update_user_profile(
            profile_id,
            full_name,
            gender,
            email,
            jobs,
            companies,
            first_name.strip(),
            last_name.strip(),
            nickname.strip(),
            employment_json,
        ))

    @Slot(bool)
    def setOnboardingCompleted(self, completed: bool):
        self._settings.setValue(
            "onboarding/completed", "true" if completed else "false"
        )
        self._settings.sync()
        self.onboardingCompletedChanged.emit()

    @Slot(str, str, result=int)
    def add_company(self, name: str, description: str = "") -> int:
        company_id = self.db.add_company(name, description)
        self.refresh_companies()
        return company_id
