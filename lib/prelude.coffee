(require 'lodash').extend global,
  _: require 'lodash'
  YAML: require 'js-yaml'
  fs: require 'fs'
  out: (string)->
    process.stdout.write String string
  err: (string)->
    process.stderr.write String string
  exit: (rc=0)->
    process.exit rc

  say: (string...)->
    out "#{string.join ' '}\n"
  warn: (string...)->
    string = String string.join ' '
    if not string.match /\n/
      string = "Warning: #{string}\n"
    err string
  error: (msg='Unknown error')->
    say "stp error: #{msg}"
    exit 1
  die: (msg)->
    throw msg
  xxx: (data...)->
    console.dir(data)
    exit 1
  XXX: (data...)->
    for elem in data
      err "---\n#{YAML.dump elem}"
    exit 1
  exec: (cmd, args)->
    args ?= []
    require('child_process').spawnSync cmd, args, stdio: 'inherit'

  stub: (name)->
    die "Function or method #{name} is not yet implemented"

  read_file: (file_path)->
    if file_path == '-'
      fs.readFileSync('/dev/stdin').toString()
    else
      fs.readFileSync(file_path).toString()

  write_file: (file_path, output)->
    if file_path == '-'
      process.stdout.write(output)
    else
      fs.writeFileSync(file_path, output)

  load_data_file: (file_path)->
    if file_path.match /\.(stp|ya?ml)$/
      return load_yaml_file file_path
    else if file_path.match /\.(stpx|jsc|json)$/
      return load_json_file file_path
    input = read_file file_path
    if input.match /^\s*[\{\[]/
      JSON.load input
    else
      YAML.load input

  load_json_file: (file_path)->
    load_json read_file file_path

  load_yaml_file: (file_path)->
    YAML.load read_file file_path
