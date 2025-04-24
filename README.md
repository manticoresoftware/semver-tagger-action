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
- If current version is `v1.2.3` and you commit with "breaking: new API"
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

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
