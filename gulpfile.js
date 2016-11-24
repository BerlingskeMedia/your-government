/*jslint indent:2, node:true, sloppy:true*/
var
  gulp = require('gulp'),
  coffee = require('gulp-coffee'),
  ngannotate = require('gulp-ng-annotate'),
  rename = require("gulp-rename"),
  uglify = require('gulp-uglify'),
  sass = require('gulp-sass'),
  styl = require('gulp-styl'),
  concat = require('gulp-concat'),
  csso = require('gulp-csso'),
  imagemin = require('gulp-imagemin'),
  header = require('gulp-header'),
  cleanhtml = require('gulp-cleanhtml'),
  changed = require('gulp-changed'),
  gulpif = require('gulp-if'),
  jade = require('gulp-jade'),
  connect = require('gulp-connect'),
  corsproxy = require('corsproxy'),
  livereload = require('gulp-livereload'),
  pkg = require('./package.json');

var banner = [
  '/**',
  ' ** <%= pkg.name %> - <%= pkg.description %>',
  ' ** @author <%= pkg.author %>',
  ' ** @version v<%= pkg.version %>',
  ' **/',
  ''
].join('\n');

var build = false;
var dest = 'app/upload/tcarlsen/your-government';
/* Scripts */
gulp.task('scripts', function () {
  return gulp.src('src/**/*.coffee')
    .pipe(gulpif(!build, changed(dest)))
    .pipe(coffee())
    .pipe(ngannotate())
    .pipe(gulpif(build, uglify()))
    .pipe(concat('scripts.min.js'))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(dest))
    .pipe(livereload());
});
/* Styles */
gulp.task('styles', function () {
  return gulp.src('src/**/*.scss')
    .pipe(gulpif(!build, changed(dest)))
    .pipe(sass())
    .pipe(styl())
    .pipe(csso())
    .pipe(concat('styles.min.css'))
    .pipe(header(banner, {pkg: pkg}))
    .pipe(gulp.dest(dest))
    .pipe(livereload());
});
/* Dom elements */
gulp.task('dom', function () {
  return gulp.src('src/**/*.jade')
    .pipe(gulpif(!build, changed(dest)))
    .pipe(jade({pretty: true}))
    .pipe(gulpif(build, cleanhtml()))
    .pipe(rename({dirname: '/partials'}))
    .pipe(gulp.dest(dest))
    .pipe(livereload());
});
/* Images */
gulp.task('images', function () {
  return gulp.src('src/images/**')
    .pipe(gulpif(!build, changed('app/img')))
    // .pipe(imagemin())
    .pipe(gulp.dest(dest + '/img'))
    .pipe(livereload());
});
/* Watch task */
gulp.task('watch', function () {
  gulp.watch('src/**/*.coffee', ['scripts']);
  gulp.watch('src/**/*.scss', ['styles']);
  gulp.watch('src/**/*.jade', ['dom']);
  gulp.watch('src/images/**', ['images']);
});
/* Build task */
// gulp.task('build', function () {
//   build = true;
//   dest = 'build';
//
//   gulp.start('scripts', 'styles', 'dom', 'images');
// });

/* Server */
gulp.task('connect', function () {
  connect.server({
    root: 'app',
    port: 9000,
    livereload: true
  });
});

/* CORS Proxy */
gulp.task('corsproxy', function () {
  require('corsproxy/bin/corsproxy');
});

gulp.task('build', function () {
  if (process.argv.indexOf('--production') > -1){
    build = true;
    dest = 'build';
    del(dest);
    console.log('Building into ./' + dest);
    gulp.start('scripts', 'styles', 'dom', 'images');
  } else {
    build = false;
    dest = 'app/upload/tcarlsen/your-government';
    console.log('Building into ./' + dest);
    gulp.start('scripts', 'styles', 'dom', 'images');
  }
});

gulp.task('serve', ['corsproxy', 'connect']);

/* Default task */
gulp.task('default', ['scripts', 'styles', 'dom', 'images', 'watch']);
