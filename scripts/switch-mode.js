#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Detect if running in CI/production environment
function isProductionEnvironment() {
  return process.env.CI === 'true' || 
         process.env.NODE_ENV === 'production' || 
         process.env.GITHUB_ACTIONS === 'true';
}

// Get appropriate npm command based on environment
function getNpmInstallCommand() {
  return isProductionEnvironment() ? 'npm ci' : 'npm install';
}

const mode = process.argv[2];
const rootDir = path.join(__dirname, '..', 'single-spa-root');
const sharedDir = path.join(__dirname, '..', 'shared');
const packageJsonPath = path.join(rootDir, 'package.json');
const packageNpmPath = path.join(rootDir, 'package-npm.json');
const packageNexusPath = path.join(rootDir, 'package-nexus.json');
const packageGithubPath = path.join(rootDir, 'package-github.json');
const packageAwsPath = path.join(rootDir, 'package-aws.json');
const packageLocalPath = path.join(rootDir, 'package-local.json');

// Shared folder paths
const sharedPackageJsonPath = path.join(sharedDir, 'package.json');
const sharedPackageNpmPath = path.join(sharedDir, 'package-npm.json');
const sharedPackageNexusPath = path.join(sharedDir, 'package-nexus.json');
const sharedPackageGithubPath = path.join(sharedDir, 'package-github.json');
const sharedPackageAwsPath = path.join(sharedDir, 'package-aws.json');
const sharedPackageLocalPath = path.join(sharedDir, 'package-local.json');

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
  
  // Handle shared folder
  if (fs.existsSync(sharedPackageJsonPath)) {
    fs.copyFileSync(sharedPackageJsonPath, sharedPackageLocalPath);
    console.log('💾 Backed up shared/package.json as package-local.json');
  }
  if (fs.existsSync(sharedPackageNpmPath)) {
    fs.copyFileSync(sharedPackageNpmPath, sharedPackageJsonPath);
    console.log('📦 Copied shared/package-npm.json to package.json');
  }
  
  // Install NPM dependencies (skip in GitHub Actions)
  if (!process.env.GITHUB_ACTIONS) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing NPM dependencies with ${installCmd}...`);
    try {
      execSync(installCmd, { cwd: rootDir, stdio: 'inherit' });
      if (fs.existsSync(sharedDir)) {
        execSync(installCmd, { cwd: sharedDir, stdio: 'inherit' });
      }
    } catch (error) {
      console.error('❌ Failed to install NPM dependencies');
      console.error('💡 Make sure packages are published first: npm run publish:patch');
      process.exit(1);
    }
  } else {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  }
  console.log('✅ NPM mode activated');
  console.log('🌐 Use: npm run serve:npm or http://localhost:8080?mode=npm');
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
  
  // Handle shared folder
  if (fs.existsSync(sharedPackageLocalPath)) {
    fs.copyFileSync(sharedPackageLocalPath, sharedPackageJsonPath);
    console.log('📦 Restored shared/package-local.json to package.json');
  }
  
  // Install local dependencies (skip in GitHub Actions)
  if (!process.env.GITHUB_ACTIONS) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing local dependencies with ${installCmd}...`);
    try {
      execSync(installCmd, { cwd: rootDir, stdio: 'inherit' });
      if (fs.existsSync(sharedDir)) {
        execSync(installCmd, { cwd: sharedDir, stdio: 'inherit' });
      }
    } catch (error) {
      console.error('❌ Failed to install local dependencies');
      process.exit(1);
    }
  } else {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  }
  console.log('✅ Local mode activated');
  console.log('🌐 Use: npm run serve:local:dev or http://localhost:8080');
}

function switchToGitHubMode() {
  console.log('🔄 Switching to GitHub mode...');
  
  // Backup current package.json as package-local.json
  if (fs.existsSync(packageJsonPath)) {
    fs.copyFileSync(packageJsonPath, packageLocalPath);
    console.log('💾 Backed up current package.json as package-local.json');
  }
  
  // Copy package-github.json to package.json
  if (fs.existsSync(packageGithubPath)) {
    fs.copyFileSync(packageGithubPath, packageJsonPath);
    console.log('📦 Copied package-github.json to package.json');
  } else {
    console.error('❌ package-github.json not found');
    process.exit(1);
  }
  
  // Handle shared folder
  if (fs.existsSync(sharedPackageJsonPath)) {
    fs.copyFileSync(sharedPackageJsonPath, sharedPackageLocalPath);
    console.log('💾 Backed up shared/package.json as package-local.json');
  }
  if (fs.existsSync(sharedPackageGithubPath)) {
    fs.copyFileSync(sharedPackageGithubPath, sharedPackageJsonPath);
    console.log('📦 Copied shared/package-github.json to package.json');
  }
  
  // Install GitHub dependencies (skip in GitHub Actions)
  if (!process.env.GITHUB_ACTIONS) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing GitHub dependencies with ${installCmd}...`);
    try {
      execSync(installCmd, { cwd: rootDir, stdio: 'inherit' });
      if (fs.existsSync(sharedDir)) {
        execSync(installCmd, { cwd: sharedDir, stdio: 'inherit' });
      }
    } catch (error) {
      console.error('❌ Failed to install GitHub dependencies');
      process.exit(1);
    }
  } else {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  }
  console.log('✅ GitHub mode activated');
  console.log('📋 GitHub mode configuration:');
  console.log('  - GITHUB_TOKEN required in .env file');
  console.log('  - GITHUB_USERNAME optional (defaults to cesarchamal)');
  console.log('🌐 Use: npm run serve:github or http://localhost:8080?mode=github');
  console.log('📖 Dev mode: Reads from existing GitHub Pages');
  console.log('🚀 Prod mode: Creates repos and deploys everything');
}

function switchToNexusMode() {
  console.log('🔄 Switching to Nexus mode...');
  
  // Backup current package.json as package-local.json
  if (fs.existsSync(packageJsonPath)) {
    fs.copyFileSync(packageJsonPath, packageLocalPath);
    console.log('💾 Backed up current package.json as package-local.json');
  }
  
  // Copy package-nexus.json to package.json
  if (fs.existsSync(packageNexusPath)) {
    fs.copyFileSync(packageNexusPath, packageJsonPath);
    console.log('📦 Copied package-nexus.json to package.json');
  } else {
    console.error('❌ package-nexus.json not found');
    process.exit(1);
  }
  
  // Handle shared folder
  if (fs.existsSync(sharedPackageJsonPath)) {
    fs.copyFileSync(sharedPackageJsonPath, sharedPackageLocalPath);
    console.log('💾 Backed up shared/package.json as package-local.json');
  }
  if (fs.existsSync(sharedPackageNexusPath)) {
    fs.copyFileSync(sharedPackageNexusPath, sharedPackageJsonPath);
    console.log('📦 Copied shared/package-nexus.json to package.json');
  }
  
  // Install Nexus dependencies (skip in GitHub Actions)
  if (!process.env.GITHUB_ACTIONS) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing Nexus dependencies with ${installCmd}...`);
    try {
      execSync(installCmd, { cwd: rootDir, stdio: 'inherit' });
      if (fs.existsSync(sharedDir)) {
        execSync(installCmd, { cwd: sharedDir, stdio: 'inherit' });
      }
    } catch (error) {
      console.error('❌ Failed to install Nexus dependencies');
      console.error('💡 Make sure packages are published first: npm run publish:nexus:patch');
      process.exit(1);
    }
  } else {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  }
  console.log('✅ Nexus mode activated');
  console.log('🌐 Use: npm run serve:nexus or http://localhost:8080?mode=nexus');
}

function switchToAwsMode() {
  console.log('🔄 Switching to AWS mode...');
  
  // Backup current package.json as package-local.json
  if (fs.existsSync(packageJsonPath)) {
    fs.copyFileSync(packageJsonPath, packageLocalPath);
    console.log('💾 Backed up current package.json as package-local.json');
  }
  
  // Copy package-aws.json to package.json
  if (fs.existsSync(packageAwsPath)) {
    fs.copyFileSync(packageAwsPath, packageJsonPath);
    console.log('📦 Copied package-aws.json to package.json');
  } else {
    console.error('❌ package-aws.json not found');
    process.exit(1);
  }
  
  // Handle shared folder
  if (fs.existsSync(sharedPackageJsonPath)) {
    fs.copyFileSync(sharedPackageJsonPath, sharedPackageLocalPath);
    console.log('💾 Backed up shared/package.json as package-local.json');
  }
  if (fs.existsSync(sharedPackageAwsPath)) {
    fs.copyFileSync(sharedPackageAwsPath, sharedPackageJsonPath);
    console.log('📦 Copied shared/package-aws.json to package.json');
  }
  
  // Install AWS dependencies (skip in GitHub Actions)
  if (!process.env.GITHUB_ACTIONS) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing AWS dependencies with ${installCmd}...`);
    try {
      execSync(installCmd, { cwd: rootDir, stdio: 'inherit' });
      if (fs.existsSync(sharedDir)) {
        execSync(installCmd, { cwd: sharedDir, stdio: 'inherit' });
      }
    } catch (error) {
      console.error('❌ Failed to install AWS dependencies');
      process.exit(1);
    }
  } else {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  }
  console.log('✅ AWS mode activated');
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
  node switch-mode.js nexus   - Switch to Nexus mode (uses Nexus registry)
  node switch-mode.js local   - Switch to Local mode (uses local development)
  node switch-mode.js github  - Switch to GitHub mode (uses GitHub Pages)
  node switch-mode.js aws     - Switch to AWS mode (uses S3 import map)
  node switch-mode.js status  - Show current mode status

NPM Scripts:
  npm run mode:npm           - Switch to NPM mode
  npm run mode:nexus         - Switch to Nexus mode
  npm run mode:local         - Switch to Local mode
  npm run mode:github        - Switch to GitHub mode
  npm run mode:aws           - Switch to AWS mode
  npm run serve:npm          - Switch to NPM mode and start server
  npm run serve:nexus        - Switch to Nexus mode and start server
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
    case 'nexus':
      switchToNexusMode();
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
      console.error('❌ Invalid mode. Use: npm, nexus, local, github, aws, or status');
      process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { switchToNpmMode, switchToLocalMode, showStatus };