@echo off
echo 📦 Downloading offline dependencies...

mkdir single-spa-root\dist\lib 2>nul
cd single-spa-root\dist\lib

echo Downloading SystemJS...
curl -L -o systemjs@6.14.1-system.min.js https://cdn.jsdelivr.net/npm/systemjs@6.14.1/dist/system.min.js
mkdir systemjs@6.14.1\dist 2>nul
move systemjs@6.14.1-system.min.js systemjs@6.14.1\dist\system.min.js

echo Downloading Single-SPA...
curl -L -o single-spa@5.9.0-single-spa.min.js https://cdn.jsdelivr.net/npm/single-spa@5.9.0/lib/system/single-spa.min.js
mkdir single-spa@5.9.0\lib\system 2>nul
move single-spa@5.9.0-single-spa.min.js single-spa@5.9.0\lib\system\single-spa.min.js

echo Downloading Bootstrap CSS...
curl -L -o bootstrap@4.6.0-bootstrap.min.css https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css
mkdir bootstrap@4.6.0\dist\css 2>nul
move bootstrap@4.6.0-bootstrap.min.css bootstrap@4.6.0\dist\css\bootstrap.min.css

echo Downloading Bootstrap JS...
curl -L -o bootstrap@4.6.0-bootstrap.bundle.min.js https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js
mkdir bootstrap@4.6.0\dist\js 2>nul
move bootstrap@4.6.0-bootstrap.bundle.min.js bootstrap@4.6.0\dist\js\bootstrap.bundle.min.js

echo Downloading Bootstrap Vue CSS...
curl -L -o bootstrap-vue@2.2.2-bootstrap-vue.css https://cdn.jsdelivr.net/npm/bootstrap-vue@2.2.2/dist/bootstrap-vue.css
mkdir bootstrap-vue@2.2.2\dist 2>nul
move bootstrap-vue@2.2.2-bootstrap-vue.css bootstrap-vue@2.2.2\dist\bootstrap-vue.css

echo Downloading Bootstrap Vue JS...
curl -L -o bootstrap-vue@2.2.2-bootstrap-vue.min.js https://cdn.jsdelivr.net/npm/bootstrap-vue@2.2.2/dist/bootstrap-vue.min.js
move bootstrap-vue@2.2.2-bootstrap-vue.min.js bootstrap-vue@2.2.2\dist\bootstrap-vue.min.js

echo Downloading jQuery...
curl -L -o jquery@3.6.0-jquery.min.js https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js
mkdir jquery@3.6.0\dist 2>nul
move jquery@3.6.0-jquery.min.js jquery@3.6.0\dist\jquery.min.js

echo Downloading Vue...
curl -L -o vue@2.6.11-vue.js https://cdn.jsdelivr.net/npm/vue@2.6.11/dist/vue.js
mkdir vue@2.6.11\dist 2>nul
move vue@2.6.11-vue.js vue@2.6.11\dist\vue.js

echo Downloading Vue Router...
curl -L -o vue-router@3.1.4-vue-router.min.js https://cdn.jsdelivr.net/npm/vue-router@3.1.4/dist/vue-router.min.js
mkdir vue-router@3.1.4\dist 2>nul
move vue-router@3.1.4-vue-router.min.js vue-router@3.1.4\dist\vue-router.min.js

echo Downloading Single-SPA Vue...
curl -L -o single-spa-vue@1.7.0-single-spa-vue.min.js https://cdn.jsdelivr.net/npm/single-spa-vue@1.7.0/lib/single-spa-vue.min.js
mkdir single-spa-vue@1.7.0\lib 2>nul
move single-spa-vue@1.7.0-single-spa-vue.min.js single-spa-vue@1.7.0\lib\single-spa-vue.min.js

cd ..\..\..
echo ✅ Offline dependencies downloaded successfully!
echo 🚀 Run with: set OFFLINE=true && npm run serve:root