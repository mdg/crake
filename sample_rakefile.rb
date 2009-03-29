require '../crake'

PROGRAM = CFileList.new()
PROGRAM.include( 'include' )
PROGRAM.compile( 'lib' )
TEST = CFileList.new()
TEST.include( 'include' )
TEST.include( 'lib' )
TEST.compile( 'test' )

CC = GppCompiler.new()

PROJECT = CProject.new()
PROJECT.cc = CC
# primary build
PROJECT.compile( SRC, 'obj', false )
PROJECT.compile( SRC ).to( 'obj' )
# debug build
PROJECT.compile( SRC, 'dbg', true )
PROJECT.compile( SRC ).to( 'dbg' ).debug!
# test build
PROJECT.compile( SRC, 'dbg', true )
PROJECT.compile( TEST, 'dbg', true )
PROJECT.compile( SRC ).to( 'dbg' ).debug!
PROJECT.compile( TEST ).to( 'dbg' ).debug!

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

