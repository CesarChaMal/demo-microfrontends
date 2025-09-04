#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const mode = process.argv[2];
const rootDir = path.join(__dirname, 'single-spa-root');
const packageJsonPath = path.join(rootDir, 'package.json');
const packageNpmPath = path.join(rootDir, 'package-npm.json');
const packageLocalPath = path.join(rootDir, 'package-local.json');

function switchToNpmMode() {
  console.log('🔄 Switching to NPM mode...');
  
  // Backup current package.json as package-local.json
  if (fs.existsSync(packageJsonPath)) {
    fs.copyFileSync(packageJsonPath, packageLocalPath);
    console.log('💾 Backed up current package.json as package-local.json');
  }
  
  // Copy package-npm.json to package.json
  if (fs.existsSync(packageNpmPath)) {
    fs.copyFileSync(packageNpmPath, packageJsonPath);
    console.log('📦 Copied package-npm.json to package.json');
  } else {
    console.error('❌ package-npm.json not found');
    process.exit(1);
  }
  
  // Install NPM dependencies
  console.log('📥 Installing NPM dependencies...');
  try {
    execSync('npm install', { cwd: rootDir, stdio: 'inherit' });
    console.log('✅ NPM mode activated');
    console.log('🌐 Use: npm run serve:npm or http://localhost:8080?mode=npm');
  } catch (error) {
    console.error('❌ Failed to install NPM dependencies');
    console.error('💡 Make sure packages are published first: npm run publish:patch');
    process.exit(1);
  }
}

function switchToLocalMode() {
  console.log('🔄 Switching to Local mode...');
  
  // Restore package-local.json to package.json
  if (fs.existsSync(packageLocalPath)) {
    fs.copyFileSync(packageLocalPath, packageJsonPath);
    console.log('📦 Restored package-local.json to package.json');
  } else {
    console.log('⚠️  No backup found, using git checkout...');
    try {
      execSync('git checkout package.json', { cwd: rootDir, stdio: 'inherit' });
    } catch (error) {
      console.log('⚠️  Git checkout failed, keeping current package.json');
    }
  }
  
  // Install local dependencies
  console.log('📥 Installing local dependencies...');
  try {
    execSync('npm install', { cwd: rootDir, stdio: 'inherit' });
    console.log('✅ Local mode activated');
    console.log('🌐 Use: npm run serve:local:dev or http://localhost:8080');
  } catch (error) {
    console.error('❌ Failed to install local dependencies');
    process.exit(1);
  }
}

function switchToGitHubMode() {
  console.log('🔄 Switching to GitHub mode...');
  
  // Use local package.json (no special dependencies needed)
  switchToLocalMode();
  
  console.log('📋 GitHub mode configuration:');
  console.log('  - GITHUB_TOKEN required in .env file');
  console.log('  - GITHUB_USERNAME optional (defaults to cesarchamal)');
  console.log('🌐 Use: npm run serve:github or http://localhost:8080?mode=github');
  console.log('📖 Dev mode: Reads from existing GitHub Pages');
  console.log('🚀 Prod mode: Creates repos and deploys everything');
}

function switchToAwsMode() {
  console.log('🔄 Switching to AWS mode...');
  
  // Use local package.json (no special dependencies needed)
  switchToLocalMode();
  
  console.log('📋 AWS mode configuration:');
  console.log('  - S3_BUCKET required in .env file');
  console.log('  - AWS_REGION required in .env file');
  console.log('  - ORG_NAME required in .env file');
  console.log('🌐 Use: npm run serve:aws or http://localhost:8080?mode=aws');
  console.log('☁️  Loads microfrontends from S3 import map');
}

function showStatus() {
  console.log('📋 Current Mode Status:');
  
  if (!fs.existsSync(packageJsonPath)) {
    console.log('❌ No package.json found');
    return;
  }
  
  const packageData = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  const hasNpmDeps = packageData.dependencies && 
    Object.keys(packageData.dependencies).some(dep => dep.startsWith('@cesarchamal/single-spa-'));
  
  if (hasNpmDeps) {
    console.log('📦 Current mode: NPM');
    console.log('🌐 Start with: npm run serve:npm');
    console.log('🔄 Switch to local: npm run mode:local');
  } else {
    console.log('🏠 Current mode: LOCAL');
    console.log('🌐 Start with: npm run serve:local:dev');
    console.log('🔄 Switch to NPM: npm run mode:npm');
  }
  
  console.log('');
  console.log('📦 Available NPM packages:');
  if (fs.existsSync(packageNpmPath)) {
    const npmPackageData = JSON.parse(fs.readFileSync(packageNpmPath, 'utf8'));
    if (npmPackageData.dependencies) {
      Object.keys(npmPackageData.dependencies)
        .filter(dep => dep.startsWith('@cesarchamal/single-spa-'))
        .forEach(dep => {
          console.log(`  - ${dep}@${npmPackageData.dependencies[dep]}`);
        });
    }
  }
}

function main() {
  if (!mode) {
    console.log(`
🔄 Mode Switcher for Demo Microfrontends

Usage:
  node switch-mode.js npm     - Switch to NPM mode (uses published packages)
  node switch-mode.js local   - Switch to Local mode (uses local development)
  node switch-mode.js github  - Switch to GitHub mode (uses GitHub Pages)
  node switch-mode.js aws     - Switch to AWS mode (uses S3 import map)
  node switch-mode.js status  - Show current mode status

NPM Scripts:
  npm run mode:npm           - Switch to NPM mode
  npm run mode:local         - Switch to Local mode
  npm run mode:github        - Switch to GitHub mode
  npm run mode:aws           - Switch to AWS mode
  npm run serve:npm          - Switch to NPM mode and start server
  npm run serve:github       - Start GitHub mode server
  npm run serve:aws          - Start AWS mode server
`);
    showStatus();
    return;
  }

  switch (mode.toLowerCase()) {
    case 'npm':
      switchToNpmMode();
      break;
    case 'local':
      switchToLocalMode();
      break;
    case 'github':
      switchToGitHubMode();
      break;
    case 'aws':
      switchToAwsMode();
      break;
    case 'status':
      showStatus();
      break;
    default:
      console.error('❌ Invalid mode. Use: npm, local, github, aws, or status');
      process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { switchToNpmMode, switchToLocalMode, showStatus };