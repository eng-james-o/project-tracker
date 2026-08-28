# Contributing to Project Tracker Desktop

Thank you for considering contributing to Project Tracker Desktop! This document provides guidelines and instructions for submitting contributions to this repository.

## Conventional Commits

We follow the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages and pull request titles.

### Commit Message Format

Each commit message consists of a **header**, an optional **body**, and an optional **footer**:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature for the user or application.
- `fix`: A bug fix.
- `docs`: Documentation only changes.
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `chore`: Changes to the build process, tooling, or helper libraries.

### Examples

- `feat(dashboard): add urgent deadlines widget to dashboard`
- `fix(qml): correct padding on CustomTextField input box`
- `docs: update README with installation steps`
- `test(db): add unit test for deliverable completion`

---

## Pull Request Guidelines

1. **Branch Naming**: Use descriptive branch names matching conventional commit types:
   - `feat/feature-name`
   - `fix/bug-description`
   - `docs/updating-readme`
2. **PR Title**: Ensure the PR title follows Conventional Commits specification (e.g. `feat(projects): add status filter combo box`).
3. **Tests**: Ensure all pytest unit tests pass before submitting your PR:
   ```bash
   PYTHONPATH=. pytest tests/
   ```
4. **Changelog**: If your PR introduces user-visible changes or new features, update `CHANGELOG.md` under the `[Unreleased]` section following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

---

## Development Workflow

1. Fork/clone the repository and install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run the application locally:
   ```bash
   python main.py
   ```
3. Run tests to verify your changes:
   ```bash
   PYTHONPATH=. pytest tests/
   ```
