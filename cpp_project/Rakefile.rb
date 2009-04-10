require '../crake'

APP = CTarget.new()
APP.name = 'app'
APP.include( 'include' )
APP.compile( 'lib' )
APP.obj_dir = 'obj/app'
TEST = CTarget.new()
TEST.name = 'test_app'
TEST.include( 'include' )
TEST.compile( 'lib' ).exclusion << 'main.cpp'
TEST.compile( 'test' )
TEST.link( 'testpp' )
TEST.obj_dir = 'obj/test'
TEST.debug!

PROJECT = CProject.new()
PROJECT.cc = CCompiler.new()
PROJECT.targets = [ APP, TEST ]


directory 'obj/app'
directory 'obj/app/lib'
directory 'obj/test'
directory 'obj/test/lib'
directory 'obj/test/test'

task :default => :app

task :app => :compile_app do
	PROJECT.link( APP )
end

task :lib => :compile do
	# sh %{ar r object.a #{OBJ}}
end

task :test => :test_app do
	sh "test_app"
end

task :test_app => :compile_test do
	PROJECT.link( TEST )
end

task :compile_app => ["obj/app", 'obj/app/lib'] + APP.objects

task :compile_test => ['obj/test'] + TEST.objects

rule '.o' => [ proc { |o| PROJECT.dependencies( o ) } ] do |t|
	PROJECT.compile( t.name )
end

task :clean => [] do
	sh "rm -rf obj *.a"
end

