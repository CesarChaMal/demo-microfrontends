#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Find project root directory (where main package.json is located)
const findProjectRoot = () => {
  let currentDir = __dirname;
  while (currentDir !== path.dirname(currentDir)) {
    const packagePath = path.join(currentDir, 'package.json');
    if (fs.existsSync(packagePath)) {
      const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      if (pkg.name === 'demo-microfrontends') {
        return currentDir;
      }
    }
    currentDir = path.dirname(currentDir);
  }
  // Fallback: assume we're in scripts/ directory
  return path.join(__dirname, '..');
};

const PROJECT_ROOT = findProjectRoot();

// All package directories (relative to project root)
const PACKAGES = [
  '.',
  'single-spa-root',
  'single-spa-auth-app',
  'single-spa-layout-app',
  'single-spa-home-app',
  'single-spa-angular-app',
  'single-spa-vue-app',
  'single-spa-react-app',
  'single-spa-vanilla-app',
  'single-spa-webcomponents-app',
  'single-spa-typescript-app',
  'single-spa-jquery-app',
  'single-spa-svelte-app'
].map(dir => path.join(PROJECT_ROOT, dir));

function readPackageJson(packageDir) {
  const packagePath = path.join(packageDir, 'package.json');
  if (!fs.existsSync(packagePath)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(packagePath, 'utf8'));
}

function writePackageJson(packageDir, packageData) {
  const packagePath = path.join(packageDir, 'package.json');
  // Remove _trigger field if it exists
  if (packageData._trigger) {
    delete packageData._trigger;
  }
  fs.writeFileSync(packagePath, JSON.stringify(packageData, null, 2) + '\n');
}

function incrementVersion(version, type = 'patch') {
  const [major, minor, patch] = version.split('.').map(Number);
  
  switch (type) {
    case 'major':
      return `${major + 1}.0.0`;
    case 'minor':
      return `${major}.${minor + 1}.0`;
    case 'patch':
    default:
      return `${major}.${minor}.${patch + 1}`;
  }
}

function getCurrentVersion() {
  const mainPackage = readPackageJson(PROJECT_ROOT);
  return mainPackage ? mainPackage.version : '0.1.0';
}

function updateAllVersions(newVersion) {
  console.log(`📦 Updating all packages to version ${newVersion}...`);
  
  let updated = 0;
  let failed = 0;
  
  for (const packageDir of PACKAGES) {
    try {
      const packageData = readPackageJson(packageDir);
      if (!packageData) {
        console.log(`⚠️  No package.json found in ${packageDir}`);
        continue;
      }
      
      const oldVersion = packageData.version;
      packageData.version = newVersion;
      
      // Update dependencies if they reference our packages
      if (packageData.dependencies) {
        for (const [depName] of Object.entries(packageData.dependencies)) {
          if (depName.startsWith('@cesarchamal/single-spa-')) {
            packageData.dependencies[depName] = `^${newVersion}`;
          }
        }
      }
      
      // Also update package-npm.json if it exists (for NPM mode)
      if (path.basename(packageDir) === 'single-spa-root') {
        const npmPackagePath = path.join(packageDir, 'package-npm.json');
        if (fs.existsSync(npmPackagePath)) {
          const npmPackageData = JSON.parse(fs.readFileSync(npmPackagePath, 'utf8'));
          npmPackageData.version = newVersion;
          
          // Update NPM dependencies
          if (npmPackageData.dependencies) {
            for (const [depName] of Object.entries(npmPackageData.dependencies)) {
              if (depName.startsWith('@cesarchamal/single-spa-')) {
                npmPackageData.dependencies[depName] = `^${newVersion}`;
              }
            }
          }
          
          if (npmPackageData._trigger) {
            delete npmPackageData._trigger;
          }
          
          fs.writeFileSync(npmPackagePath, JSON.stringify(npmPackageData, null, 2) + '\n');
          console.log(`✅ Updated package-npm.json: ${newVersion}`);
        }
      }
      
      writePackageJson(packageDir, packageData);
      
      const displayName = packageDir === PROJECT_ROOT ? 'demo-microfrontends' : packageData.name;
      console.log(`✅ ${displayName}: ${oldVersion} → ${newVersion}`);
      updated++;
      
    } catch (error) {
      console.error(`❌ Failed to update ${packageDir}:`, error.message);
      failed++;
    }
  }
  
  console.log(`\n📊 Summary: ${updated} updated, ${failed} failed`);
  return { updated, failed };
}

function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  const versionType = args[1] || 'patch';
  
  if (command === 'bump') {
    const currentVersion = getCurrentVersion();
    const newVersion = incrementVersion(currentVersion, versionType);
    
    console.log(`🚀 Bumping version from ${currentVersion} to ${newVersion} (${versionType})`);
    
    const result = updateAllVersions(newVersion);
    
    if (result.failed === 0) {
      console.log(`\n🎉 All packages successfully updated to ${newVersion}!`);
      process.exit(0);
    } else {
      console.log(`\n⚠️  Some packages failed to update. Check the errors above.`);
      process.exit(1);
    }
    
  } else if (command === 'set') {
    const targetVersion = args[1];
    
    if (!targetVersion || !/^\d+\.\d+\.\d+$/.test(targetVersion)) {
      console.error('❌ Please provide a valid version (e.g., 1.2.3)');
      process.exit(1);
    }
    
    console.log(`🎯 Setting all packages to version ${targetVersion}`);
    
    const result = updateAllVersions(targetVersion);
    
    if (result.failed === 0) {
      console.log(`\n🎉 All packages successfully set to ${targetVersion}!`);
      process.exit(0);
    } else {
      console.log(`\n⚠️  Some packages failed to update. Check the errors above.`);
      process.exit(1);
    }
    
  } else if (command === 'current') {
    const currentVersion = getCurrentVersion();
    console.log(`📋 Current version: ${currentVersion}`);
    
    // Show all package versions
    console.log('\n📦 Package versions:');
    for (const packageDir of PACKAGES) {
      const packageData = readPackageJson(packageDir);
      if (packageData) {
        const displayName = packageDir === PROJECT_ROOT ? 'demo-microfrontends' : packageData.name;
        console.log(`  ${displayName}: ${packageData.version}`);
      }
    }
    
  } else if (command === 'clean') {
    console.log('🧹 Cleaning _trigger fields from all packages...');
    
    let cleaned = 0;
    for (const packageDir of PACKAGES) {
      const packageData = readPackageJson(packageDir);
      if (packageData && packageData._trigger) {
        delete packageData._trigger;
        writePackageJson(packageDir, packageData);
        console.log(`✅ Cleaned ${packageDir === PROJECT_ROOT ? 'demo-microfrontends' : packageData.name}`);
        cleaned++;
      }
    }
    
    console.log(`\n📊 Cleaned ${cleaned} packages`);
    
  } else if (command === 'reset') {
    const resetVersion = args[1] || '0.1.0';
    
    console.log(`🔄 Resetting all packages to version ${resetVersion}`);
    
    const result = updateAllVersions(resetVersion);
    
    if (result.failed === 0) {
      console.log(`\n🎉 All packages successfully reset to ${resetVersion}!`);
      process.exit(0);
    } else {
      console.log(`\n⚠️  Some packages failed to reset. Check the errors above.`);
      process.exit(1);
    }
    
  } else {
    console.log(`
📦 Version Manager for Demo Microfrontends

Usage:
  node version-manager.js bump [patch|minor|major]  - Increment version for all packages
  node version-manager.js set <version>             - Set specific version for all packages
  node version-manager.js reset [version]           - Reset all packages to base version (default: 0.1.0)
  node version-manager.js current                   - Show current versions
  node version-manager.js clean                     - Remove _trigger fields

Examples:
  node version-manager.js bump patch               - 0.1.0 → 0.1.1
  node version-manager.js bump minor               - 0.1.0 → 0.2.0
  node version-manager.js bump major               - 0.1.0 → 1.0.0
  node version-manager.js set 1.2.3                - Set all to 1.2.3
  node version-manager.js reset                    - Reset all to 0.1.0
  node version-manager.js reset 1.0.0              - Reset all to 1.0.0
  node version-manager.js current                  - Show all versions
  node version-manager.js clean                    - Clean _trigger fields
`);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { updateAllVersions, incrementVersion, getCurrentVersion };