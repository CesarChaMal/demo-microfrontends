#!/bin/bash
echo "📦 Downloading offline dependencies..."

mkdir -p single-spa-root/dist/lib
cd single-spa-root/dist/lib

echo "Downloading SystemJS..."
curl -L -o systemjs@6.14.1-system.min.js https://cdn.jsdelivr.net/npm/systemjs@6.14.1/dist/system.min.js
mkdir -p systemjs@6.14.1/dist
mv systemjs@6.14.1-system.min.js systemjs@6.14.1/dist/system.min.js

echo "Downloading Single-SPA..."
curl -L -o single-spa@5.9.0-single-spa.min.js https://cdn.jsdelivr.net/npm/single-spa@5.9.0/lib/system/single-spa.min.js
mkdir -p single-spa@5.9.0/lib/system
mv single-spa@5.9.0-single-spa.min.js single-spa@5.9.0/lib/system/single-spa.min.js

echo "Downloading Bootstrap CSS..."
curl -L -o bootstrap@4.6.0-bootstrap.min.css https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css
mkdir -p bootstrap@4.6.0/dist/css
mv bootstrap@4.6.0-bootstrap.min.css bootstrap@4.6.0/dist/css/bootstrap.min.css

echo "Downloading Bootstrap JS..."
curl -L -o bootstrap@4.6.0-bootstrap.bundle.min.js https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js
mkdir -p bootstrap@4.6.0/dist/js
mv bootstrap@4.6.0-bootstrap.bundle.min.js bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js

echo "Downloading Bootstrap Vue CSS..."
curl -L -o bootstrap-vue@2.2.2-bootstrap-vue.css https://cdn.jsdelivr.net/npm/bootstrap-vue@2.2.2/dist/bootstrap-vue.css
mkdir -p bootstrap-vue@2.2.2/dist
mv bootstrap-vue@2.2.2-bootstrap-vue.css bootstrap-vue@2.2.2/dist/bootstrap-vue.css

echo "Downloading Bootstrap Vue JS..."
curl -L -o bootstrap-vue@2.2.2-bootstrap-vue.min.js https://cdn.jsdelivr.net/npm/bootstrap-vue@2.2.2/dist/bootstrap-vue.min.js
mv bootstrap-vue@2.2.2-bootstrap-vue.min.js bootstrap-vue@2.2.2/dist/bootstrap-vue.min.js

echo "Downloading jQuery..."
curl -L -o jquery@3.6.0-jquery.min.js https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js
mkdir -p jquery@3.6.0/dist
mv jquery@3.6.0-jquery.min.js jquery@3.6.0/dist/jquery.min.js

echo "Downloading Vue..."
curl -L -o vue@2.6.11-vue.js https://cdn.jsdelivr.net/npm/vue@2.6.11/dist/vue.js
mkdir -p vue@2.6.11/dist
mv vue@2.6.11-vue.js vue@2.6.11/dist/vue.js

echo "Downloading Vue Router..."
curl -L -o vue-router@3.1.4-vue-router.min.js https://cdn.jsdelivr.net/npm/vue-router@3.1.4/dist/vue-router.min.js
mkdir -p vue-router@3.1.4/dist
mv vue-router@3.1.4-vue-router.min.js vue-router@3.1.4/dist/vue-router.min.js

echo "Downloading Single-SPA Vue..."
curl -L -o single-spa-vue@1.7.0-single-spa-vue.min.js https://cdn.jsdelivr.net/npm/single-spa-vue@1.7.0/lib/single-spa-vue.min.js
mkdir -p single-spa-vue@1.7.0/lib
mv single-spa-vue@1.7.0-single-spa-vue.min.js single-spa-vue@1.7.0/lib/single-spa-vue.min.js

cd ../../..
echo "✅ Offline dependencies downloaded successfully!"
echo "🚀 Run with: OFFLINE=true npm run serve:root"