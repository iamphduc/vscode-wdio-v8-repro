describe('example', () => {
  it('opens a page', async () => {
    await browser.url('https://webdriver.io');
    await expect(browser).toHaveTitle(expect.stringContaining('WebdriverIO'));
  });
});
