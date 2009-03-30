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

CC = GppCompiler.new()

# Release and debug compilers
RELEASE = CompileContext.new( 'obj' )
DEBUG = CompileContext.new( 'dbg' ).debug!

PROJECT.add_context( RELEASE )
PROJECT.add_context( DEBUG )


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
	PROJECT.compile( obj.name )
end

# modifies any subsequent tasks to compile w/ debug options
task :debug do
	PROJECT.debug = true
	PROJECT.obj_dir = 'dbg'
end

task :compile => PROJECT.compile_dependencies

task :build => :compile do
	PROJECT.link( "program" )
end

task :build_test => [ :debug, :compile_test ] do
	PROJECT.link( "test_program", 'testpp' )
end

task :lib => :compile do
	PROJECT.archive( "object", CC.objects )
end

task :clean do
	sh "rm -rf obj"
	sh "rm -rf dbg"
end

