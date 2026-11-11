#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { ensureInstalledSync } = require('./install-if-changed');

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

// Installs single-spa-root and shared where their dependencies changed since their last
// successful install (scripts/install-if-changed.js). Unchanged folders are skipped.
function installDependencies() {
  const options = { ci: isProductionEnvironment() };
  ensureInstalledSync(rootDir, options);
  if (fs.existsSync(sharedDir)) {
    ensureInstalledSync(sharedDir, options);
  }
}

const mode = process.argv[2];
const rootDir = path.join(__dirname, '..', 'single-spa-root');
const sharedDir = path.join(__dirname, '..', 'shared');
const projectRoot = path.join(__dirname, '..');
const packageJsonPath = path.join(rootDir, 'package.json');
const packageNpmPath = path.join(rootDir, 'package-npm.json');
const packageNexusPath = path.join(rootDir, 'package-nexus.json');
const packageGithubPath = path.join(rootDir, 'package-github.json');
const packageAwsPath = path.join(rootDir, 'package-aws.json');
const packageLocalPath = path.join(rootDir, 'package-local.json');

// NPM registry config paths
const npmrcPath = path.join(projectRoot, '.npmrc');
const npmrcNpmPath = path.join(projectRoot, '.npmrc.npm');
const npmrcNexusPath = path.join(projectRoot, '.npmrc.nexus');
const npmrcLocalPath = path.join(projectRoot, '.npmrc.local');

// The local-mode backups (package-local.json, shared/package-local.json, .npmrc.local) are
// taken only while single-spa-root/package.json is the local or npm variant. Those are the only
// variants with the @cesarchamal/single-spa-* dependencies, and they are identical by design, so
// a version bump made in npm mode still reaches package-local.json. Before, every switch away
// from local overwrote the backups: a second aws run (run.sh switches to aws, then deploy:aws:*
// switches again) replaced the local backup with aws content. Only the dependencies are checked,
// so tools that rewrite "version" in place (fix-npm-deps.sh, version-manager.js) don't matter.
function readJsonOrNull(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (error) {
    return null;
  }
}

function holdsLocalDependencies() {
  const pkg = readJsonOrNull(packageJsonPath);
  const dependencies = (pkg && pkg.dependencies) || {};
  if (Object.keys(dependencies).some((name) => name.startsWith('@cesarchamal/single-spa-'))) return true;
  console.log('⏭️  package.json is not the local or npm variant (no @cesarchamal/single-spa-* dependencies): the local-mode backups stay as they are');
  return false;
}

// Shared folder paths
const sharedPackageJsonPath = path.join(sharedDir, 'package.json');
const sharedPackageNpmPath = path.join(sharedDir, 'package-npm.json');
const sharedPackageNexusPath = path.join(sharedDir, 'package-nexus.json');
const sharedPackageGithubPath = path.join(sharedDir, 'package-github.json');
const sharedPackageAwsPath = path.join(sharedDir, 'package-aws.json');
const sharedPackageLocalPath = path.join(sharedDir, 'package-local.json');

function switchToNpmMode() {
  console.log('🔄 Switching to NPM mode...');
  const backUpLocal = holdsLocalDependencies();
  
  // Backup current .npmrc as .npmrc.local
  if (backUpLocal && fs.existsSync(npmrcPath)) {
    fs.copyFileSync(npmrcPath, npmrcLocalPath);
    console.log('💾 Backed up current .npmrc as .npmrc.local');
  }
  
  // Copy .npmrc.npm to .npmrc
  if (fs.existsSync(npmrcNpmPath)) {
    fs.copyFileSync(npmrcNpmPath, npmrcPath);
    console.log('📦 Copied .npmrc.npm to .npmrc');
  }
  
  // Backup current package.json as package-local.json
  if (backUpLocal && fs.existsSync(packageJsonPath)) {
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
  if (backUpLocal && fs.existsSync(sharedPackageJsonPath)) {
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
    console.log(`📥 Installing NPM dependencies with ${installCmd} where they changed...`);
    try {
      installDependencies();
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
  
  // Debug: Check file existence
  console.log('🔍 Debug: npmrcPath exists:', fs.existsSync(npmrcPath));
  console.log('🔍 Debug: npmrcLocalPath exists:', fs.existsSync(npmrcLocalPath));
  console.log('🔍 Debug: npmrcNpmPath exists:', fs.existsSync(npmrcNpmPath));
  
  // For local mode, we want to use NPM registry, so copy .npmrc.npm to .npmrc
  if (fs.existsSync(npmrcNpmPath)) {
    fs.copyFileSync(npmrcNpmPath, npmrcPath);
    console.log('📦 Copied .npmrc.npm to .npmrc for local mode');
  } else {
    console.log('⚠️  No .npmrc.npm found, using git checkout...');
    try {
      execSync('git checkout .npmrc', { cwd: projectRoot, stdio: 'inherit' });
    } catch (error) {
      console.log('⚠️  Git checkout failed, keeping current .npmrc');
    }
  }
  
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
  
  // Install local dependencies (skip in GitHub Actions or when SKIP_INSTALL is set)
  if (!process.env.GITHUB_ACTIONS && !process.env.SKIP_INSTALL) {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing local dependencies with ${installCmd} where they changed...`);
    try {
      installDependencies();
    } catch (error) {
      console.error('❌ Failed to install local dependencies');
      process.exit(1);
    }
  } else {
    if (process.env.SKIP_INSTALL) {
      console.log('⏭️ Skipping npm install (SKIP_INSTALL=true)');
    } else {
      console.log('⏭️ Skipping npm install in GitHub Actions');
    }
  }
  console.log('✅ Local mode activated');
  console.log('🌐 Use: npm run serve:local:dev or http://localhost:8080');
}

function switchToGitHubMode() {
  console.log('🔄 Switching to GitHub mode...');
  const backUpLocal = holdsLocalDependencies();
  
  // GitHub mode uses NPM registry, so ensure .npmrc is set correctly
  if (backUpLocal && fs.existsSync(npmrcPath)) {
    fs.copyFileSync(npmrcPath, npmrcLocalPath);
    console.log('💾 Backed up current .npmrc as .npmrc.local');
  }
  
  if (fs.existsSync(npmrcNpmPath)) {
    fs.copyFileSync(npmrcNpmPath, npmrcPath);
    console.log('📦 Copied .npmrc.npm to .npmrc (GitHub uses NPM registry)');
  }
  
  // Backup current package.json as package-local.json
  if (backUpLocal && fs.existsSync(packageJsonPath)) {
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
  if (backUpLocal && fs.existsSync(sharedPackageJsonPath)) {
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
    console.log(`📥 Installing GitHub dependencies with ${installCmd} where they changed...`);
    try {
      installDependencies();
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
  const backUpLocal = holdsLocalDependencies();
  
  // Backup current .npmrc as .npmrc.local
  if (backUpLocal && fs.existsSync(npmrcPath)) {
    fs.copyFileSync(npmrcPath, npmrcLocalPath);
    console.log('💾 Backed up current .npmrc as .npmrc.local');
  }
  
  // Copy .npmrc.nexus to .npmrc
  if (fs.existsSync(npmrcNexusPath)) {
    fs.copyFileSync(npmrcNexusPath, npmrcPath);
    console.log('📦 Copied .npmrc.nexus to .npmrc');
  }
  
  // Backup current package.json as package-local.json
  if (backUpLocal && fs.existsSync(packageJsonPath)) {
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
  if (backUpLocal && fs.existsSync(sharedPackageJsonPath)) {
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
    console.log(`📥 Installing Nexus dependencies with ${installCmd} where they changed...`);
    try {
      installDependencies();
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
  const backUpLocal = holdsLocalDependencies();
  
  // AWS mode uses NPM registry, so ensure .npmrc is set correctly
  if (backUpLocal && fs.existsSync(npmrcPath)) {
    fs.copyFileSync(npmrcPath, npmrcLocalPath);
    console.log('💾 Backed up current .npmrc as .npmrc.local');
  }
  
  if (fs.existsSync(npmrcNpmPath)) {
    fs.copyFileSync(npmrcNpmPath, npmrcPath);
    console.log('📦 Copied .npmrc.npm to .npmrc (AWS uses NPM registry)');
  }
  
  // Backup current package.json as package-local.json
  if (backUpLocal && fs.existsSync(packageJsonPath)) {
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
  if (backUpLocal && fs.existsSync(sharedPackageJsonPath)) {
    fs.copyFileSync(sharedPackageJsonPath, sharedPackageLocalPath);
    console.log('💾 Backed up shared/package.json as package-local.json');
  }
  if (fs.existsSync(sharedPackageAwsPath)) {
    fs.copyFileSync(sharedPackageAwsPath, sharedPackageJsonPath);
    console.log('📦 Copied shared/package-aws.json to package.json');
  }
  
  // Install AWS dependencies. Skipped in GitHub Actions, and when SKIP_INSTALL=true
  // while the dependencies are already installed: run.sh passes it for its early mode
  // switch (deploy:aws:* switches again and installs right before the root build) and
  // serve:aws passes it too. The aws dependencies are a subset of every other mode's
  // set, so any existing install covers them; an empty tree still installs.
  const depsInstalled = fs.existsSync(path.join(rootDir, 'node_modules')) &&
    (!fs.existsSync(sharedDir) || fs.existsSync(path.join(sharedDir, 'node_modules')));
  const skipInstall = String(process.env.SKIP_INSTALL || '').trim() === 'true' && depsInstalled;
  if (process.env.GITHUB_ACTIONS) {
    console.log('⏭️ Skipping npm install in GitHub Actions');
  } else if (skipInstall) {
    console.log('⏭️ Skipping npm install (SKIP_INSTALL=true, dependencies already installed)');
  } else {
    const installCmd = getNpmInstallCommand();
    console.log(`📥 Installing AWS dependencies with ${installCmd} where they changed...`);
    try {
      installDependencies();
    } catch (error) {
      console.error('❌ Failed to install AWS dependencies');
      process.exit(1);
    }
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