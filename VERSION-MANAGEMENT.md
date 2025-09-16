# Version Management Guide

This guide covers version management across all 12 microfrontends, including synchronization, publishing, and deployment strategies.

## Version Strategy

### Synchronized Versioning
All 12 microfrontends use **synchronized versioning** - they share the same version number for consistency and easier management.

**Current Architecture:**
- **Root App**: Orchestrator (always matches other apps)
- **11 Microfrontends**: All use identical version numbers
- **Synchronized Updates**: Version changes apply to all apps simultaneously

### Semantic Versioning
Following [Semantic Versioning (SemVer)](https://semver.org/) principles:

```
MAJOR.MINOR.PATCH
1.2.3
│ │ │
│ │ └── Patch: Bug fixes, no breaking changes
│ └──── Minor: New features, backward compatible
└────── Major: Breaking changes, not backward compatible
```

## Version Management Commands

### Check Current Versions
```bash
# Show versions of all packages
npm run version:current

# Check specific app version
cd single-spa-auth-app
npm version
```

### Set Specific Version
```bash
# Set version for all packages
npm run version:set 1.2.3

# Verify version was set
npm run version:current
```

### Automatic Version Bumping
```bash
# Patch version (1.0.0 → 1.0.1)
npm run version:bump:patch

# Minor version (1.0.0 → 1.1.0)
npm run version:bump:minor

# Major version (1.0.0 → 2.0.0)
npm run version:bump:major
```

## Publishing with Version Management

### NPM Publishing
```bash
# Publish with version bump
npm run publish:npm:patch    # Bump patch and publish
npm run publish:npm:minor    # Bump minor and publish
npm run publish:npm:major    # Bump major and publish

# Publish without version bump
npm run publish:npm:nobump   # Use current version
```

### Nexus Publishing
```bash
# Publish with version bump
npm run publish:nexus:patch  # Bump patch and publish
npm run publish:nexus:minor  # Bump minor and publish
npm run publish:nexus:major  # Bump major and publish

# Publish without version bump
npm run publish:nexus:nobump # Use current version
```

### Complete Publishing Workflow
```bash
# Publish to both registries with version bump
npm run publish:all:patch    # Patch to both NPM and Nexus
npm run publish:all:minor    # Minor to both NPM and Nexus
npm run publish:all:major    # Major to both NPM and Nexus
```

## Version Synchronization

### Automatic Synchronization
The project maintains version synchronization automatically:

1. **Version Scripts**: All version commands update all 12 packages
2. **Publishing Scripts**: Ensure all packages have same version before publishing
3. **Fix Scripts**: Synchronize versions when switching between registries
4. **Launcher Scripts**: Verify version consistency before starting

### Manual Synchronization
```bash
# Force synchronization to specific version
npm run version:set 2.1.0

# Verify all packages have same version
npm run version:current

# Fix any version mismatches
npm run fix:auto
```

## Registry-Specific Versioning

### NPM Registry Versions
```bash
# Check NPM registry versions
npm view @cesarchamal/single-spa-auth-app versions --json

# Check latest NPM version
npm view @cesarchamal/single-spa-auth-app version

# Publish specific version to NPM
npm run version:set 1.5.0
npm run publish:npm:nobump
```

### Nexus Registry Versions
```bash
# Check Nexus registry versions (requires authentication)
npm view @cesarchamal/single-spa-auth-app versions --registry http://localhost:8081/repository/npm-group/

# Publish specific version to Nexus
npm run version:set 1.5.0
npm run publish:nexus:nobump
```

### Version Alignment
```bash
# Align local version with NPM
npm run fix:npm:deps:root

# Align local version with Nexus
npm run fix:nexus:deps:root

# Check version alignment
npm run check:npm
npm run check:nexus
```

## Deployment Versioning

### GitHub Pages Versioning
```bash
# Deploy specific version to GitHub
npm run version:set 2.0.0
./run.sh github prod

# Version is embedded in deployed files
# Check: https://username.github.io/single-spa-auth-app/single-spa-auth-app.js
```

### AWS S3 Versioning
```bash
# Deploy specific version to AWS
npm run version:set 2.0.0
./run.sh aws prod

# Import map includes version information
# Check: https://bucket.s3.amazonaws.com/@org/importmap.json
```

### Version Tagging
```bash
# Create Git tags for versions
git tag v1.2.3
git push origin v1.2.3

# List all version tags
git tag -l "v*"
```

## Version Workflows

### Development Workflow
```bash
# 1. Start development
./run.sh local dev

# 2. Make changes and test
# ... development work ...

# 3. Bump version for release
npm run version:bump:patch

# 4. Publish to registries
npm run publish:all:nobump

# 5. Deploy to external services
./run.sh github prod
./run.sh aws prod
```

### Release Workflow
```bash
# 1. Set release version
npm run version:set 2.1.0

# 2. Test all modes
./run.sh local prod
./run.sh npm dev
./run.sh nexus dev

# 3. Publish to registries
npm run publish:all:nobump

# 4. Deploy to production
./run.sh github prod
./run.sh aws prod

# 5. Create Git tag
git tag v2.1.0
git push origin v2.1.0
```

### Hotfix Workflow
```bash
# 1. Create hotfix branch
git checkout -b hotfix/2.1.1

# 2. Fix issue and test
# ... fix implementation ...

# 3. Bump patch version
npm run version:bump:patch

# 4. Publish hotfix
npm run publish:all:nobump

# 5. Deploy immediately
./run.sh aws prod

# 6. Merge back to main
git checkout main
git merge hotfix/2.1.1
```

## Version Troubleshooting

### Version Mismatch Issues
```bash
# Problem: Different versions across packages
# Solution: Force synchronization
npm run version:set 1.2.3
npm run version:current  # Verify all match
```

### Registry Version Conflicts
```bash
# Problem: Local 1.2.3, NPM has 1.1.0, Nexus has 1.2.0
# Solution: Align versions
npm run fix:npm:deps:root     # Align with NPM
# OR
npm run publish:npm:nobump    # Publish current to NPM
```

### Missing Versions in Registry
```bash
# Problem: Package not found in registry
# Solution: Publish current version
npm run publish:npm:nobump
npm run publish:nexus:nobump
```

### Deployment Version Issues
```bash
# Problem: Deployed version doesn't match local
# Solution: Redeploy with current version
./run.sh github prod
./run.sh aws prod
```

## Version Checking and Status

### Comprehensive Version Check
```bash
# Check all versions across all systems
npm run version:status:all

# Individual checks
npm run version:current       # Local versions
npm run check:npm            # NPM registry versions
npm run check:nexus          # Nexus registry versions
npm run check:github         # GitHub deployment versions
npm run check:aws            # AWS deployment versions
```

### Version Comparison
```bash
# Compare local vs registry versions
npm run version:compare:npm
npm run version:compare:nexus

# Show version differences
npm run version:diff
```

## Advanced Version Management

### Conditional Versioning
```bash
# Different versions for different environments
if [ "$NODE_ENV" = "production" ]; then
  npm run version:set 2.0.0
else
  npm run version:set 2.0.0-dev
fi
```

### Automated Version Bumping
```bash
# Based on commit messages (conventional commits)
npm install -g conventional-changelog-cli
npm run version:auto  # Auto-bump based on commits
```

### Version Rollback
```bash
# Rollback to previous version
npm run version:rollback

# Rollback to specific version
npm run version:set 1.9.0
npm run publish:all:nobump
./run.sh aws prod
```

### Pre-release Versions
```bash
# Create pre-release versions
npm run version:set 2.0.0-alpha.1
npm run version:set 2.0.0-beta.1
npm run version:set 2.0.0-rc.1

# Publish pre-release
npm run publish:npm:nobump --tag alpha
```

## Version Documentation

### Changelog Management
```bash
# Generate changelog
npm run changelog:generate

# Update changelog for version
npm run changelog:update 2.1.0
```

### Version History
```bash
# Show version history
git log --oneline --grep="version"

# Show tagged versions
git tag -l "v*" --sort=-version:refname
```

### Release Notes
```bash
# Generate release notes
npm run release:notes 2.1.0

# Create GitHub release
gh release create v2.1.0 --generate-notes
```

## Best Practices

### Version Planning
- **Major versions**: Plan breaking changes carefully
- **Minor versions**: Group related features
- **Patch versions**: Individual bug fixes
- **Pre-releases**: Use for testing before stable release

### Version Communication
- **Changelog**: Document all changes
- **Release notes**: Highlight important changes
- **Migration guides**: For breaking changes
- **Deprecation notices**: For removed features

### Version Testing
```bash
# Test version compatibility
npm run test:version:compatibility

# Test upgrade path
npm run test:upgrade:path 1.9.0 2.0.0

# Test rollback capability
npm run test:rollback 2.0.0 1.9.0
```

### Version Security
- **Audit versions**: Regular security audits
- **Update dependencies**: Keep dependencies current
- **Version pinning**: Pin critical dependency versions
- **Security patches**: Prioritize security updates

## Integration with CI/CD

### Automated Version Management
```yaml
# .github/workflows/version.yml
name: Version Management
on:
  push:
    branches: [main]
jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Bump version
        run: npm run version:bump:patch
      - name: Publish packages
        run: npm run publish:all:nobump
      - name: Deploy
        run: ./run.sh aws prod
```

### Version-based Deployment
```bash
# Deploy based on version tags
if [[ $GITHUB_REF == refs/tags/v* ]]; then
  VERSION=${GITHUB_REF#refs/tags/v}
  npm run version:set $VERSION
  ./run.sh aws prod
fi
```