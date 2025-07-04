#!/bin/bash
# Initialize test repo
rm -rf semver-test && mkdir semver-test && cd semver-test
git init -b main

# Configure authors
git config user.name "Conventional User"
git config user.email "conventional@example.com"

# ===========================================
# 1. CREATE TEST COMMITS
# ===========================================

# Create base files with proper directories
mkdir -p .github/workflows manual tests
echo "Core functionality" > main.py
echo "Documentation" > README.md
echo "Test cases" > tests/test_main.py
echo "Manual" > manual/guide.txt

git add .
git commit -m "Initial commit. New version 0.0.0
EXPECTED: IGNORED (initial commit)"

# ======================
# 1. BREAKING CHANGES
# ======================
echo "New API" > api.py
git add api.py
git commit -m "feat(api)!: remove deprecated endpoint. New version 1.0.0
EXPECTED: MAJOR (explicit !)"

# Fix sed command for macOS (use -i '' instead of just -i)
sed -i '' 's/Core/More/' main.py
git commit -am "fix!: drop support for Node 12. New version 2.0.0
EXPECTED: MAJOR (explicit !)"

echo "BREAKING CHANGE: CSS vars changed" > breaking.cpp
git add breaking.cpp
git commit -m "chore: update styles. New version 3.0.0

BREAKING CHANGE: CSS vars changed
EXPECTED: MAJOR (footer)"

# ======================
# 2. VERSION CHANGES
# ======================
echo "2.0.0" > version.cpp
git add version.cpp
git commit -m "Version bump from 1.2.3 to 2.0.0
EXPECTED: no change since the author is conventional user"

echo "1.3.0" > version.cpp
git commit -am "Version bump from 1.2.3 to 1.3.0
EXPECTED: no change since the author is conventional user"

# ======================
# 3. CONVENTIONAL COMMITS
# ======================
echo "Geosearch" > search.py
git add search.py
git commit -m "feat(search): add geosearch. New version 3.1.0
EXPECTED: MINOR (starts with feat:)"

sed -i '' 's/null/NULL/g' main.py
git commit -am "fix(parser): handle null values. New version 3.1.1
EXPECTED: PATCH (fix: prefix)"

echo "Updated docs" >> README.md
git commit -am "docs: update README.
EXPECTED: IGNORED (.md file)"

echo "New API" > api_v2.py
git add api_v2.py
git commit -m "feat: new API. New version 3.2.0
EXPECTED: IGNORED (starts with docs:)"

# ======================
# 4. LEGACY COMMITS
# ======================
git config user.name "Legacy User"
git config user.email "legacy@example.com"

echo "Dashboard" > dashboard.py
git add dashboard.py
git commit -m "feature: new dashboard. New version 3.3.0
EXPECTED: MINOR (starts with feature:)"

sed -i '' '/leak/d' main.py
git commit -am "Fixed memory leak. New version 3.3.1
EXPECTED: PATCH (contains fix)"

git commit -am "improve performance.
EXPECTED: IGNORED (no signal)"

echo "2.5.2" > version.cpp
git commit -am "Version from 2.3.5 to 2.5.2. New version 3.4.0
EXPECTED: MINOR (version bump)"

# ======================
# 5. GITHUB REFERENCES
# ======================
# PR with feature label
sed -i '' 's/OAuth/OAuth2/' main.py
git commit -am "feat(auth): implement OAuth (PR https://github.com/manticoresoftware/semver-test/pull/1). New version 3.5.0

EXPECTED: MINOR (PR label)
PR https://github.com/manticoresoftware/semver-test/pull/1: 
  labels: [\"feature\"]"

# Issue with Bug type
echo "config" > config.cfg
git add config.cfg
git commit -m "fix(config): update config (fixes https://github.com/manticoresoftware/semver-test/issues/2). New version 3.5.1

EXPECTED: PATCH (issue type)
ISSUE https://github.com/manticoresoftware/semver-test/issues/2: 
  type: Bug"

# PR with breaking change
echo "New API" > api_v3.py
git add api_v3.py
git commit -m "feat!: new API (PR https://github.com/manticoresoftware/semver-test/pull/3). New version 4.0.0
EXPECTED: MAJOR (breaking beats PR)
PR https://github.com/manticoresoftware/semver-test/pull/3: 
  labels: [\"bug\"]"

# ======================
# 6. FILE PATTERN IGNORES
# ======================
echo "update" >> manual/guide.txt
git commit -am "docs(manual): update guide.
EXPECTED: IGNORED (.txt file)"

# ======================
# 7. MERGE COMMITS
# ======================
git checkout -b dev
echo "dev change" > dev.py
git add dev.py
git commit -m "dev: new feature.
EXPECTED: IGNORED (starts with dev: )"
git checkout main
git merge dev -m "Merge branch 'dev'.
EXPECTED: IGNORED (merge commit)"

# ======================
# 8. ADDITIONAL EDGE CASES
# ======================
# Fix with breaking change footer
echo "line 151" > main.py
git add main.py
git commit -am "fix(ui): button color. New version 5.0.0

BREAKING CHANGE: CSS classes renamed
EXPECTED: MAJOR (footer beats fix)"

# Random commit
echo "update" >> .gitignore
git add .gitignore
git commit -m "random commit message.
EXPECTED: IGNORED (.gitignore is ignored)"

# ======================
# 9. MISSING TEST CASES
# ======================
# Explicit version changes
echo "1.2.4" > version.cpp
git commit -am "Version from 1.2.3 to 1.2.4. New version 5.0.1
EXPECTED: PATCH (patch version increase)"

echo "1.0.0" > version.cpp
git commit -am "Version from 2.0.0 to 2.0.1. New version 5.0.2
EXPECTED: PATCH (patch version increase)"

# Conventional commits validation
git config user.name "Conventional User"
git config user.email "conventional@example.com"
echo "invalid" > invalid.py
git add invalid.py
git commit -m "invalid commit message.
EXPECTED: IGNORED (invalid conventional format)"

git config user.name "Legacy User"
git config user.email "legacy@example.com"
echo "valid" > valid.py
git add valid.py
git commit -m "feat: valid conventional format from legacy user. New version 5.1.0
EXPECTED: MINOR (valid conventional format from any user)"

# GitHub references
echo "feature" > feature.py
git add feature.py
git commit -m "feat: new feature (fixes https://github.com/manticoresoftware/semver-test/issues/3). New version 5.2.0
EXPECTED: MINOR (issue type Feature)
ISSUE https://github.com/manticoresoftware/semver-test/issues/3: 
  type: Feature"

echo "bugfix" > bugfix.py
git add bugfix.py
git commit -m "fix: bug fix (PR https://github.com/manticoresoftware/semver-test/pull/4). New version 5.2.1
EXPECTED: PATCH (PR label bug)
PR https://github.com/manticoresoftware/semver-test/pull/4: 
  labels: bug"

# Conflict resolution
echo "2.1.0" > version.cpp
git commit -am "Version from 2.0.0 to 2.1.0. New version 5.3.0
feat: new feature
EXPECTED: MINOR (explicit version beats conventional)"

echo "3.0.0" > version.cpp
git commit -am "Version from 2.1.0 to 3.0.0 (PR https://github.com/manticoresoftware/semver-test/pull/5). New version 6.0.0
EXPECTED: MAJOR (explicit version beats PR)
PR https://github.com/manticoresoftware/semver-test/pull/5: 
  labels: feature"

# Additional filters
git checkout -b test-branch
echo "test" > test.py
git add test.py
git commit -m "test: add unit tests.
EXPECTED: IGNORED (starts with test)"

echo "ci" > ci.py
git add ci.py
git commit -m "ci: update CI config.
EXPECTED: IGNORED (starts with ci:)"

# Merge with changes
git checkout main
git merge test-branch -m "Merge branch 'test-branch'.
EXPECTED: IGNORED (merge with file changes, but no changes to version in the commit message)"

# Multiple triggers
echo "multi" > multi.py
git add multi.py
git commit -m "feat: multiple triggers (PR https://github.com/manticoresoftware/semver-test/pull/6). New version 6.1.0
EXPECTED: MINOR (conventional beats PR)
PR https://github.com/manticoresoftware/semver-test/pull/6: 
  labels: feature"

# Invalid conventional but valid GitHub reference
echo "invalid-ref" > invalid-ref.py
git add invalid-ref.py
git commit -m "invalid conventional (PR https://github.com/manticoresoftware/semver-test/pull/7). New version 6.2.0
EXPECTED: MINOR (valid GitHub reference)
PR https://github.com/manticoresoftware/semver-test/pull/7: 
  labels: feature"

git checkout main

# ======================
# 10. BRANCH MERGE TEST
# ======================
echo "DEBUG: Starting branch merge test..."

# Create branch merge1
git checkout -b merge1
echo "branch fix" > branch_fix.py
git add branch_fix.py
git commit -m "fix(branch): branch fix. No increment as it's a branch commit"

# Commit something into master
git checkout main
echo "main change" > main_change.py
git add main_change.py
git commit -m "chore: main change."

# Commit a feature into merge1
git checkout merge1
echo "branch feature" > branch_feature.py
git add branch_feature.py
git commit -m "feat(branch): branch feature. No increment as it's a branch commit"

# Merge main into the branch
git merge main -m "Merge main into merge1.
EXPECTED: IGNORED (merge into branch)"

# Merge from merge1 into the master
git checkout main
git merge merge1 -m "Merge merge1 into main. New version 6.3.0
EXPECTED: MINOR (merge commit message increment)"

# ===========================================
# 11. SETUP GITHUB REPOSITORY
# ===========================================

# Check if we have the required permissions
echo "DEBUG: Checking GitHub authentication status..."
if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "Error: Not authenticated with GitHub. Please run 'gh auth login' first."
  exit 1
fi

# Try to create the repository
echo "DEBUG: Creating GitHub repository..."
if ! gh repo create manticoresoftware/semver-test --public --push --source=. --description "Test repository for semver-tagger-action"; then
  echo "Error: Failed to create repository. Please ensure:"
  echo "1. You have the necessary permissions"
  echo "2. The repository doesn't already exist"
  exit 1
fi

# Add origin remote if it doesn't exist
echo "DEBUG: Setting up git remote..."
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin https://github.com/manticoresoftware/semver-test.git
fi

# Create labels first (required for issues/PRs)
echo "DEBUG: Creating bug label..."
gh label create bug --color d73a4a --description "Bug fixes" -R manticoresoftware/semver-test

echo "DEBUG: Creating feature label..."
gh label create feature --color a2eeef --description "New features" -R manticoresoftware/semver-test

# Create issues with proper labels
echo "DEBUG: Creating bug issue..."
gh issue create -t "Config parser bug" -b "Fixes needed" \
  -l bug -R manticoresoftware/semver-test --web=false

echo "DEBUG: Creating feature issue..."
gh issue create -t "New OAuth feature" -b "Implementation" \
  -l feature -R manticoresoftware/semver-test --web=false

# Create issue #3 (Feature type)
echo "DEBUG: Creating issue #3..."
ISSUE3=$(gh issue create -t "Feature implementation" -b "New feature to be implemented" \
  -R manticoresoftware/semver-test --web=false)

echo "Please set the type of issue #3 to 'Feature' in the GitHub UI:"
echo "1. Go to https://github.com/manticoresoftware/semver-test/issues/3"
echo "2. Click 'Labels' on the right sidebar"
echo "3. Add the 'type: Feature' label"
echo "Press Enter when done..."
read

# Create PR branches with actual changes
echo "DEBUG: Creating and pushing oauth branch..."
git checkout -b oauth
echo "# OAuth Implementation" > oauth.md
git add oauth.md
git commit -m "feat: add OAuth implementation"
git push -u origin oauth --force

echo "DEBUG: Creating and pushing breaking-api branch..."
git checkout main
git checkout -b breaking-api
echo "# Breaking API Changes" > breaking-api.md
git add breaking-api.md
git commit -m "feat!: breaking API changes"
git push -u origin breaking-api --force

# Create branches for PRs #4-7
echo "DEBUG: Creating branches for PRs #4-7..."
for i in {4..7}; do
  git checkout -b pr-$i
  echo "# PR $i Changes" > pr-$i.md
  git add pr-$i.md
  git commit -m "feat: changes for PR $i"
  git push -u origin pr-$i --force
  git checkout main
done

# Wait a moment for GitHub to process the pushes
sleep 2

# Create PRs after pushing branches
echo "DEBUG: Creating OAuth PR..."
gh pr create -t "OAuth support" -b "Adds OAuth2 implementation" \
  -l feature -R manticoresoftware/semver-test \
  --base main --head oauth --fill --web=false

echo "DEBUG: Creating breaking API PR..."
gh pr create -t "Breaking API change" -b "New API version with breaking changes" \
  -l bug -R manticoresoftware/semver-test \
  --base main --head breaking-api --fill --web=false

# Create PRs #4-7 with proper labels
echo "DEBUG: Creating PR #4 (bug label)..."
gh pr create -t "Bug fix implementation" -b "Fixes a critical bug" \
  -l bug -R manticoresoftware/semver-test \
  --base main --head pr-4 --fill --web=false

echo "DEBUG: Creating PR #5 (feature label)..."
gh pr create -t "Feature implementation" -b "Adds new feature" \
  -l feature -R manticoresoftware/semver-test \
  --base main --head pr-5 --fill --web=false

echo "DEBUG: Creating PR #6 (feature label)..."
gh pr create -t "Multiple triggers feature" -b "Implements multiple triggers" \
  -l feature -R manticoresoftware/semver-test \
  --base main --head pr-6 --fill --web=false

echo "DEBUG: Creating PR #7 (feature label)..."
gh pr create -t "Invalid conventional format" -b "Changes with invalid conventional format" \
  -l feature -R manticoresoftware/semver-test \
  --base main --head pr-7 --fill --web=false

# Add GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: test

on:
  push:
    branches:
      - main
     
jobs:
  test:
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Update version
        id: semver-tagger
        uses: sanikolaev/semver-tagger-action@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          conventional_commits_authors: conventional@example.com
          debug: true
          ignore_patterns: '\.md$|^test/|^manual/|\^.clt|\^.github|\^.patterns|\.txt$|\.yml$|\^.gitignore'
EOF

git add .github/workflows/ci.yml
git commit -m "ci: add GitHub Actions workflow."
git push origin main

echo "==========================================="
echo "Test repository setup complete!"
echo "Repository URL: https://github.com/manticoresoftware/semver-test"
echo "CI Workflow: https://github.com/manticoresoftware/semver-test/actions"
echo "==========================================="
