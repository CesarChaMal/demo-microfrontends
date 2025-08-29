@echo off
echo Starting all microfrontend HTTP servers...

start "Auth-4201" cmd /k "cd single-spa-auth-app\dist && npx http-server . -p 4201 -c-1 --cors"
start "Layout-4202" cmd /k "cd single-spa-layout-app\dist && npx http-server . -p 4202 -c-1 --cors"
start "Home-4203" cmd /k "cd single-spa-home-app\dist && npx http-server . -p 4203 -c-1 --cors"
start "Angular-4204" cmd /k "cd single-spa-angular-app\dist && npx http-server . -p 4204 -c-1 --cors"
start "Vue-4205" cmd /k "cd single-spa-vue-app\dist && npx http-server . -p 4205 -c-1 --cors"
start "React-4206" cmd /k "cd single-spa-react-app\dist && npx http-server . -p 4206 -c-1 --cors"
start "Vanilla-4207" cmd /k "cd single-spa-vanilla-app\dist && npx http-server . -p 4207 -c-1 --cors"
start "WebComponents-4208" cmd /k "cd single-spa-webcomponents-app\dist && npx http-server . -p 4208 -c-1 --cors"
start "TypeScript-4209" cmd /k "cd single-spa-typescript-app\dist && npx http-server . -p 4209 -c-1 --cors"
start "jQuery-4210" cmd /k "cd single-spa-jquery-app\dist && npx http-server . -p 4210 -c-1 --cors"
start "Svelte-4211" cmd /k "cd single-spa-svelte-app\dist && npx http-server . -p 4211 -c-1 --cors"

echo All servers started in separate windows.
echo Press any key to continue...
pause