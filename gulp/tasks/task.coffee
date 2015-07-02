# ==================================
#
# Load modules.
#
# ==================================
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
browserify = require 'browserify'
watchify = require 'watchify'
browserSync = require 'browser-sync'
nodeSassGlobbing = require 'node-sass-globbing'

handleErrors = require '../util/handleErrors.js'

gulp = require 'gulp'
$ = require('gulp-load-plugins')()

# ==================================
#
# Directory Setting.
#
# ==================================

dir =
  assets: './assets'
  src: './assets/src'
  dist: './assets/dist'



# ==================================
#
# vendor styles
#
# ==================================

gulp.task 'vendor-style', () ->
  gulp.src 'node_modules/normalize.css/normalize.css'
  .pipe $.rename basename: "_normalize", extname: ".scss"
  .pipe gulp.dest dir.src + '/styles/foundation'

  gulp.src 'node_modules/swiper/dist/css/swiper.css'
  .pipe $.rename basename: "_swiper", extname: ".scss"
  .pipe gulp.dest dir.src + '/styles/object/component'



# ==================================
#
# Sass
#
# ==================================

gulp.task 'sass', () ->
  gulp.src [
    dir.src + '/styles/**/*.scss'
  ]
  .pipe $.plumber()
  .pipe $.sourcemaps.init()
  .pipe $.sass(
    importer: nodeSassGlobbing
  )
  .on('error', $.sass.logError)
  .pipe $.autoprefixer()
  .pipe $.sourcemaps.write {
    includeContent: false,
    sourceRoot: '../../../assets/src/styles'
  }
  .pipe gulp.dest dir.dist + '/styles'


gulp.task 'sass:dist', () ->
  gulp.src dir.src + '/styles/**/*.scss'
  .pipe $.sass(
    importer: nodeSassGlobbing
  )
  .pipe $.autoprefixer()
  .pipe $.rename extname: ".min.css"
  .pipe gulp.dest dir.dist + '/styles'




# ==================================
#
# minify images
#
# ==================================

gulp.task 'image', ->
  gulp.src(dir.src + '/images/**/*')
  .pipe $.plumber errorHandler: $.notify.onError('<%= error.message %>')
  .pipe $.imagemin
    progressive: true,
    svgoPlugins: [{removeViewBox: false}],
  .pipe gulp.dest dir.dist + '/images'


# ==================================
#
# Compile JavaScripts.
#
# ==================================



gulp.task 'setWatch', ->
  #noinspection JSUnresolvedVariable
  global.isWatching = true

gulp.task 'browserify', () ->

  b = browserify({
    cache: {}, packageCache: {}, fullPaths: false,
    debug: true
    entries: dir.src + '/scripts/all.coffee'
    extensions: ['.coffee', 'js', 'jsx', 'cjsx']
  })
  .transform 'coffeeify'
  .transform 'babelify'
  .transform "browserify-shim"
  .transform "debowerify"

  bundle = ->
    b
    .bundle()
    .on 'error', handleErrors
    .pipe source 'all.js'
    .pipe gulp.dest dir.dist + '/scripts/'


  console.log global.isWatching
  if global.isWatching
    bundler = watchify(b)

    bundler.on 'update', bundle

  bundle()


# ==================================
#
# browserSync
#
# ==================================

gulp.task 'browserSync', ->
  browserSync(
    #proxy: 'local.nagano-premium.jp', # for vccw. replace server.
    server:
      baseDir: './'

    files: [
      dir.dist + '/**',
      "./**/*.php",
      "./**/*.html"
    ]
  )



# ==================================
#
# tasks.
#
# ==================================



gulp.task 'build:dist', [ 'sass:dist', 'browserify', 'image']
gulp.task 'build', [ 'sass', 'browserify', 'image']

#browserifyを実行すると、watchifyが動かないので個別に実行
gulp.task 'default', [ 'sass','image', 'watch']



# ==================================
#
# watch.
#
# ==================================


gulp.task 'watch', ['watchify', 'browserSync'], ->
  $.watch dir.src + '/styles/**/*', ->
    gulp.start 'sass'

  $.watch dir.src + '/images/**/*', ->
    gulp.start 'image'

gulp.task 'watchify',['setWatch', 'browserify']

gulp.task 'serve', ['watch']
