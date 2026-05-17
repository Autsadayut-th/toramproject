module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/*.test.js', '**/__tests__/**/*.js'],
  coveragePathIgnorePatterns: ['/node_modules/'],
  collectCoverageFrom: [
    'api/**/*.js',
    '!api/**/*.test.js',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  testTimeout: 10000,
};
