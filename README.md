## SemVer Tagger GitHub Action

This GitHub action automatically creates and pushes version tags based on your commit messages, following semantic versioning ([SemVer](https://semver.org/)) principles.

### What it does:

1. Checks out repository at the current commit
2. Scans all commits since the last version tag
3. Analyzes commit messages to determine the type of changes
4. Automatically calculates the next version number based on:
   - **MAJOR** version (X.0.0) - when commits contain "breaking" changes
   - **MINOR** version (0.X.0) - for new features and non-breaking changes
   - **PATCH** version (0.0.X) - for bug fixes (commits with "fix", "bugfix", etc.)
5. Creates and pushes a new Git tag with the calculated version
6. Outputs both simple version (X.Y.Z) and full version with metadata

For example:
- If current version is `v1.2.3` and you commit with "feat!: new API"
  → Action creates tag `v2.0.0`
- If current version is `v1.2.3` and you commit with "feat: new login"
  → Action creates tag `v1.3.0`
- If current version is `v1.2.3` and you commit with "fix: login bug"
  → Action creates tag `v1.2.4`

## Usage

Basic usage with outputs:
```yaml
jobs:
  update-version:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.semver-tagger.outputs.version }}
      version_full: ${{ steps.semver-tagger.outputs.version_full }}
      version_rpm: ${{ steps.semver-tagger.outputs.version_rpm }}
      version_deb: ${{ steps.semver-tagger.outputs.version_deb }}
      target: ${{ steps.semver-tagger.outputs.target }}
      version_updated: ${{ steps.semver-tagger.outputs.version_updated }}
      target: ${{ steps.semver-tagger.outputs.target }}
    permissions:
      contents: write  # Required for pushing tags
    steps:
      - id: semver-tagger
        uses: manticoresoftware/semver-tagger-action@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          conventional_commits_authors: "user@example.com"  # Optional: enforce conventional commits for specific authors
          debug: true  # Optional: enable debug mode
          ignore_patterns: "\.md$|\.txt$|^test/|^manual/|\.clt|\.github|\.patterns|\.yml|\.gitignore"  # Optional: customize ignored files

  # Optional: Use the version in subsequent jobs
  release:
    needs: update-version
    if: ${{ needs.update-version.outputs.version != '' }}
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "New version: ${{ needs.update-version.outputs.version }}"
          echo "Full version: ${{ needs.update-version.outputs.version_full }}"
          echo "RPM version: ${{ needs.update-version.outputs.version_rpm }}"
          echo "DEB version: ${{ needs.update-version.outputs.version_deb }}"
          echo "Version updated: ${{ needs.update-version.outputs.version_updated }}"
          echo "Build target: ${{ needs.update-version.outputs.target }}"
```

### Important Notes
- The action requires `contents: write` permission to create and push tags
- The action outputs multiple version formats and metadata:
  - `version`: Simple semver format (e.g., "1.2.3")
  - `version_full`: Extended format with metadata (e.g., "1.2.3+230415-a1b2c3d4[-dev|-<branch name>")
  - `version_rpm`: RPM-compatible format (e.g., "1.2.3.230415.a1b2c3d4")
  - `version_deb`: DEB-compatible format (e.g., "1.2.3+230415-a1b2c3d4")
  - `version_updated`: Boolean indicating if version was updated
  - `target`: Build target - "release" when commit has release tag, "dev" otherwise
- The full version format includes:
  - Base version
  - Commit timestamp (YYMMDDHHH)
  - Commit hash (8 chars)
  - Branch name (for non-main branches)
  - "-dev" suffix for main/master branches
  - No suffix for releases (when the commit is tagged with "release")

### Ignored Files

By default, changes to the following files don't trigger version bumps:
- Markdown files (*.md)
- Text files (*.txt)
- Test files (test/*)
- Manual files (manual/*)
- GitHub workflows and configuration (.github/*)
- YAML files (*.yml)
- .gitignore
- .clt files
- .patterns files

You can customize this list using the `ignore_patterns` input parameter.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `github_token` | GitHub token for authentication | Yes | N/A |
| `ignore_patterns` | Pipe-separated list of file patterns to ignore | No | `.md$|.txt$|^test/|^manual/|.clt|.github|.patterns|.yml|.gitignore` |
| `conventional_commits_authors` | Comma-separated list of commit authors whose commits should be analyzed following strict Conventional Commits rules | No | '' |
| `debug` | Enable debug mode for verbose output | No | 'false' |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `version` | Simple semver version | `1.2.3` |
| `version_full` | Full version with metadata | `1.2.3+23041507-a1b2c3d4-dev` |
| `version_rpm` | RPM-compatible version | `1.2.3.23041507.a1b2c3d4` |
| `version_deb` | DEB-compatible version | `1.2.3+23041507-a1b2c3d4` |
| `version_updated` | Whether version was updated | `true` |
| `target` | Build target | `release` or `dev` |

## How it works: Core Rules (Ordered by Precedence)

### 1. Breaking Change (Highest Priority)
- **Triggers:**
  - Commit message matches `^(\w+)(\([^)]+\))?!:`
  - Commit message contains footer "BREAKING CHANGE:"
- **Effect:** 
  - Increment major version
  - Reset minor and patch to 0
- **Examples:**
  - Current version: `v1.2.3`. Commit: `feat!: remove deprecated API endpoint`
    → New version: `v2.0.0`
  - Current version: `v3.5.1`. Commit: `refactor(api)!: change authentication method`
    → New version: `v4.0.0`
  - Current version: `v2.1.0`. Commit: `fix: resolve memory leak\n\nBREAKING CHANGE: Database schema changed`
    → New version: `v3.0.0`

### 2. Explicit Version Change
- **Triggers:**
  - Commit message matches "Version from X.Y.Z to A.B.C"
- **Analysis:**
  - If major increased → increment major, reset minor and patch
  - If minor increased → increment minor, reset patch
  - If patch increased → increment patch
- **Examples:**
  - Current version: `v1.2.3`. Commit: `Version from 2.2.3 to 3.0.0`
    → New version: `v2.0.0` (major increment)
  - Current version: `v1.2.3`. Commit: `Version from 1.2.3 to 1.5.0`
    → New version: `v1.3.0` (minor increment)
  - Current version: `v1.2.3`. Commit: `Version from 1.2.3 to 1.2.7`
    → New version: `v1.2.4` (patch increment)

### 3. Commit Message
- **Conventional Format:**
  - `feat:` → increment minor, reset patch
  - `fix:` → increment patch
- **Legacy Format:**
  - `feature:` → increment minor, reset patch
  - Contains "fix" → increment patch
- **Precedence:** Conventional > Legacy
- **Examples:**
  - Current version: `v1.2.3`. Commit: `feat: add user authentication`
    → New version: `v1.3.0` (minor increment)
  - Current version: `v1.2.3`. Commit: `feat(api): implement rate limiting`
    → New version: `v1.3.0` (minor increment)
  - Current version: `v1.2.3`. Commit: `fix: resolve login timeout issue`
    → New version: `v1.2.4` (patch increment)
  - Current version: `v1.2.3`. Commit: `fix(security): patch SQL injection vulnerability`
    → New version: `v1.2.4` (patch increment)
  - Current version: `v1.2.3`. Commit: `feature: new dashboard UI`
    → New version: `v1.3.0` (legacy format, minor increment)
  - Current version: `v1.2.3`. Commit: `fixed correct calculation error`
    → New version: `v1.2.4` (legacy format, patch increment)

### 4. GitHub Reference (Lowest Priority)
- **Triggers:**
  - PR/issue labeled "feature" or type "Feature" → increment minor, reset patch
  - PR/issue labeled "bug" or type "Bug" → increment patch
- **Precedence:** PR > Issue
- **Examples:**
  - Current version: `v1.2.3`. Commit references PR #42 with label "feature"
    → New version: `v1.3.0` (minor increment)
  - Current version: `v1.2.3`. Commit references PR #15 with type "Feature"
    → New version: `v1.3.0` (minor increment)
  - Current version: `v1.2.3`. Commit references issue #88 with label "bug"
    → New version: `v1.2.4` (patch increment)
  - Current version: `v1.2.3`. Commit references issue #12 with type "Bug"
    → New version: `v1.2.4` (patch increment)
  - Current version: `v1.2.3`. Commit references both PR #10 (labeled "feature") and issue #5 (labeled "bug")
    → New version: `v1.3.0` (PR takes precedence over issue)

## Validation
- **Conventional Commits Pattern:**
  ```
  ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\([a-z0-9-]+\))?!?:[[:space:]]
  ```
- Required for authors listed in `conventional_commits_authors`

## Filters
Commits are ignored when:
- Commit message matches `^(ci|chore|docs|test)(\([^)]+\))?:`
- Modified files match `ignore_patterns`
- Merge commit with no file changes
- All changed files are ignored

## Execution Flow
1. Skip if matches ignore filters
2. For conventional authors:
   - Reject if commit message doesn't match validation pattern
3. Check for triggers in resolution order
4. Apply first matching effect
5. If no triggers → no version bump
6. Create git tag
7. Generate version formats
8. Push tags if in GitHub Actions

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
