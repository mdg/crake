require '../crake'

SRC = CFileList.new()
SRC.include( 'include' )
SRC.compile( 'lib', 'cpp' )
SRC.obj_dir = 'obj/lib'
TEST = CFileList.new()
TEST.include( 'include' )
TEST.compile( 'test', 'cpp' )
TEST.obj_dir = 'obj/test'

CC = GppCompiler.new( SRC )


directory SRC.obj_dir
directory TEST.obj_dir

task :default => :lib

rule '.o' => CC.object_dependencies( obj.name ) do |obj|
	CC.compile( obj.name )
end

task :debug do
	CC.debug = true
end

task :test => [ :compile, :compile_test ] do
	CC.files = TEST
end

task :compile => CC.compile_dependencies

task :build => :compile do
	CC.link( "program" )
end

task :lib => :compile do
	CC.archive( "object", CC.objects )
end

task "program" => :build

task :clean do
	sh "rm -rf obj"
end

