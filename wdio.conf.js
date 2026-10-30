export const config = {
  runner: 'local',
  specs: ['./test/specs/**/*.js'],
  capabilities: [{ browserName: 'chrome' }],
  framework: 'mocha',
  reporters: ['spec'],
};
