module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    cssmin: {
      combine: {
        files: {
          'out/styles/all.min.css': [
            'out/vendor/highlight-tomorrow-night.css',
            'out/styles/post-tags.css',
            'out/styles/style.css'
          ]
        }
      }
    },
    compress: {
      main: {
        options: {
          mode: 'gzip'
        },
        expand: true,
        cwd: 'out/',
        src: ['**/*'],
        dest: 'public/',
        ext: ''
      }
    },
    uglify: {
      build: {
        src: 'out/styles/all.css',
        dest: 'out/styles/all.min.css'
      }
    },
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-compress');

  grunt.registerTask('default', ['cssmin']);

};