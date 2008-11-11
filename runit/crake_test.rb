
require "../crake.rb"
require "test/unit"

class TC_CFileSet < Test::Unit::TestCase
	def test_construction
		f = CFileSet.new()

		assert( [], f.inc )
		assert( [], f.src )
		assert( [], f.obj )
		assert( true, f.obj_path.nil? )
		assert( {}, f.obj_to_src )

		print "constructor worked.\n"
	end
end

