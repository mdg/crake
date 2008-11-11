require 'rake'

INC = FileList[ 'include/**/*.h' ]
SRC = FileList[ 'lib/**/*.cpp' ]
OBJ = SRC.sub( /\.cpp$/, '.o' ).sub( /^lib\//, 'obj/lib/' )
TEST = FileList[ 'test/**/*.cpp' ]

directory 'obj/lib'

task :default => :lib

task :lib => :compile

task :compile => ["obj/lib"] + OBJ

rule '.o' => SRC do |t|
	sh %{g++ -c -g -Iinclude -o #{t.name} #{t.source}}
end

task :clean => [] do
	sh "rm -rf obj"
end

