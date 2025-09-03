@echo off
echo Setting Node.js version...
nvm use 22.18.0

set NODE_OPTIONS=--openssl-legacy-provider

echo Starting ALL microfrontends in development mode...

echo Starting all applications...
echo Root: http://localhost:8080
echo Auth: http://localhost:4201
echo Layout: http://localhost:4202
echo Home: http://localhost:4203
echo Angular: http://localhost:4204
echo Vue: http://localhost:4205
echo React: http://localhost:4206
echo Vanilla: http://localhost:4207
echo Web Components: http://localhost:4208
echo TypeScript: http://localhost:4209
echo jQuery: http://localhost:4210
echo Svelte: http://localhost:4211
echo.
echo Press Ctrl+C to stop all

rem npx concurrently ^
rem   "cd single-spa-login-example-with-npm-packages && npm run serve" ^
rem   "cd single-spa-auth-app && npm run serve" ^
rem   "cd single-spa-layout-app && npm run serve" ^
rem   "cd single-spa-home-app && npm run serve" ^
rem   "cd single-spa-angular-app && npm run serve" ^
rem   "cd single-spa-vue-app && npm run serve" ^
rem   "cd single-spa-react-app && npm run serve"

npm run dev:all