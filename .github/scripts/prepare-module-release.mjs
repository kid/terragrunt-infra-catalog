import fs from "fs";
import path from "path";

const moduleName = process.env.MODULE_NAME;

if (!moduleName) {
  console.error("MODULE_NAME is required");
  process.exit(1);
}

const moduleDir = path.resolve("modules", moduleName);
if (!fs.existsSync(moduleDir)) {
  console.error(`Module directory not found: ${moduleDir}`);
  process.exit(1);
}

const contextPath = path.join(".github", ".releases", moduleName);
fs.mkdirSync(contextPath, { recursive: true });

const escapeRegex = (value) =>
  value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const moduleScope = escapeRegex(moduleName);
const parserOpts = {
  headerPattern: `^(\\w+)\\(${moduleScope}\\)(!)?: (.+)$`,
  headerCorrespondence: ["type", "scope", "breaking", "subject"]
};

const releaseConfig = {
  branches: ["main"],
  tagFormat: `module-${moduleName}-v\${version}`,
  plugins: [
    [
      "@semantic-release/commit-analyzer",
      { preset: "conventionalcommits", parserOpts }
    ],
    [
      "@semantic-release/release-notes-generator",
      { preset: "conventionalcommits", parserOpts }
    ],
    [
      "@semantic-release/changelog",
      { changelogFile: "modules/" + moduleName + "/CHANGELOG.md" }
    ],
    [
      "@semantic-release/git",
      {
        assets: ["modules/" + moduleName + "/CHANGELOG.md"],
        message: `chore(release:${moduleName}): \${nextRelease.version} [skip ci]`
      }
    ],
    "@semantic-release/github"
  ]
};

const releaseConfigPath = path.join(contextPath, "release.config.json");
fs.writeFileSync(releaseConfigPath, JSON.stringify(releaseConfig, null, 2));

const releaseRcPath = path.join(contextPath, ".releaserc.json");
fs.writeFileSync(
  releaseRcPath,
  JSON.stringify({ extends: "./release.config.json" }, null, 2)
);

const releaseIndexPath = path.join(contextPath, "index.mjs");
const releaseIndex = `import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import semanticRelease from "semantic-release";

const configPath = path.resolve(".github", ".releases", "${moduleName}", "release.config.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
const isDryRun = process.argv.includes("--dry-run");
const logPath = path.resolve(".github", ".releases", "${moduleName}", "dry-run.log");
const modulePath = path.join("modules", "${moduleName}");

if (isDryRun) {
  config.branches = ["*"];
  config.plugins = config.plugins.filter((plugin) => {
    const name = Array.isArray(plugin) ? plugin[0] : plugin;
    return name !== "@semantic-release/git" && name !== "@semantic-release/github";
  });
}

const writeLog = (line) => {
  if (!isDryRun) {
    return;
  }
  fs.appendFileSync(logPath, line);
};

const stdout = {
  write: (chunk) => {
    process.stdout.write(chunk);
    writeLog(chunk);
  }
};
const stderr = {
  write: (chunk) => {
    process.stderr.write(chunk);
    writeLog(chunk);
  }
};

if (isDryRun) {
  fs.writeFileSync(logPath, "");
}

const hasChanges = () => {
  let lastTag = "";
  try {
    lastTag = execSync(
      `git describe --tags --match "module-${moduleName}-v*" --abbrev=0`,
      { encoding: "utf8" }
    ).trim();
  } catch (error) {
    lastTag = "";
  }

  const range = lastTag ? `${lastTag}..HEAD` : "HEAD";
  const output = execSync(`git log ${range} -- ${modulePath}`, {
    encoding: "utf8"
  }).trim();

  return output.length > 0;
};

if (!hasChanges()) {
  console.log(`No changes in ${modulePath}; skipping release.`);
  process.exit(0);
}

const result = await semanticRelease(config, {
  cwd: process.cwd(),
  env: process.env,
  stdout,
  stderr,
  dryRun: isDryRun
});

if (!result) {
  console.log(`No release published for ${moduleName}.`);
} else {
  console.log(
    `Published ${moduleName} release ${result.nextRelease.version} as ${result.nextRelease.gitTag}.`
  );
}
`;
fs.writeFileSync(releaseIndexPath, releaseIndex);
