
require "../crake.rb"
require "test/unit"

class TC_CFileSet < Test::Unit::TestCase
	def setup
		@cfiles = CFileSet.new()
	end

	def test_construction
		assert_equal( [], @cfiles.inc )
		assert_equal( [], @cfiles.src )
		assert_equal( [], @cfiles.obj )
		assert_equal( true, @cfiles.obj_path.nil? )
	end

	def test_include
		@cfiles.include( "include" )
		@cfiles.include( "testpp/include" )

		assert_equal( [ "include", "testpp/include" ], @cfiles.inc )
	end

	def test_compile
		@cfiles.compile( "../cpp_project/lib/**/*.cpp" )

		assert_equal( [ "../cpp_project/lib/object.cpp" ], @cfiles.src )
		assert_equal( [ "../cpp_project/lib/object.o" ], @cfiles.obj )
		assert_equal( "../cpp_project/lib/object.cpp" \
		       , @cfiles.obj_to_src( "../cpp_project/lib/object.o" ) )
	end

end

