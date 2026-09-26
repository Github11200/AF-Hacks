// Drive the VM console via noVNC. Usage: node vnc_do.mjs out.png step... where step is
// click:X,Y | dbl:X,Y | type:TEXT | key:Enter | wait:MS  (coords in the 1600x1000 viewport)
import { chromium } from '/home/arch/.local/share/mise/installs/npm-playwright/latest/node_modules/playwright/index.mjs';
const [out, ...steps] = process.argv.slice(2);
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1600, height: 1000 } });
await page.goto('http://localhost:8006/', { waitUntil: 'networkidle' });
await page.waitForTimeout(3000);
for (const s of steps) {
  const [op, arg] = [s.slice(0, s.indexOf(':')), s.slice(s.indexOf(':') + 1)];
  const [x, y] = arg.split(',').map(Number);
  if (op === 'click') await page.mouse.click(x, y);
  else if (op === 'dbl') await page.mouse.dblclick(x, y);
  else if (op === 'type') await page.keyboard.type(arg, { delay: 60 });
  else if (op === 'key') await page.keyboard.press(arg);
  else if (op === 'wait') await page.waitForTimeout(Number(arg));
  await page.waitForTimeout(400);
}
await page.screenshot({ path: out });
await browser.close();
