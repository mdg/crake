require '../crake'

SRC = CFileList.new()
SRC.include( 'include' )
SRC.compile( 'lib/**/*.cpp' )
SRC.obj_dir = 'obj/lib'
TEST = CFileList.new()
TEST.include( 'include' )
TEST.compile( 'test/**/*.cpp' )
TEST.obj_dir = 'obj/test'


directory SRC.obj_dir
directory TEST.obj_dir

task :default => :lib

task :lib => :compile do
	CC.archive( "object.a", SRC.objects )
end

task :test => [ :compile, :compile_test ] do
	CC.link( "run-test", [SRC, TEST] )
end

task :compile => SRC.compile_tasks

task :compile_test => TEST.compile_tasks

rule '.o' => PROJECT.dependencies( obj.name ) do |obj|
	CC.compile( obj.name, obj.source )
end

task "program" => :compile

task :clean => [] do
	CC.clean( PROJECT.output_files )
end

