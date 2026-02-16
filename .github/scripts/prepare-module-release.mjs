import fs from 'fs'
import path from 'path'

const moduleName = process.env.MODULE_NAME

if (!moduleName) {
  console.error('MODULE_NAME is required')
  process.exit(1)
}

const moduleDir = path.resolve('modules', moduleName)
if (!fs.existsSync(moduleDir)) {
  console.error(`Module directory not found: ${moduleDir}`)
  process.exit(1)
}

const contextPath = path.join('.github', '.releases', moduleName)
fs.mkdirSync(contextPath, { recursive: true })

const releaseConfig = {
  branches: ['main'],
  tagFormat: `${moduleName}-v\${version}`,
  plugins: [
    [
      './.github/.releases/' + moduleName + '/filtered-commits.mjs',
      {
        modulePath: 'modules/' + moduleName,
        unitPath: 'units/' + moduleName,
        analyzer: { preset: 'conventionalcommits' },
        notes: { preset: 'conventionalcommits' }
      }
    ],
    [
      '@semantic-release/changelog',
      { changelogFile: 'modules/' + moduleName + '/CHANGELOG.md' }
    ],
    [
      '@semantic-release/git',
      {
        assets: ['modules/' + moduleName + '/CHANGELOG.md'],
        message: `chore(release:${moduleName}): \${nextRelease.version} [skip ci]`
      }
    ],
    [
      '@semantic-release/github',
      {
        successComment:
          `:tada: This PR is included in ${moduleName} v\${nextRelease.version} :tada:\n\n` +
          'The release is available on [GitHub release](<%= releaseUrl %>)\n\n' +
          'Your **[semantic-release](https://github.com/semantic-release/semantic-release)** bot :package::rocket:',
        failComment: false
      }
    ]
  ]
}

const releaseConfigPath = path.join(contextPath, 'release.config.json')
fs.writeFileSync(releaseConfigPath, JSON.stringify(releaseConfig, null, 2))

const releaseRcPath = path.join(contextPath, '.releaserc.json')
fs.writeFileSync(
  releaseRcPath,
  JSON.stringify({ extends: './release.config.json' }, null, 2)
)

const releaseIndexPath = path.join(contextPath, 'index.mjs')
const filteredCommitsPath = path.join(contextPath, 'filtered-commits.mjs')
const filteredCommitsPlugin = `import { execSync } from "child_process"
import { createRequire } from "module"

const require = createRequire(import.meta.url)
const commitAnalyzerModule = require("@semantic-release/commit-analyzer")
const releaseNotesGeneratorModule = require("@semantic-release/release-notes-generator")
const commitAnalyzer =
  commitAnalyzerModule.default || commitAnalyzerModule.analyzeCommits
const releaseNotesGenerator =
  releaseNotesGeneratorModule.default || releaseNotesGeneratorModule.generateNotes

const listCommitFiles = (hash) => {
  if (!hash) {
    return []
  }

  try {
    const output = execSync(
      "git diff-tree --no-commit-id --name-only -r " + hash,
      { encoding: "utf8" }
    )

    return output
      .split("\\n")
      .map((line) => line.trim())
      .filter((line) => line.length > 0)
  } catch (error) {
    return []
  }
}

const filterCommitsByPath = (commits, modulePath, unitPath) =>
  commits.filter((commit) => {
    const files = listCommitFiles(commit.hash)
    const sharedPath = "modules/_shared"
    return files.some(
      (file) =>
        file === modulePath ||
        file.startsWith(modulePath + "/") ||
        (unitPath && (file === unitPath || file.startsWith(unitPath + "/"))) ||
        file === sharedPath ||
        file.startsWith(sharedPath + "/")
    )
  })

const filterContextCommits = (context, modulePath, unitPath) => {
  const commits = filterCommitsByPath(
    context.commits || [],
    modulePath,
    unitPath
  )
  context.commits = commits
  return commits
}

export async function verifyConditions (pluginConfig, context) {
  const modulePath = pluginConfig.modulePath
  const unitPath = pluginConfig.unitPath
  filterContextCommits(context, modulePath, unitPath)
}

export async function analyzeCommits (pluginConfig, context) {
  const modulePath = pluginConfig.modulePath
  const unitPath = pluginConfig.unitPath
  const commits = filterContextCommits(context, modulePath, unitPath)
  return commitAnalyzer(pluginConfig.analyzer || {}, {
    ...context,
    commits
  })
}

export async function generateNotes (pluginConfig, context) {
  const modulePath = pluginConfig.modulePath
  const unitPath = pluginConfig.unitPath
  const commits = filterContextCommits(context, modulePath, unitPath)
  return releaseNotesGenerator(pluginConfig.notes || {}, {
    ...context,
    commits
  })
}
`
const releaseIndex = `import { execSync } from "child_process"
import fs from "fs"
import path from "path"
import semanticRelease from "semantic-release"

const configPath = path.resolve(".github", ".releases", "${moduleName}", "release.config.json")
const config = JSON.parse(fs.readFileSync(configPath, "utf8"))
const isDryRun = process.argv.includes("--dry-run")
const logPath = path.resolve(".github", ".releases", "${moduleName}", "dry-run.log")
const modulePath = path.join("modules", "${moduleName}")
const unitPath = path.join("units", "${moduleName}")
const sharedPath = path.join("modules", "_shared")

if (isDryRun) {
  config.branches = ["*"]
  config.plugins = config.plugins.filter((plugin) => {
    const name = Array.isArray(plugin) ? plugin[0] : plugin
    return name !== "@semantic-release/git" && name !== "@semantic-release/github"
  })
}

const writeLog = (line) => {
  if (!isDryRun) {
    return
  }
  fs.appendFileSync(logPath, line)
}

const stdout = {
  write: (chunk) => {
    process.stdout.write(chunk)
    writeLog(chunk)
  }
}
const stderr = {
  write: (chunk) => {
    process.stderr.write(chunk)
    writeLog(chunk)
  }
}

if (isDryRun) {
  fs.writeFileSync(logPath, "")
}

const hasChanges = () => {
  let lastTag = ""
  try {
    lastTag = execSync(
      "git describe --tags --match '${moduleName}-v*' --abbrev=0",
      { encoding: "utf8" }
    ).trim()
  } catch (error) {
    lastTag = ""
  }

  if (!lastTag) {
    return true
  }

  const range = lastTag + "..HEAD"
  const output = execSync(
    "git log " +
      range +
      " -- " +
      modulePath +
      " " +
      unitPath +
      " " +
      sharedPath,
    {
      encoding: "utf8"
    }
  ).trim()

  return output.length > 0
}

if (!hasChanges()) {
  console.log("No changes in " + modulePath + "; skipping release.")
  process.exit(0)
}

const result = await semanticRelease(config, {
  cwd: process.cwd(),
  env: process.env,
  stdout,
  stderr,
  dryRun: isDryRun
})

if (!result) {
  console.log("No release published for ${moduleName}.")
} else {
  console.log(
    "Published ${moduleName} release " +
      result.nextRelease.version +
      " as " +
      result.nextRelease.gitTag +
      "."
  )
}
`
fs.writeFileSync(releaseIndexPath, releaseIndex)
fs.writeFileSync(filteredCommitsPath, filteredCommitsPlugin)
