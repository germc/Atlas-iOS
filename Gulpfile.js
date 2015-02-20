var gulp = require('gulp'),
    stylus = require('gulp-stylus'),
    nib = require('nib'),
    jeet = require('jeet'),
    connect = require('gulp-connect');

gulp.task('default', ['stylus-prod']);
gulp.task('build', ['stylus-prod']);
gulp.task('dev', ['stylus-dev', 'connect', 'watch']);

gulp.task('stylus-prod', function () {
  gulp.src('./styles/styles.styl')
    .pipe(stylus({
      use: [nib(), jeet()],
      compress: true
    }))
    .pipe(gulp.dest('./css'));
});

gulp.task('stylus-dev', function () {
  gulp.src('./styles/styles.styl')
    .pipe(stylus({
      use: [nib(), jeet()]
    }))
    .pipe(gulp.dest('./css'))
    .pipe(connect.reload());
});

gulp.task('connect', function() {
  connect.server({
    livereload: true
  });
});
 
gulp.task('html', function () {
  gulp.src('./*.html')
    .pipe(connect.reload());
});
 
gulp.task('watch', function () {
  gulp.watch(['./*.html'], ['html']);
  gulp.watch(['./styles/*.styl', './styles/components/*.styl', './styles/sections/*.styl'], ['stylus-dev']);
});