#!/usr/bin/env node

// used to install aur packages

if (process.argv.length < 3) process.exit(1);

const path = require('path')
const fs = require('fs/promises')

;(async () => {
  try {
    const package = process.argv[2]
    const dirPath = path.join(__dirname, '.tmp', package)
    const list = await fs.readdir(dirPath)
    const match = list.find(name => name.startsWith(package) && name.includes('.tar'))
    if (match !== undefined) console.log(path.join(__dirname, '.tmp', package, match))
  } catch (err) {}
})()
