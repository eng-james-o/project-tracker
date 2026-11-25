# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Supabase email sign-in and sign-up on the desktop startup screen.
- Offline access for the last verified account using the operating system credential store.

## [1.1.0] - 2026-11-16

### Added

- Open the AI Assistant from Tools or the right edge of the window. Gemini is the default provider. Windows users can save their own provider key in Credential Manager through Settings.
- A floating up-arrow returns the active page to the top while scrolling.

### Changed

- The sidebar remembers the expanded navigation group. Opening another group closes the previous one.
- The screenshot script captures the running application with a sample project, including the assistant drawer.
- Tag builds launch the packaged Windows app as a smoke test before publishing `ProjectTracker.exe` to GitHub Releases.

### Fixed

- Sidebar controls have distinct click targets, including Planning → Goals and Management → Activity & Audit.
- Project tag filters use the correct controller methods.
- Existing databases gain the missing ordering columns for steps and deliverables on startup, preserving records and allowing notification checks to run.

## [1.0.0] - 2026-09-01

### Added
- Added Dark mode functionality with a settings toggle.
- Packaged application as a single executable using PyInstaller.
- GitHub Actions workflow for automated Windows executable releases.

### Added
- Project tracking desktop application built with PySide6 and QML.
- SQLite database integration (`db/database.py`) supporting full CRUD operations for projects, steps, deliverables, and resources.
- `ProjectController` backend with Signals, Slots, and Properties for QML data binding.
- Dashboard view displaying overall statistics, active projects, and upcoming close deadlines.
- Projects view with search functionality and status filter (All, Active, Paused, Completed).
- Project detail view for managing steps checklist, project deliverables, client details, and attaching links, documents, folder paths, and notes.
- Reusable modular QML components (`StatCard`, `StatusBadge`, `ProjectCard`, `StepItem`, `DeliverableItem`, `ResourceItem`, `ProjectDialog`, `CustomButton`, `CustomTextField`).
- Unit test suite using `pytest` and `pytest-qt`.
