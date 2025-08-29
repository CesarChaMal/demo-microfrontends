#!/bin/bash

echo "Starting all microfrontend HTTP servers..."

npx http-server single-spa-auth-app/dist -p 4201 -c-1 --cors &
npx http-server single-spa-layout-app/dist -p 4202 -c-1 --cors &
npx http-server single-spa-home-app/dist -p 4203 -c-1 --cors &
npx http-server single-spa-angular-app/dist -p 4204 -c-1 --cors &
npx http-server single-spa-vue-app/dist -p 4205 -c-1 --cors &
npx http-server single-spa-react-app/dist -p 4206 -c-1 --cors &
npx http-server single-spa-vanilla-app/dist -p 4207 -c-1 --cors &
npx http-server single-spa-webcomponents-app/dist -p 4208 -c-1 --cors &
npx http-server single-spa-typescript-app/dist -p 4209 -c-1 --cors &
npx http-server single-spa-jquery-app/dist -p 4210 -c-1 --cors &
npx http-server single-spa-svelte-app/dist -p 4211 -c-1 --cors &

echo "All servers started. Press Ctrl+C to stop all."
wait