// Screenshot the Windows VM via the dockur noVNC console.
import { chromium } from '/home/arch/.local/share/mise/installs/npm-playwright/latest/node_modules/playwright/index.mjs';
const out = process.argv[2] || 'vm.png';
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
await page.goto('http://localhost:8006/', { waitUntil: 'networkidle' });
await page.waitForTimeout(4000);
await page.screenshot({ path: out });
await browser.close();
