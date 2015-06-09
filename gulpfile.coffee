gulp    = require "gulp"
util    = require 'gulp-util'

coffee  = require "gulp-coffee"
# 防止编译 coffee 过程中 watch 进程中止
plumber = require 'gulp-plumber'

haml    = require 'gulp-ruby-haml'

sass    = require 'gulp-ruby-sass'

options =
  src:
    js: "src/js/**/*.coffee"
    html: "src/demo/**/*.haml"
    yaml: "src/yaml/**/*.yaml"
    scss_path:  "src/scss/"
    scss:  "src/scss/**/**.scss"
    css:  "src/css/**/*.css"
  dist:
    js: "dist/js"
    html: "dist/demo"
    yaml: "dist/yaml"
    css:  "dist/css"

gulp.task "js", ->
  gulp.src options.src.js
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest(options.dist.js)

gulp.task "html", ->
  gulp.src options.src.html
    .pipe haml()
    .on "error", (err)->
      util.log [
        err.plugin,
        util.colors.red err.message
        err.message
      ].join " "
    .pipe gulp.dest(options.dist.html)

gulp.task "yaml", ->
  gulp.src options.src.yaml
    .pipe gulp.dest(options.dist.yaml)

gulp.task "scss", ->
  return sass options.src.scss_path
  .on "error", (err)->
    console.error "Error!", err.message
  .pipe gulp.dest(options.dist.css)

gulp.task "css", ->
  gulp.src options.src.css
    .pipe gulp.dest(options.dist.css)


gulp.task "build", ["js", "html", "yaml", "scss", "css"]

gulp.task 'watch', ['build'], ->
  gulp.watch options.src.js, ['js']
  gulp.watch options.src.html, ['html']
  gulp.watch options.src.yaml, ['yaml']
  gulp.watch options.src.css, ['css']
  gulp.watch options.src.scss, ['scss']
