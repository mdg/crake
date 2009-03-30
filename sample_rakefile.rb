require '../crake'

# The compiler class, RELEASE is the default context
CC = GppCompiler.new()
CC.context = RELEASE
CC.files = APP_FILES

# The project?
PROJECT = CProject.new()
PROJECT.context = [ RELEASE, DEBUG ]
PROJECT.files = [ APP_SRC, APP_MAIN, TEST_SRC ]

APP = CTarget.new()
APP.include( 'include' )
APP.compile( 'src' )
APP.obj_dir = 'obj/app'

DEBUG_APP = APP.debug
DEBUG_APP = 'obj/dbg'

TEST = CTarget.new()
TEST.include( 'include' )
TEST.compile( 'src' ).filter( 'main.cpp' )
TEST.compile( 'test' )
TEST.obj_dir = 'obj/test'


# default is to build the program
task :default => :build

# build the program
task :build => "program"

task :build_test => "test_program"

# build & run the tests
task :test => [ :test_context, :build ] do
	sh "./test_program"
end


# Rule to compile each object
rule '.o' => CC.object_dependencies( obj.name ) do |obj|
	CC.compile( obj.name )
end

task :compile => CC.compile_dependencies

task "program" => :compile do
	CC.link( "program" )
end

task "test_program" => [ :debug, :test_context, :compile_test ] do
	CC.link( "test_program", 'testpp' )
end

task :lib => :compile do
	CC.library( "object" )
end

task :clean do
	sh "rm -rf obj"
	sh "rm -rf dbg"
end

