import fs from 'fs'
import path from 'path'

const modulesDir = path.resolve('modules')
const entries = fs.existsSync(modulesDir)
  ? fs.readdirSync(modulesDir, { withFileTypes: true })
  : []

const modules = entries
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .filter((name) => name !== '_shared')
  .sort()

const changedFilesPath = process.env.CHANGED_FILES_PATH

const parseChangedModules = (filePath) => {
  if (!filePath || !fs.existsSync(filePath)) {
    return null
  }

  const content = fs.readFileSync(filePath, 'utf8').trim()
  if (!content) {
    return []
  }

  const modulesSet = new Set()
  for (const file of content.split('\n')) {
    const match = file.match(/^modules\/([^/]+)\//)
    if (match && match[1] !== '_shared') {
      modulesSet.add(match[1])
    }
  }

  return [...modulesSet]
}

const changedModules = parseChangedModules(changedFilesPath)
const selectedModules = changedModules === null
  ? modules
  : modules.filter((name) => changedModules.includes(name))

const matrix = selectedModules.length
  ? { include: selectedModules.map((name) => ({ name })) }
  : ''

if (process.env.GITHUB_OUTPUT) {
  const payload = matrix ? JSON.stringify(matrix) : ''
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `matrix=${payload}\n`)
} else {
  console.log(matrix ? JSON.stringify(matrix) : '')
}
