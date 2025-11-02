const fs = require('node:fs');
const path = require('node:path');

module.exports = function hasbinSync (bin) {
  return getPaths(bin).some(fileExistsSync);
}

function getPaths (bin) {
  var envPath = (process.env.PATH || '');
  var envExt = (process.env.PATHEXT || '');
  return envPath.replace(/["]+/g, '').split(path.delimiter).map(function (chunk) {
    return envExt.split(path.delimiter).map(function (ext) {
      return path.join(chunk, bin + ext);
    });
  }).reduce(function (a, b) {
    return a.concat(b);
  });
}

function fileExistsSync (filePath) {
  try {
    return fs.statSync(filePath).isFile();
  } catch (error) {
    return false;
  }
}
