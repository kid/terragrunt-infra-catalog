import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'

const moduleName = process.env.MODULE_NAME
if (!moduleName) {
  console.error('MODULE_NAME is required')
  process.exit(1)
}

const logPath = `.github/.releases/${moduleName}/dry-run.log`
if (!fs.existsSync(logPath)) {
  console.log(`No dry-run log found for ${moduleName}.`)
  process.exit(0)
}

const log = fs.readFileSync(logPath, 'utf8')
const publishedMatch = log.match(/Published .* release (\d+\.\d+\.\d+)/)
const notesMatch = log.match(/Release note for version .*?\n([\s\S]*)/)
if (!publishedMatch) {
  console.log(`No release for ${moduleName}.`)
  process.exit(0)
}

const version = publishedMatch[1]
const notes = notesMatch ? notesMatch[1].trim() : ''
const body = `## Release preview: ${moduleName}\n\n` +
  `Planned version: ${version}\n\n` +
  (notes ? `### Notes\n\n${notes}\n` : 'No release notes generated.')

const prNumber = process.env.PR_NUMBER || process.env.GITHUB_REF_NAME?.split('/')[1]
if (!prNumber) {
  console.log('No PR number available; skipping comment.')
  process.exit(0)
}

const tmpPath = path.resolve('.github', '.releases', moduleName, 'pr-comment.md')
fs.writeFileSync(tmpPath, body)

execFileSync('gh', ['pr', 'comment', prNumber, '--body-file', tmpPath], {
  stdio: 'inherit'
})
