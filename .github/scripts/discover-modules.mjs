import fs from "fs";
import path from "path";

const modulesDir = path.resolve("modules");
const entries = fs.existsSync(modulesDir)
  ? fs.readdirSync(modulesDir, { withFileTypes: true })
  : [];

const modules = entries
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .filter((name) => name !== "_shared")
  .sort();

const matrix = { include: modules.map((name) => ({ name })) };

if (process.env.GITHUB_OUTPUT) {
  fs.appendFileSync(
    process.env.GITHUB_OUTPUT,
    `matrix=${JSON.stringify(matrix)}\n`
  );
} else {
  console.log(JSON.stringify(matrix));
}
