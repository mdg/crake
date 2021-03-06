# Copyright 2008 Matthew Graham
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'pathname'
require 'rake'


class CTarget
	attr_accessor :name
	attr_accessor :obj_dir
	attr_reader :incs
	attr_reader :libs
	attr_writer :debug


	def initialize()
		@name = ''
		@obj_dir = ''
		@incs = []
		@libs = []
		@src = []
		@debug = false
		@dependencies = CDependency.new()
	end

	def clone()
	end

	# Add a path to be included during compilation
	def include( path )
		@incs << path
		@incs.flatten!
	end

	# Compile a directory of source files.
	def compile( path )
		files = CFileList.new( path )
		@src << files
		return files
	end

	# Add a library that should be linked to the app.
	def link( lib_name )
		@libs << lib_name
	end


	# Set the debug flag for this target
	def debug!()
		@debug = true
	end

	# Check if this target is set for debug.
	def debug?()
		return @debug
	end


	# Get objects that need to be compiled for this target.
	def objects()
		objs = []
		@src.each do |s|
			s.each do |file|
				objs << src_to_obj( file )
			end
		end
		return objs
	end

	# Get source dependencies for an object files.
	def dependencies( obj )
		src = obj_to_src( obj )
		deps = [ src ]
		headers = @dependencies.headers( src, @incs )
		deps.concat( headers )
		return deps
	end


	# Map a source file to its corresponding object file.
	def src_to_obj( src )
		obj = @obj_dir +"/"+ src.sub( '.cpp', '.o' )
		return obj
	end

	# Map an object file to its corresponding source file.
	def obj_to_src( obj )
		src = obj.sub( '.o', '.cpp' )
		src.sub!( /^#{obj_dir}\//, '' )
		return src
	end

end


# module Crake

# Files included in the C project
class CFileList
	attr_accessor :src_root
	attr_accessor :inclusion
	attr_accessor :exclusion


	def initialize( src_root )
		@src_root = src_root
		@inclusion = []
		@exclusion = []
	end

	# Return each source file included by this file list
	def each()
		glob = @src_root
		if @inclusion.length > 0
			glob += ( '/'+ @inclusion[0] )
		else
			glob += ( '/**/*.cpp' )
		end
		files = FileList[ glob ]

		for f in files
			yield f if not excluded?( f )
		end
		return nil
	end

	def files()
		file_array = []
		each { |f| file_array << f }
		return file_array
	end

	def excluded?( filename )
		if not @exclusion
			return false
		end

		exclusion_match = filename.match( /#{@exclusion[0]}/ )
		return ! exclusion_match.nil?
	end

end


# Scan C files and find header dependencies
class CDependency

	# Create the dependency object
	def initialize()
	end


	def headers( filename, inc_dirs )
		header_list = []

		each_include( filename ) do |inc|
			inc_path = header_path( inc, inc_dirs )

			if ( ! inc_path.nil? )
				header_list << inc_path

				nested_headers = headers( inc_path, inc_dirs )
				header_list.concat( nested_headers )
			end
		end

		return header_list
	end

	def each_include( filename )
		# print "each_include( ", filename, " )\n"

		f = File.new( filename, "r" )
		for line in f.each
			inc = find_include( line )
			yield inc if ! inc.nil?
		end
	end

	# Check if the given line of text includes an include statement
	# return the included header if one is found,
	# return nil if the line does not have an include statement
	# throw an error if it is an include line but it is not understood
	def find_include( line )
		inc = /#include +"([\w]+\.h)"/.match( line )
		# return nil if nothing
		return nil if inc.nil?
		return inc.to_a[1]
	end

	# Check for an included file in the given include directories
	def header_path( inc, inc_dirs )
		inc_dirs.each do |inc_dir|
			path = Pathname.new( inc_dir )
			path = path + inc
			if path.exist?
				return path.to_s
			end
		end
		return nil
	end
end


class CProject
	attr_accessor :targets
	attr_accessor :cc

	def initialize()
		@targets = []
		@cc = nil
	end

	# Get dependencies for an object
	def dependencies( object )
		t = find_target( object )
		return t.dependencies( object )
	end

	# actually compile a file
	def compile( object )
		t = find_target( object )
		@cc.compile( object, t )
	end

	# Link a target
	def link( target )
		@cc.link( target )
	end

	# Not yet defined
	def library( target )
	end


	# Find the target for a given object file
	def find_target( object )
		for t in @targets
			return t if object.index( t.obj_dir ) == 0
		end
		return nil
	end

end


class CCompiler
	attr_accessor :cc

	def initialize()
		@cc = 'g++'
	end

	# actually compile a file
	def compile( object, target )
		cc_flags = debug_flag( target.debug? )
		inc_flags = include_flags( target.incs )
		src = target.obj_to_src( object )
		exec( "#{@cc} -c #{cc_flags} #{inc_flags} -o #{object} #{src}" )
	end

	# don't implement yet
	def link( target )
		objs = target.objects.join( ' ' )
		lib_flags = lib_flags( target.libs )
		exec( "#{@cc} -o #{target.name} #{lib_flags} #{objs}" )
	end

	# not implemented
	def archive( name, objects )
	end


	# return the debug flag for this compiler
	def debug_flag( debug )
		if not debug
			return ''
		end
		return ' -g'
	end

	# generate a string for the flags to say which paths
	# should be included
	def include_flags( includes )
		flags = ''
		includes.each do |i|
			flags += ' -I' + i
		end
		return flags
	end

	# generate a string for the library flags that should be
	# linked to the application
	def lib_flags( libs )
		flags = ''
		libs.each do |l|
			flags += ' -l' + l
		end
		return flags
	end

	# execute a command
	def exec( cmd )
		sh( cmd )
	end

end

# end # Module Crake

