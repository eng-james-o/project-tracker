# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
