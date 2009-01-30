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

require 'rake'
require 'pathname'


# module Crake

# Files included in the C project
class CFileList
	attr_reader :inc
	attr_reader :src
	attr_reader :obj
	attr_reader :obj_path


	def initialize()
		@inc = Array.new()
		@src = FileList.new()
		@obj = FileList.new()
		@obj_path = nil
		@obj_to_src_map = Hash.new()

		# this should probably be injected, not created here
		@dep_lookup = CDependency.new()
	end

	def initialize(*args)
		@inc = Array.new()
		@src = FileList.new()
		@obj = FileList.new()
		@obj_path = nil
		@obj_to_src_map = Hash.new()

		# this should probably be injected, not created here
		@dep_lookup = CDependency.new()
	end

	# Include a path in the include directory.
	def include( inc_path )
		@inc << inc_path
	end

	# Add a set of files that should be compiled as described by the
	# given glob
	def compile( glob )
		files = FileList[ glob ]
		@src.import( files )
		for f in files.each
			# this needs to handle any extension, not just .cpp
			obj = f.sub( /\.cpp$/, '.o' )
			@obj << obj
			@obj_to_src_map[ obj ] = f
		end
	end

	# Get the dependencies for an object file.
	def deps( obj_file )
		dep_list = []
		c_file = obj_to_src( obj_file )
		headers = @dep_lookup.headers( c_file, @inc )
		dep_list << c_file
		dep_list.import( headers )
		return dep_list
	end

	# Return the mapped source file for a given object file
	def obj_to_src( obj_file )
		return @obj_to_src_map[ obj_file ]
	end

	class << self
		def [](*args)
			new(*args)
		end
	end
end


# Scan C files and find header dependencies
class CDependency
	# this unnecessary for now attr_reader :header_cache


	# This function should probably be modified to use yield
	# somehow.  Haven't quite got yield figured out
	# enough for that yet though.
	def headers( src_filename, inc_dirs )
		header_list = []

		p = Pathname.new( src_filename )
		path_prefix = p.dirname.to_s + "/"
		# print path_prefix, "\n"
		src_file = File.new( src_filename, "r" )
		src_file.each do |line|
			# print line
			inc = line.match( /#include +"([\w]+\.h)"/ )
			if ( ! inc.nil? )
				# inc_path = path_prefix + inc[1]
				inc_path = header_path( inc[1], inc_dirs )
				if not inc_path.nil?
					# print inc_path, "\n"
					header_list << inc_path
					included_headers = headers( inc_path \
								   , inc_dirs )
					header_list.import( included_headers )
				end
			end
		end
		return header_list.uniq
	end

	# Check if the given line of text includes an include statement
	# return the included header if one is found,
	# return nil if the line does not have an include statement
	# throw an error if it is an include line but it is not understood
	def find_include( line )
		inc = line.match( /#include +"([\w]+\.h)"/ )
		# return true if the include is found
		return ( not inc.nil? )
	end

	# Check for an included file in the given include directories
	def header_path( inc, inc_dirs )
		# print "inc_dirs = '", inc_dirs, "'\n"
		inc_dirs.each do |inc_dir|
			path = Pathname.new( inc_dir )
			path = path + inc
			# print "path = '", path, "'\n"
			if path.exist?
				return path.to_s
			end
		end
		return nil
	end
end

# end # Module Crake

