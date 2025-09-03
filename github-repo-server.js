#!/usr/bin/env node

const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const app = express();
const PORT = 3001;

app.use(express.json());
app.use(express.static('single-spa-root/dist'));

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Load environment variables
require('dotenv').config();

// API endpoint to create all GitHub repositories and deploy them
app.post('/api/create-all-repos', (req, res) => {
  const { apps } = req.body;
  
  if (!apps || !Array.isArray(apps)) {
    return res.status(400).json({ error: 'Apps array is required' });
  }

  // Check for required environment variables
  if (!process.env.GITHUB_API_TOKEN) {
    return res.status(500).json({ 
      error: 'GITHUB_TOKEN not found in environment variables',
      message: 'Make sure GITHUB_TOKEN is set in .env file'
    });
  }

  console.log(`🔧 Creating and deploying ${apps.length} GitHub repositories...`);

  // Determine script extension based on platform
  const isWindows = process.platform === 'win32';
  const createScript = isWindows ? 'create-github-repo.bat' : './create-github-repo.sh';
  const deployScript = isWindows ? 'deploy-github.bat' : './deploy-github.sh';
  
  // Check if scripts exist
  if (!fs.existsSync(createScript)) {
    return res.status(500).json({ 
      error: `Script not found: ${createScript}`,
      message: 'Make sure create-github-repo script exists in the root directory'
    });
  }

  let completedApps = 0;
  let errors = [];

  // Process each app sequentially
  apps.forEach((app, index) => {
    setTimeout(() => {
      console.log(`📦 Processing ${app}...`);
      
      // First create the repository
      const createCommand = isWindows 
        ? `${createScript} "${app}"` 
        : `${createScript} "${app}"`;

      exec(createCommand, { cwd: __dirname }, (error, stdout, stderr) => {
        if (error && !error.message.includes('already exists')) {
          console.error(`Error creating repo ${app}:`, error.message);
          errors.push(`${app}: ${error.message}`);
        } else {
          console.log(`✅ Repository ${app} ready`);
        }

        // Then deploy the app to the repository
        if (fs.existsSync(deployScript)) {
          const deployCommand = isWindows 
            ? `${deployScript} "${app}"` 
            : `${deployScript} "${app}"`;

          exec(deployCommand, { cwd: __dirname }, (deployError, deployStdout) => {
            if (deployError) {
              console.error(`Error deploying ${app}:`, deployError.message);
              errors.push(`${app} deploy: ${deployError.message}`);
            } else {
              console.log(`🚀 ${app} deployed to GitHub Pages`);
            }

            completedApps++;
            if (completedApps === apps.length) {
              // All apps processed
              if (errors.length > 0) {
                res.status(207).json({ 
                  success: true,
                  message: `Processed ${apps.length} apps with ${errors.length} errors`,
                  errors: errors
                });
              } else {
                // Deploy root app after all microfrontends are done
                console.log('🏠 Deploying root application...');
                const rootDeployCommand = isWindows 
                  ? `${deployScript} "root"` 
                  : `${deployScript} "root"`;
                
                exec(rootDeployCommand, { cwd: __dirname }, (rootError) => {
                  if (rootError) {
                    console.error('Error deploying root app:', rootError.message);
                  } else {
                    console.log('✅ Root app deployed to GitHub Pages');
                  }
                  
                  res.json({ 
                    success: true, 
                    message: `All ${apps.length} repositories + root app deployed successfully`
                  });
                });
              }
            }
          });
        } else {
          completedApps++;
          if (completedApps === apps.length) {
            res.json({ 
              success: true, 
              message: `All ${apps.length} repositories created (deployment script not found)`
            });
          }
        }
      });
    }, index * 2000); // Stagger requests by 2 seconds to avoid rate limiting
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'GitHub repo creation server is running' });
});

app.listen(PORT, () => {
  console.log(`🚀 GitHub repo creation server running on http://localhost:${PORT}`);
  console.log(`📡 API endpoint: http://localhost:${PORT}/api/create-repo`);
});