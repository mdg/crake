require '../crake'

INC = FileList[ 'include/**/*.h' ]
SRC = FileList[ 'lib/**/*.cpp' ]
OBJ = SRC.sub( /\.cpp$/, '.o' ).sub( /^lib\//, 'obj/lib/' )
TEST = FileList[ 'test/**/*.cpp' ]
TEST_OBJ = TEST.sub( /\.cpp$/, '.o' ).sub( /^test\//, 'obj/test/' )


directory 'obj/lib'
directory 'obj/test'

task :default => :lib

task :lib => :compile do
	sh %{ar r object.a #{OBJ}}
end

task :test => [ :compile, :compile_test ] do
	sh %{g++ -o run-test #{OBJ} #{TEST_OBJ}}
	# sh %{g++ -o run-test #{OBJ} -Iinclude test/object_test.cpp}
end

task :compile => ["obj/lib"] + OBJ

task :compile_test => ['obj/test'] + TEST_OBJ

rule '.o' => TEST + SRC do |t|
	print %{#{t.name} #{t.source}\n}
	sh %{g++ -c -g -Iinclude -o #{t.name} #{t.source}}
end

task :clean => [] do
	sh "rm -rf obj *.a"
end

