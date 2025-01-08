## SemVer Tagger GitHub action

This GitHub action analyzes commit messages since the last version tag and:

- Bumps **major** version (X.0.0) when commits contain "breaking" changes
- Bumps **minor** version (0.X.0) for new features and non-breaking changes
- Bumps **patch** version (0.0.X) for commits containing "fix", "bugfix", etc.

## Usage

Basic usage:
```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    permissions:      # Required permissions
      contents: write # Needed for pushing tags
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required to fetch all tags
      - uses: sanikolaev/semver-tagger-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Important Note
Make sure to add the `permissions` section as shown above. The action requires `contents: write` permission to create and push tags.

### Ignored Files

By default, changes to the following files don't trigger version bumps:
- Markdown files (*.md)
- GitHub workflows and configuration (.github/*)
- YAML files (*.yml)
- .gitignore

You can customize this list using the `ignore_patterns` input parameter. Patterns should be pipe-separated.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `github_token` | GitHub token for authentication | Yes | N/A |
| `ignore_patterns` | Pipe-separated list of file patterns to ignore when calculating version bump | No | `.md\|.github/\|.yml\|.gitignore` |

## Example Usage

Basic usage:
```yaml
- uses: sanikolaev/semver-tagger-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

Custom ignore patterns:
```yaml
- uses: sanikolaev/semver-tagger-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    ignore_patterns: '.md|.txt|.docs/|package-lock.json'
```

## Example Scenarios

1. **Breaking Change**
   ```git
   git commit -m "breaking: completely redesign API"
   # 1.2.3 -> 2.0.0
   ```

2. **New Feature**
   ```git
   git commit -m "feat: add new authentication method"
   # 1.2.3 -> 1.3.0
   ```

3. **Bug Fix**
   ```git
   git commit -m "fix: resolve login issue"
   # 1.2.3 -> 1.2.4
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
