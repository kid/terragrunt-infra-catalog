import fs from "fs";
import path from "path";

const changedFilesPath = process.env.CHANGED_FILES_PATH;

const readChangedFiles = (filePath) => {
  if (!filePath || !fs.existsSync(filePath)) {
    return null;
  }

  const content = fs.readFileSync(filePath, "utf8").trim();
  if (!content) {
    return [];
  }

  return content.split("\n").filter(Boolean);
};

const isRootFile = (filePath) => !filePath.includes("/");

const selectTargets = (files) => {
  if (files === null) {
    return ["."];
  }

  const targets = new Set();
  for (const file of files) {
    const normalized = file.replace(/\\/g, "/");
    if (!fs.existsSync(normalized)) {
      continue;
    }

    if (normalized.startsWith("modules/")) {
      const parts = normalized.split("/");
      if (parts.length >= 2 && parts[1] !== "_shared") {
        targets.add(path.join("modules", parts[1]));
      }
      continue;
    }

    if (normalized.startsWith(".github/")) {
      targets.add(".github");
      continue;
    }

    if (isRootFile(normalized)) {
      targets.add(".");
      continue;
    }

    const topLevel = normalized.split("/")[0];
    if (topLevel) {
      targets.add(topLevel);
    }
  }

  if (targets.size === 0) {
    targets.add(".");
  }

  return [...targets].sort();
};

const changedFiles = readChangedFiles(changedFilesPath);
const targets = selectTargets(changedFiles);
const matrix = targets.length
  ? { include: targets.map((target) => ({ target })) }
  : "";

if (process.env.GITHUB_OUTPUT) {
  const payload = matrix ? JSON.stringify(matrix) : "";
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `matrix=${payload}\n`);
} else {
  console.log(matrix ? JSON.stringify(matrix) : "");
}
