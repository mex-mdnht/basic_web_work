module.exports = (grunt) ->
	"use strict"

	#パッケージ情報読み込み
	pkg = grunt.file.readJSON 'package.json'
	
	#upするディレクトリ
	deploydest = ""
	
	#全てのnpmタスク読み込み
	for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
		grunt.loadNpmTasks taskName

	#各タスク設定
	grunt.initConfig
		#テンプレートに設定引き継ぎ
		pkg: pkg

		#concat:
		concat:
			coffee_main:
				src: ['source/javascript/main/*.coffee']
				dest: 'source/javascript/_main.coffee'

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
					dest: 'source',
					ext: '.js',
					rename:(dest, src)=>
						return dest+"/"+src.replace(/_(.*)\.js$/,"$1.js" )
					]

		sass:
			maincss:
				options:
					style: 'expanded'
				files:[
					expand: true,
					cwd: 'source',
					src: ['**/*.scss', '!**/_*.scss'],
					dest: 'source',
					ext: '.css']

		uglify:
			minifyjs:
				files:[
					expand: true,
					cwd: 'source/javascript',
					src: ['*.js', '!*.min.js'],
					dest: 'deploy/javascript',
					ext: '.js']
					
		cssmin: 
			minifycss: 
				expand: true,
				cwd: 'source/stylesheet/',
				src: ['*.css', '!*.min.css'],
				dest: 'deploy/stylesheet/',
				ext: '.css'
		
		#server
		connect:
			server:
				options:
					hostname: "*"
					port: 9500
					base: 'source'
					livereload: true

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
		
		imagemin:
			minallimgs:
				files: [
					expand: true,
					cwd: 'source',
					src: ['**/*.{png,gif}'],
					dest: 'deploy']

		'ftp-deploy':
			build:
				auth:
					host: '<%= pkg.name %>.dev-mex.com',
					port: 21,
					authKey: 'key1'
				src: 'deploy',
				dest: '/public_html',
				exclusions: ['deploy/**/.DS_Store', 'deploy/**/Thumbs.db', 'deploy/**/_*.*']

		compress:
			main:
				options:
					archive:()=>
						dd = new Date()
						yy = dd.getYear()
						mm = dd.getMonth() + 1
						dd = dd.getDate()
						if (yy < 2000) then  yy += 1900
						if (mm < 10) then mm = "0" + mm
						if (dd < 10) then dd = "0" + dd
						dateString = yy.toString()+mm.toString()+dd.toString()
						return 'archive/'+pkg.name+dateString+'.zip'
				files: [
					expand: true,
					cwd: 'deploy/',
					src: ['**'],
					dest: deploydest
				]

		copy:
			html:
				files: [
					expand: true,
					cwd: 'source',
					src: ['*.html'],
					dest: 'deploy/',
					filter: 'isFile'
				]


	#カスタムタスク

	#デフォルト
	grunt.registerTask 'compile_coffee', ['concat','coffee']
	grunt.registerTask 'compile_sass',['sass']
	grunt.registerTask 'minifyjs',['uglify', 'clean:expanded_js']
	grunt.registerTask 'minifycss',['cssmin', 'clean:expanded_css']
	grunt.registerTask 'deploy',['uglify', 'cssmin', 'imagemin', 'copy:html']
	grunt.registerTask 'server', ['compile_sass', 'compile_coffee', 'connect', 'watch']


