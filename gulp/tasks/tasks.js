'use strict';

// ==================================
//
// Load modules.
//
// ==================================

var gulp = require('gulp');

// ==================================
//
// tasks.
//
// ==================================


gulp.task('build', ['fonts', 'sass', 'images', 'browserify']);
gulp.task('build:dist', ['build', 'sass:dist']);

gulp.task('default', ['setWatch', 'build', 'watch', 'browserSync']);
gulp.task('phpserver', ['setPHPServer', 'default']);