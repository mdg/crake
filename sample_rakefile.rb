require '../crake'


APP = CTarget.new()
APP.name = 'program'
APP.include( 'include' )
APP.compile( 'src' )
APP.obj_dir = 'obj/app'

DEBUG_APP = APP.debug
DEBUG_APP.name = 'debug_program'
DEBUG_APP.obj_dir = 'obj/dbg'

TEST = CTarget.new()
TEST.name = 'testpp'
TEST.debug!
TEST.include( 'include' )
TEST.compile( 'src' ).filter( 'main.cpp' )
TEST.compile( 'test' )
TEST.obj_dir = 'obj/test'

CC = CProject.new()
CC.cc = GppCompiler.new()
CC.targets = [ APP, DEBUG_APP, TEST ]


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
	CC.link( APP )
end

task "debug_program" => DEBUG_APP.compile_dependencies do
	CC.link( DEBUG_APP )
end

task "test_program" => TEST_APP.compile_dependencies do
	CC.link( TEST_APP )
end

# task :lib => LIB.compile_dependencies do
#	CC.library( "object" )
# end

task :clean do
	sh "rm -rf obj"
	sh "rm -rf dbg"
end

