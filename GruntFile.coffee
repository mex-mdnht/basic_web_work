module.exports = (grunt) ->
	"use strict"

	#パッケージ情報読み込み
	pkg = grunt.file.readJSON 'package.json'

	#全てのnpmタスク読み込み
	for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
		grunt.loadNpmTasks taskName

	#各タスク設定
	grunt.initConfig
		#テンプレートに設定引き継ぎ
		pkg: pkg
		#concat:
			

		clean:
			expanded_js:
				expand: true,
				cwd: 'deploy/javascript',
				src: ['*.js', '!*.min.js']
				
			expanded_css:
				expand: true,
				cwd: 'deploy/stylesheet',
				src: ['*.css', '!*.min.css']

		coffee:
			mainjs:
				files:[
					expand: true,
					cwd: 'source',
					src: ['**/_*.coffee'],
					dest: 'deploy',
					ext: '.js',
					rename:(dest, src)=>
						return src.replace(/_(.*)\.js$/,"$1.js" )
					]

		sass:
			maincss:
				options:
					style: 'expanded'
				files:[
					expand: true,
					cwd: 'source',
					src: ['**/*.scss', '!**/_*.scss'],
					dest: 'deploy',
					ext: '.css']

		uglify:
			minifyjs:
				files:[
					expand: true,
					cwd: 'deploy/javascript',
					src: ['*.js', '!*.min.js'],
					dest: 'deploy/javascript',
					ext: '.min.js']
					
		cssmin: 
			minifycss: 
				expand: true,
				cwd: 'deploy/stylesheet/',
				src: ['*.css', '!*.min.css'],
				dest: 'deploy/stylesheet/',
				ext: '.min.css'

		watch:
			coffee:
				files:'source/**/*.coffee'
				tasks:['compile_coffee']
				options:
					livereload:true
			sass:
				files:'source/**/*.scss'
				tasks:['compile_sass']
				options:
					livereload:true
		
		'ftp-deploy':
			build:
				auth:
					host: '<%= pkg.name %>.dev-mex.com',
					port: 21,
					authKey: 'key1'
				src: 'deploy',
				dest: '/public_html',
				exclusions: ['deploy/**/.DS_Store', 'deploy/**/Thumbs.db', 'deploy/**/_*.*']


	#カスタムタスク

	#デフォルト
	grunt.registerTask 'compile_coffee', ['concat','coffee']
	grunt.registerTask 'compile_sass',['sass']
	grunt.registerTask 'minifyjs',['uglify', 'clean:expanded_js']
	grunt.registerTask 'minifycss',['cssmin', 'clean:expanded_css']
	grunt.registerTask 'publish_dev',['uglify', 'cssmin', 'ftp-deploy']


