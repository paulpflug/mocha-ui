{Emitter} = require 'event-kit'
{spawn} = require "child_process"

mocha = null
emitter = null

dataManager = (chunk) ->
  if chunk != null
    lines = chunk.split("\n")
    lines.pop() if lines[lines.length-1] == ""
    for line,i in lines
      success = false
      try
        obj = JSON.parse(line)
        success = true
      catch
        emitter.emit "line", line
      if success
        emitter.emit "obj", obj

module.exports = class MochaInterface
  constructor : () ->
    if not emitter
      emitter = new Emitter
      emitter.run = ({filter:filter, env:env}) ->
        if emitter.path
          if mocha != null
            mocha.stdout.removeListener "data", dataManager
            mocha.stderr.removeListener "data", dataManager
            mocha.kill("SIGHUP")
          sh = "sh"
          mochaString = "mocha --reporter atom-ui-reporter"
          if filter
            mochaString += " --grep '#{filter}'"
          args = ["-c",mochaString]
          if process.platform == "win32"
            sh = "cmd"
            args[0] = "/c"
          mocha = spawn sh, args, {
            cwd: emitter.path
            env: env
          }
          mocha.stdout.setEncoding("utf8")
          mocha.stdout.on "data", dataManager
          mocha.stderr.setEncoding("utf8")
          mocha.stderr.on "data", dataManager
      emitter.setPath = (path) ->
        emitter.path = path
    return emitter