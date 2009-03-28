require '../crake'

SRC = CFileList.new()
SRC.include( 'include' )
SRC.compile( 'lib', 'cpp' )
TEST = CFileList.new()
TEST.include( 'include' )
TEST.compile( 'test', 'cpp' )

CC = GppCompiler.new()

PROJECT = CProject.new()
PROJECT.cc = CC
PROJECT.files = SRC
PROJECT.obj_dir = 'obj'


directory SRC.obj_dir
directory TEST.obj_dir

task :default => :lib

rule '.o' => PROJECT.object_dependencies( obj.name ) do |obj|
	PROJECT.compile( obj.name )
end

task :debug do
	PROJECT.debug = true
	PROJECT.obj_dir = 'dbg'
end

task :test => [ :compile, :compile_test ] do
	PROJECT.files = TEST
end

task :compile => PROJECT.compile_dependencies

task :build => :compile do
	PROJECT.link( "program" )
end

task :lib => :compile do
	PROJECT.archive( "object", CC.objects )
end

task "program" => :build

task :clean do
	sh "rm -rf obj"
end

