#!/usr/bin/ruby

#This script should be run in ${S} after src_unpack

require "find"
path = ARGV[0] || '.'

puts "Prints the symlinks for which there isn't a scrambled file and"
puts "the scrambled files for which there isn't a symlink."

Find.find(path) { |file|
	
	if (FileTest.symlink? file)
		if(! FileTest.exist? file+".scrambled")
			puts file
		end
	end
	
	if(file.match /scrambled$/)
		if(! FileTest.exist? file.gsub(/scrambled$/, '') )
			puts file
		end
	end
}

puts "Find finished."
