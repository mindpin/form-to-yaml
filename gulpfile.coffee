gulp    = require "gulp"
util    = require 'gulp-util'

coffee  = require "gulp-coffee"
# smaps   = require 'gulp-sourcemaps'

haml    = require 'gulp-ruby-haml'

options =
  src:
    js: "src/js/**/*.coffee"
    html: "src/demo/**/*.haml"
  dist:
    js: "dist/js"
    html: "dist/demo"

gulp.task "js", ->
  gulp.src options.src.js
    # .pipe smaps.init()
    .pipe coffee()
    # .pipe smaps.write("../maps")
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

gulp.task "build", ["js", "html"]

gulp.task 'watch', ['build'], ->
  gulp.watch options.src.js, ['js']
  gulp.watch options.src.html, ['html']
