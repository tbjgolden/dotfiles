#!/usr/bin/env node

const path = require('path')
const fs = require('fs/promises')
const os = require('os')
const hasBin = require('./hasBin.js')
const Diff = require('./diff.js')
const { isText } = require('./isTextOrBinary.js')
const readline = require('readline');
const cp = require("child_process")
const { stdin: input, stdout: output } = require('process');

const prompt = (str) => {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({ input, output });
    rl.question(str, (answer) => {
      rl.close();
      resolve(answer);
    });
  })
}

const red = str => `\x1b[31m${str}\x1b[0m`
const green = str => `\x1b[32m${str}\x1b[0m`

;(async () => {
  const sections = ['all'];
  if (process.platform === 'darwin' || process.platform === 'linux') {
    sections.push(process.platform)
  }
  if (process.platform === 'linux') {
    if (hasBin("pacman")) {
      sections.push("pacman")
    }
  }

  const parts = sections.reduce((o, k) => {
    o[k] = new Set();
    return o;
  }, {});
  
  const references = new Map()

  const scanDir = async (currPath, set) => {
    const list = await fs.readdir(currPath, { withFileTypes: true })

    const promises = []

    for (const item of list) {
      if (item.isFile()) {
        set.add(path.join(currPath, item.name))
      } else if (item.isDirectory()) {
        promises.push(scanDir(path.join(currPath, item.name), set))
      }
    }
    
    await Promise.all(promises)
  }

  await Promise.all(
    Object.keys(parts)
      .map((part) => scanDir(path.join(__dirname, '..', 'src', part), parts[part]))
  )

  await Promise.all(
    (await fs.readdir(path.join(__dirname, '..', 'src', 'references'), {
      withFileTypes: true
    })).map((ref) => {
      if (ref.isDirectory()) {
        const set = new Set()
        references.set(ref.name, set)
        return scanDir(
          path.join(__dirname, '..', 'src', 'references', ref.name),
          set
        )
      }
    })
  )

  const mappings = []

  sections.forEach((section) => {
    const root = path.join(__dirname, '..', 'src', section)
    for (const file of parts[section]) {
      if (file.endsWith('.reference')) {
        const frags = file.split('/')
        const ref = frags[frags.length - 1].slice(0, -10)
        const refRoot = path.join(__dirname, '..', 'src', 'references', ref)
        for (const refFile of references.get(ref)) {
          mappings.push([
            refFile,
            path.join(os.homedir(), file.slice(root.length + 1, -(ref.length + 11)), refFile.slice(refRoot.length + 1))
          ])
        }
      } else {
        mappings.push([
          file,
          path.join(os.homedir(), file.slice(root.length + 1))
        ])
      }
    }
  })

  let hasChanges = false

  await Promise.all(mappings.map(async ([from, to]) => {
    let isFromFileText = null
    try {
      isFromFileText = isText(from)
    } catch (err) {}
    let isToFileText = null
    try {
      isToFileText = isText(to)
    } catch (err) {}

    // if file is not diffable, just replace the file
    if (!isFromFileText || !isToFileText) {
      try {
        await fs.unlink(to)
      } catch (err) {}
      try {
        await fs.copyFile(from, to)
      } catch (err) {}
    } else {
      let toFileText = null
      try {
        toFileText = await fs.readFile(to, 'utf8')
      } catch (err) {}

      if (toFileText === null) {
        try {
          await fs.unlink(to)
        } catch (err) {}
        await fs.copyFile(from, to)
      } else {
        const fromFileText = await fs.readFile(from, 'utf8')

        if (toFileText !== fromFileText) {
          console.log("Proposed changes to:", to)
  
          const diffs = Diff.diffLines(toFileText, fromFileText)
          // Iterate the new lines
          
          let str = ""
          for (const diff of diffs) {
            if (diff.added) {
              str += green(diff.value)
            } else if (diff.removed) {
              str += red(diff.value)
            } else {
              str += diff.value
            }
          }
          console.log(str)

          const choice = await new Promise(async (resolve) => {
            let response = null
            const validResponses = new Set("ukm".split(""))
            while (!validResponses.has(response)) {
              response = (await prompt('[U]pdate, [K]eep or [M]anual merge? ')).trim().toLowerCase();
            }
            resolve(response)
          })

          if (choice === "u") {
            try {
              await fs.unlink(to)
            } catch (err) {}
            await fs.copyFile(from, to)
          } else if (choice === "m") {
            let str = ""
            for (let i = 1; i < diffs.length; i++) {
              const a = diffs[i - 1]
              const b = diffs[i]
              const aType = a.added ? "a" : (a.removed ? "r" : "-")
              const bType = b.added ? "a" : (b.removed ? "r" : "-")
              const type = aType + bType
              
              if (type === "-a" || type === "-r") {
                str += a.value
              } else if (type === "a-") {
                str += `<<<<<<< ↓ LOCAL ↓\n=======\n${a.value}>>>>>>> ↑ REMOTE ↑\n`
              } else if (type === "r-") {
                str += `<<<<<<< ↓ LOCAL ↓\n${a.value}=======\n>>>>>>> ↑ REMOTE ↑\n`
              } else { // "ra"
                str += `<<<<<<< ↓ LOCAL ↓\n${a.value}=======\n${b.value}>>>>>>> ↑ REMOTE ↑\n`
                i++
              }
            }
            if (diffs.length > 0) {
              const diff = diffs[diffs.length - 1]
              if (diff.added) {
                str += `<<<<<<< ↓ LOCAL ↓\n=======\n${diff.value}>>>>>>> ↑ REMOTE ↑\n`
              } else if (diff.removed) {
                str += `<<<<<<< ↓ LOCAL ↓\n${diff.value}=======\n>>>>>>> ↑ REMOTE ↑\n`
              } else {
                str += diff.value
              }
            }

            let ext = to.match(/\.([a-zA-Z0-9]+)$/)
            ext = ext === null ? "" : ext[0]
            const filePath = path.join(os.tmpdir(), `${Math.random().toString().slice(2)}${ext}`)
            await fs.writeFile(filePath, str)
            cp.execSync(`${process.platform === "linux" ? "codium" : "/Applications/VSCodium.app/Contents/Resources/app/bin/codium"} '${filePath}'`)

            await prompt('Opened editor. Edit and save, then press [Enter] to continue')

            try {
              await fs.unlink(to)
            } catch (err) {}
            await fs.copyFile(filePath, to)
          }
          
          if (choice !== "u") {
            const remoteResult = fs.readFile(from, 'utf8')
            const newResult = fs.readFile(to, 'utf8')
            if (remoteResult !== newResult) {
              try {
                await fs.unlink(from)
              } catch (err) {}
              await fs.copyFile(to, from)
              hasChanges = true;
            }
          }
        }
      }
    }
  }))

  if (hasChanges) {
    cp.execSync(`zsh -c 'alias fur="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"; fur add $HOME/.scripts $HOME/.dotfileSrc $HOME/README.md; fur commit -m "updateDotfiles.js"; fur push --set-upstream origin main'`)
  }
})()

/**



# create tmp dir
PREV_CWD="$( pwd )"
rm -rf $HOME/.scripts/.tmp
mkdir -p $HOME/.scripts/.tmp
cd $HOME/.scripts/.tmp
# build into tmp dir
cp -R ../../.dotfileSrc/all/ .
if [ `uname` = "Darwin" ]; then
  cp -R ../../.dotfileSrc/darwin/ .
elif [ `uname` = "Linux" ]; then
  cp -R ../../.dotfileSrc/linux/ .
  if (( $+commands[pacman] )); then
    cp -R ../../.dotfileSrc/pacman/ .
  else
    echo "Unsupported Linux OS; add equivalent config to .dotfileSrc/pacman"
  fi
fi
# replace references with actual files
IFS=$'\n'
REFERENCES=($( find . -type f -iregex '.*\.reference$' -print0 | xargs -0 -I "{}" echo '"{}"' ))
for reference in $REFERENCES; do
  refname=$reference:t
  refname=${refname[1,-12]}
  refdir=`dirname $reference`'"'
  echo $refdir | xargs rm -rf
  echo $refdir | xargs cp -R ../../.dotfileSrc/references/$refname/
done
IFS=$' \t\n'
# replace references with files
cp -Rn ./ $HOME
# find changed files and prompt user
IFS=$'\n'
FILES=($( find . -type f -print0 | xargs -0 -I "{}" echo '"{}"' ))
for file in $FILES; do
  SRCPATH=$( echo $file | xargs -I '{}' echo '"'{}'"' )
  DESTPATH=$( echo '"'${file[4,-1]} | xargs -I '{}' echo '"'$HOME/{}'"' )

  if ! cmp -s ${DESTPATH[2, -2]} ${SRCPATH[2, -2]}; then
    echo ""
    diff -u ${DESTPATH[2, -2]} ${SRCPATH[2, -2]} | diff-so-fancy | tail -n +4
    result=""
    while [ "$result" != "U" -a "$result" != "u" -a "$result" != "K" -a "$result" != "k" -a "$result" != "M" -a "$result" != "m" ]; do
      echo ""
      vared -p '(U)pdate, (K)eep, (M)erge manually?: ' -c result
    done

    if [ "$result" = "U" -o "$result" = "u" ]; then
      echo "Updating"
      rm ${DESTPATH[2, -2]}
      mv ${SRCPATH[2, -2]} ${DESTPATH[2, -2]}
    elif [ "$result" = "K" -o "$result" = "k" ]; then
      echo "Keeping"
    else
      echo "Manual merge"
      echo "===v=== before ===v===" > ${DESTPATH[2, -2]}.tmp
      cat ${DESTPATH[2, -2]} >> ${DESTPATH[2, -2]}.tmp
      echo "===v=== update ===v===" >> ${DESTPATH[2, -2]}.tmp
      cat ${SRCPATH[2, -2]} >> ${DESTPATH[2, -2]}.tmp
      vim ${DESTPATH[2, -2]}.tmp

      while grep -s "e ===v===" ${DESTPATH[2, -2]}.tmp &>/dev/null; do
        echo ""
        echo "Diff comments remain in the source code, must edit..."
        sleep 3
        vim ${DESTPATH[2, -2]}.tmp
      done

      echo "Manual merge completed"
      rm ${DESTPATH[2, -2]}
      mv ${DESTPATH[2, -2]}.tmp ${DESTPATH[2, -2]}
      rm ${DESTPATH[2, -2]}.tmp
    fi
  fi
done
IFS=$' \t\n'
# cleanup tmp dir
cd ..
rm -rf .tmp
cd $PREV_CWD


*/