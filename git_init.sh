#!/bin/bash
set -e

# Let's see what is already added, wait, git failed on the first add, so nothing is added yet.
git add abbu.gemspec Gemfile .gitignore LICENSE README.md CONTRIBUTING.md CHANGELOG.md bin/ lib/abbu.rb lib/abbu/version.rb
git commit -m "feat: core gem setup and configuration"

git add lib/abbu/contact.rb
[ -d "lib/abbu/utils" ] && git add lib/abbu/utils/
git commit -m "feat: add Contact model and utilities"

git add lib/abbu/archive.rb lib/abbu/parsers/
git commit -m "feat: implement Apple Address Book parsers"

git add lib/abbu/exporters/
git commit -m "feat: implement contact exporters"

git add spec/ .rspec .rubocop.yml .simplecov Guardfile tasks/
git commit -m "test: add rspec suite and quality tools"

git add docs/ examples/
git commit -m "docs: add documentation and usage examples"

git add .
git diff-index --quiet HEAD || git commit -m "chore: add remaining files"

git push -u origin feature/initial-codebase
gh pr create --title "Initial Codebase Implementation" --body "This PR introduces the initial codebase for the \`abbu\` gem. It includes the core framework, SQLite and Plist parsers, CSV/JSON/vCard exporters, test suite, and documentation."
