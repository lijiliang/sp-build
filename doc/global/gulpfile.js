var $, browserSync, configs, fs, getTask, gulp, gutil, path, reload;

fs = require('fs');

path = require('path');

gulp = require('gulp');

gutil = require('gulp-util');

configs = require('./config');

browserSync = require('browser-sync');

reload = browserSync.reload;

$ = require('gulp-load-plugins')();

getTask = function(task) {
  return require('./_builder/gulp-task/' + task)(gulp, $);
};

gulp.task('clean:build', getTask('clean-build'));

gulp.task('clean:dev', getTask('clean-dev'));

gulp.task('ie:dev', getTask('ie'));

gulp.task('commoncss:dev', getTask('css-common'));

gulp.task('pagecss:dev', getTask('css-pages'));

gulp.task('sprite:dev', ['commoncss:dev', 'pagecss:dev', 'images:dev'], getTask('sprite'));

gulp.task('images:dev', getTask('images-dev'));

gulp.task('images:build', ['sprite:dev'], getTask('images-build'));

gulp.task('fonts:dev', getTask('fonts-dev'));

gulp.task('fonts:build', getTask('fonts-build'));

gulp.task('html:list', getTask('html-json'));

gulp.task('html', getTask('html'));

gulp.task('doc', getTask('doc'));

gulp.task("server", ['buildCommon:dev', 'html', 'html:list', 'ie:dev', 'fonts:dev', 'sprite:dev'], getTask('server'));

gulp.task('webpack:dev', getTask('webpack'));

gulp.task('default', ['clean:dev'], function() {
  return gulp.start('server');
});

gulp.task('buildCommon:dev', ['webpack:dev'], getTask('concat-common-js'));

gulp.task('build', ['clean:dev', 'clean:build'], getTask('map'));

gulp.task('testserver', ['build'], getTask('server-pro'));
