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


# Files included in the C project
class CFileSet
	attr_reader :inc
	attr_reader :src
	attr_reader :obj
	attr_reader :obj_path
	@dep_lookup


	def initialize()
		@inc = Array.new()
		@src = FileList.new()
		@obj = FileList.new()
		@obj_path = nil
		@obj_to_src_map = Hash.new()
	end

	# Include a path in the include directory.
	def include( inc_path )
		@inc << inc_path
	end

	# Add a set of files that should be compiled as described by the
	# given glob
	def compile( glob )
		files = FileList[ glob ]
		@src << files
	end

	# Get the dependencies for an object file.
	def deps( obj_file )
		dep_list = []
		c_file = @obj_to_src[ obj_file ]
		headers = @dep_lookup.headers( c_file, @inc )
		dep_list << c_file
		dep_list << headers
		return dep_list
	end

	def obj_to_src( obj_file )
		return @obj_to_src_map[ obj_file ]
	end
end


# Scan C files and find header dependencies
class CDependency
	# this unnecessary for now attr_reader :header_cache


	def headers( src_file, inc_dirs )
	end
end

