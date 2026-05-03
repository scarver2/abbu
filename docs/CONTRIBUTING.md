<!-- CONTRIBUTING.md -->

# Contributing to abbu

Thank you for your interest in contributing!

## Setup

```bash
git clone https://github.com/scarver2/abbu
cd abbu
mise exec -- bundle install
```

## DX Loop

```bash
mise exec -- bundle exec guard
```

This runs RSpec and RuboCop automatically on file changes.

## Running Tests

```bash
mise exec -- bundle exec rspec
```

## Linting

```bash
mise exec -- bundle exec rubocop
mise exec -- bundle exec rubocop -a   # autocorrect
```

## Pull Request Guidelines

- Base branch: `master`
- Commit style: [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`)
- All specs must pass and coverage must remain at 100%
- RuboCop must pass with no offenses
- Add an entry to `docs/CHANGELOG.md` under `[Unreleased]`

## Reporting Issues

Open an issue on GitHub with a minimal reproduction case.

---
Stan Carver II
Made in Texas 🤠
https://stancarver.com
