<!-- CHANGELOG.md -->

# Changelog

All notable changes to `abbu` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

## [0.1.0] - 2026-04-12

### Added

- `Abbu.open(path)` entry point returning an `Archive`
- `Archive#contacts` — reads contacts from SQLite or falls back to plist stub
- `Archive#sqlite?` — detects modern `.abcddb` bundles
- `Contact` object with `first_name`, `last_name`, `emails`, `phones`, `company`, `full_name`
- `Parsers::SqliteParser` — queries `ZABCDRECORD`, `ZABCDEMAILADDRESS`, `ZABCDPHONENUMBER`
- `Parsers::PlistParser` — stub with warning (legacy `.abcdp` support in v0.2)
- `Exporters::CsvExporter` — `to_file` and `to_stdout`
- `Exporters::JsonExporter` — `to_file` and `to_stdout`
- `Exporters::VcardExporter` — `to_file` and `to_stdout` (vCard 3.0)
- `Utils::Deduplicator` — groups contacts by first email, returns duplicates hash
- `bin/abbu` CLI with `--format`, `--output`, `--stats`, `--dedupe`, `--version`
- Rake tasks: `abbu:export`, `abbu:dedupe`, `abbu:stats`
- Example scripts: CSV, JSON, vCard, API, CRM sync, stats, dedupe
- `docs/ABBU.md` — file format reference
- RSpec test suite with 100% coverage target
- Guard + RuboCop DX loop
- GitHub Actions CI (Ruby 3.2 + 3.3)

---
Stan Carver II
Made in Texas 🤠
https://stancarver.com
