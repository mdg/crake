
require "../crake.rb"
require "test/unit"


class CFileSetTestCase < Test::Unit::TestCase
	def setup
		@cfiles = CFileSet.new()
	end

	def teardown
		@cfiles = nil
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

	def test_multi_include
		@cfiles.include( ['include', 'testpp/include'] )

		assert_equal( ['include', 'testpp/include'], @cfiles.inc )
	end

	def test_compile
		@cfiles.compile( "../cpp_project/lib/**/*.cpp" )

		assert_equal( [ "../cpp_project/lib/object.cpp" ], @cfiles.src )
		assert_equal( [ "../cpp_project/lib/object.o" ], @cfiles.obj )
		assert_equal( "../cpp_project/lib/object.cpp" \
		       , @cfiles.obj_to_src( "../cpp_project/lib/object.o" ) )
	end

	def test_creation
		f = CFileSet['dog']
	end

end


# Test cases for the CDependency class
class CDependencyTestCase < Test::Unit::TestCase
	def setup
		@inc = [ '../cpp_project/include' ]
		@dep = CDependency.new()
	end

	def teardown
		@dep = nil
	end

	# Test that the include function works in the most simple case
	def test_find_include_0
		inc = @dep.find_include( '#include "file.h"' )
		assert( inc, 'include is found' )
	end

	# Test that the header_path function works for the basic case.
	def test_header_path
		inc_path = @dep.header_path( 'abc/object.h', @inc )
		assert_equal( '../cpp_project/include/abc/object.h', inc_path )
	end

	def test_headers
		deps = @dep.headers( '../cpp_project/lib/object.cpp', @inc )
		# assert_equal( [ '../cpp_project/include/abc/object.h' \
		#		, '../cpp_project/include/abc/obj_test.h' ] \
		#		, deps )
	end
end

