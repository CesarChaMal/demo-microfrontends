module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'airbnb-base',
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: [
    'json',
  ],
  rules: {
    'no-console': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/no-unresolved': 'off',
    'max-len': ['error', { code: 120 }],
    'no-param-reassign': 'off',
    'no-underscore-dangle': 'off',
  },
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    '*.min.js',
    'single-spa-*/node_modules/',
    'single-spa-*/dist/',
    'single-spa-*/build/',
  ],
};