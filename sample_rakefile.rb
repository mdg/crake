require '../crake'

# application source
APP_SRC = CFileList.new()
APP_SRC.include( 'include' )
APP_SRC.compile( 'lib' ).exclude!( 'main.cpp' )
# main is separate for not including in the test app
APP_MAIN = CFileList.new()
APP_MAIN.include( 'include' )
APP_MAIN.compile( 'lib' ).filter!( 'main.cpp' )
# test source
TEST_SRC = CFileList.new()
TEST_SRC.include( 'include' )
TEST_SRC.include( 'lib' )
TEST_SRC.compile( 'test' )

# Group files into targets
APP_FILES = [ APP_SRC, APP_MAIN ]
TEST_FILES = [ APP_SRC, TEST_SRC ]

# Release and debug compilers
RELEASE = CompileContext.new( 'obj' )
DEBUG = CompileContext.new( 'dbg' ).debug!

# The compiler class, RELEASE is the default context
CC = GppCompiler.new()
CC.context = RELEASE
CC.files = [ APP_SRC, APP_MAIN ]

# The project?
PROJECT = CProject.new()
PROJECT.context = [ RELEASE, DEBUG ]
PROJECT.files = [ APP_SRC, APP_MAIN, TEST_SRC ]


# default is to build the program
task :default => :build

# build the program
task "program" => :build

# build & run the tests
task :test => [ :build_test ] do
	sh "./test_program"
end



# Rule to compile each object
rule '.o' => PROJECT.object_dependencies( obj.name ) do |obj|
	CC.compile( obj.name )
end

# modifies any subsequent tasks to compile w/ debug options
task :debug do
	CC.context = DEBUG
end

task :compile => PROJECT.compile_dependencies

task :build => :compile do
	CC.link( "program", FILES )
end

task :build_test => [ :debug, :compile_test ] do
	CC.link( "test_program", 'testpp' )
end

task :lib => :compile do
	CC.library( "object", CC.objects )
end

task :clean do
	sh "rm -rf obj"
	sh "rm -rf dbg"
end

