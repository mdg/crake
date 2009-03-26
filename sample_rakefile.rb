require '../crake'

SRC = CFileList.new()
SRC.include( 'include' )
SRC.compile( 'lib/**/*.cpp' )
SRC.obj_dir = 'obj/lib'
TEST = CFileList.new()
TEST.include( 'include' )
TEST.compile( 'test/**/*.cpp' )
TEST.obj_dir = 'obj/test'
CC = CTask.new()
CC.include( 'include' )
CC.compile( 'lib/**/*.cpp' )
CC.obj_dir = 'obj/lib'


directory SRC.obj_dir
directory TEST.obj_dir

task :default => :lib

task :lib => :compile do
	CC.archive( "object", CC.objects )
end

task :debug do
	CC.debug = true
end

task :test => [ :compile, :compile_test ] do
	CC.compile( 'lib/**/*.cpp' )
	CC.obj_dir = 'obj/test'
end

task :build do
	CC.link( "program" )
end

task :compile => CC.compile_tasks

rule '.o' => CC.dependencies( obj.name ) do |obj|
	CC.compile( obj.name, obj.source )
end

task "program" => :build

task :clean => [] do
	sh "rm -rf obj"
end

