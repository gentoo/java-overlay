#!/usr/bin/ruby

#This script should be run in ${S} after src_unpack

require "find"
path = ARGV[0] || '.'

puts "Prints the symlinks for which there isn't a scrambled file and"
puts "the scrambled files for which there isn't a symlink."

Find.find(path) { |file|
	
	if (FileTest.symlink? file)
		if(! FileTest.exist? file+".scrambled")
			puts 'No scrambled: ' + file
		end
	end
	
	if(file.match /scrambled$/)
		toMatch = file.gsub(/\.scrambled$/, '')
		if(! FileTest.exist? toMatch )
			puts 'No symlink: ' + file
		elsif(  ! FileTest.symlink? toMatch)
			puts 'Unscrambled: ' + file
	end
}

puts "Find finished."
