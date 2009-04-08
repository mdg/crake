#! /usr/bin/ruby

require "../crake.rb"
require "test/unit"


# Test the CTarget class features that don't require file system access.
class CTargetTestCase < Test::Unit::TestCase

	def setup
		@target = CTarget.new()
	end

	def teardown
		@target = nil
	end

	def test_constructor()
		assert_equal( [], @target.incs )
		assert( ! @target.debug? )
	end

	def test_target_include()
		@target.include( 'include' )
		@target.include( 'src' )

		assert_equal( ['include','src'], @target.incs )
	end

	# Test that an array of include paths is correctly added to the array
	def test_multi_include
		@target.include( ['include', 'testpp/include'] )

		assert_equal( ['include', 'testpp/include'], @target.incs )
	end

	# test that debug! properly sets the debug flag
	def test_set_debug()
		@target.debug!
		assert( @target.debug? )
	end

end


# CTarget tests using the test project 1
class CTargetTP1TestCase < Test::Unit::TestCase

	def setup
		@tp1 = CTarget.new()
		@tp1.include( 'tp1-include' )
		@tp1.compile( 'tp1-src' )
		@tp1.obj_dir = 'tp1-obj'
	end

	def teardown
		@tp1 = nil
	end

	# test that the objects are being generated correctly from source
	def test_tp1_objects()
		assert_equal( [ 'tp1-obj/tp1-src/file.o' ], @tp1.objects )
	end

	# Test that the dependencies function finds source and header
	# dependencies correctly.
	def test_tp1_dependencies()
		assert_equal( [ 'tp1-src/file.cpp', 'tp1-include/file.h' \
			     , 'tp1-include/framework.h' ] \
			     , @tp1.dependencies( 'tp1-obj/tp1-src/file.o' ) )
	end

	# test the source->object conversion for test project 1
	def test_tp1_src_to_obj()
		obj = @tp1.src_to_obj( 'tp1-src/file.cpp' )
		assert_equal( 'tp1-obj/tp1-src/file.o', obj )
	end

	# test the object->source conversion for test project 1
	def test_tp1_obj_to_src()
		src = @tp1.obj_to_src( 'tp1-obj/tp1-src/file.o' )
		assert_equal( 'tp1-src/file.cpp', src )
	end

end


class CFileListTestCase < Test::Unit::TestCase

	def setup
	end

	def teardown
	end

	def test_construction
		cfiles = CFileList.new( 'asdf' )
		assert_equal( 'asdf', cfiles.src_root )
		assert_equal( [], cfiles.inclusion )
		assert_equal( [], cfiles.exclusion )
	end

	def test_tp1_file_list
		cfiles = CFileList.new( 'tp1-src' )

		assert_equal( [ "tp1-src/file.cpp" ], cfiles.files )
	end

end


# Test cases for the CDependency class
class CDependencyTestCase < Test::Unit::TestCase
	def setup
		@dep = CDependency.new()
		@tp1_inc = ['tp1-include']
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
		inc_path = @dep.header_path( 'file.h', @tp1_inc )
		assert_equal( 'tp1-include/file.h', inc_path )
	end

	def test_headers
		deps = @dep.headers( 'tp1-src/file.cpp', @tp1_inc )
		assert_equal( [ 'tp1-include/file.h' \
				, 'tp1-include/framework.h' ] \
				, deps )
	end
end


class MockCCompiler < CCompiler
	attr_reader :command_history
	attr_reader :last_command

	def exec( cmd )
		if not @command_history
			@command_history = []
			@last_command = nil
		end
		@last_command = cmd
		@command_history << @last_command
	end
end

# Tests for the CCompiler class
class CCompilerTestCase < Test::Unit::TestCase

	def setup()
		@cc = CCompiler.new()
		@mock_cc = MockCCompiler.new()
	end

	def teardown()
		@cc = nil
		@mock_cc = nil
	end

	# Test that the debug flag is correct when debugging
	def test_debug_flag_true()
		assert_equal( ' -g', @cc.debug_flag( true ) )
	end

	# Test that the debug flag is correct when not debugging
	def test_debug_flag_false()
		assert_equal( '', @cc.debug_flag( false ) )
	end

	# Test that the include flags are created correctly for an array
	# of directories.
	def test_include_flags()
		flags = @cc.include_flags( [ 'include', 'lib', 'test' ] )
		assert_equal( ' -Iinclude -Ilib -Itest', flags )
	end

	# Test that the lib flags are created correctly for an array
	# of directories.
	def test_lib_flags()
		flags = @cc.lib_flags( [ 'testpp', 'pthread' ] )
		assert_equal( ' -ltestpp -lpthread', flags )
	end

end

# Integration tests for entire crake behavior
class CrakeIntegrationTestCase < Test::Unit::TestCase

	def setup()
	end

	def teardown()
	end

	def test_tp1()
		target = CTarget.new()
		target.include( 'tp1-include' )
		target.compile( 'tp1-src' )
		target.obj_dir = 'obj'

		cc = MockCCompiler.new()

		project = CProject.new()
		project.targets = [ target ]
		project.cc = cc

		project.compile( 'obj/tp1-src/file.o' )

		assert_equal( "g++   -Itp1-include -o obj/tp1-src/file.o tp1-src/file.cpp" \
			     , cc.last_command )
	end

end

