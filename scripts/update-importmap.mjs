// Note that this file requires node@13.2.0 or higher (or the --experimental-modules flag)
import fs from "fs";
import path from "path";
import https from "https";

const importMapFilePath = path.resolve(process.cwd(), "importmap.json");
let importMap;

// Get app configuration from environment variables
const appName = process.env.APP_NAME;
const bundleFile = process.env.BUNDLE_FILE;
const sharedDeps = process.env.SHARED_DEPS ? JSON.parse(process.env.SHARED_DEPS) : {};

if (!appName || !bundleFile) {
  throw new Error("APP_NAME and BUNDLE_FILE environment variables are required");
}

// Initialize import map with shared dependencies if file doesn't exist or is empty
try {
  importMap = JSON.parse(fs.readFileSync(importMapFilePath));
} catch (error) {
  importMap = { imports: {} };
}

// Ensure shared dependencies are always present
if (!importMap.imports) importMap.imports = {};
if (!importMap.imports["single-spa"]) {
  importMap.imports["single-spa"] = "https://cdn.jsdelivr.net/npm/single-spa@5.9.0/lib/system/single-spa.min.js";
}

// Add app-specific shared dependencies
Object.entries(sharedDeps).forEach(([key, value]) => {
  if (!importMap.imports[key]) {
    importMap.imports[key] = value;
  }
});

const s3Bucket = process.env.S3_BUCKET || 'single-spa-demo';
const awsRegion = process.env.AWS_REGION || 'eu-central-1';
const orgName = process.env.ORG_NAME || 'cesarchamal';
const commitSha = process.env.GIT_ACTIONS_COMMIT || process.env.GITHUB_SHA;
const url = `https://${s3Bucket}.s3-${awsRegion}.amazonaws.com/@${orgName}/${appName}/${commitSha}/${bundleFile}`;

https
  .get(url, res => {
    // HTTP redirects (301, 302, etc) not currently supported, but could be added
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (
        res.headers["content-type"] &&
        res.headers["content-type"].toLowerCase().trim() ===
          "application/javascript"
      ) {
        const moduleName = `@${orgName}/${appName}`;
        importMap.imports[moduleName] = url;
        fs.writeFileSync(importMapFilePath, JSON.stringify(importMap, null, 2));
        console.log(
          `Updated import map for module ${moduleName}. New url is ${url}.`
        );
      } else {
        urlNotDownloadable(
          url,
          Error(`Content-Type response header must be application/javascript`)
        );
      }
    } else {
      urlNotDownloadable(
        url,
        Error(`HTTP response status was ${res.statusCode}`)
      );
    }
  })
  .on("error", err => {
    urlNotDownloadable(url, err);
  });

function urlNotDownloadable(url, err) {
  throw Error(
    `Refusing to update import map - could not download javascript file at url ${url}. Error was '${err.message}'`
  );
}