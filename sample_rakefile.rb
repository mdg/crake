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

# build the debug program
task :debug_build => "debug_program"

# build the tests
task :test_build => "test_program"

# build & run the tests
task :test => [ :build_test ] do
	sh "./test_program"
end


# Rule to compile each object
rule '.o' => CC.object_dependencies( obj.name ) do |obj|
	CC.compile( obj.name )
end

task "program" => APP.compile_dependencies do
	CC.link( "program", APP )
end

task "debug_program" => DEBUG_APP.compile_dependencies do
	CC.link( "debug_program", DEBUG_APP )
end

task "test_program" => TEST_APP.compile_dependencies do
	CC.link( "test_program", TEST_APP )
end

task :lib => :compile do
	CC.library( "object" )
end

task :clean do
	sh "rm -rf obj"
	sh "rm -rf dbg"
end

