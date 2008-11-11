
require "../crake.rb"
require "test/unit"

class TC_CFileSet < Test::Unit::TestCase
	def setup
		@cfiles = CFileSet.new()
	end

	def test_construction
		assert( [], @cfiles.inc )
		assert( [], @cfiles.src )
		assert( [], @cfiles.obj )
		assert( true, @cfiles.obj_path.nil? )
	end

	def test_include
		@cfiles.include( "include" )
		@cfiles.include( "testpp/include" )

		assert( [ "include", "testpp/include" ], @cfiles.inc )
	end

	def test_compile
		@cfiles.compile( "../cpp_project/lib/**/*.cpp" )

		assert( [ "../cpp_project/lib/object.cpp" ], @cfiles.src )
		assert( [ "../cpp_project/lib/object.o" ], @cfiles.obj )
		assert( "../cpp_project/lib/object.cpp" \
		       , @cfiles.obj_to_src( "../cpp_project/lib/object.o" ) )
	end

end

