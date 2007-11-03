#!/bin/sh
# use to facilitate resources tarballing after generating them
# enjoy :p

assemble() {
	local dest=titi
	mkdir dest
	for i in $(find . -name generated-resources|sed -re "s:(/target)|(\./)::g");
	do
		local maven_dest="$dest/$(dirname $i)/src/main"
		echo assemble "$i"
		mkdir -p  "$maven_dest"
		cp -rf \
		"$(echo $i|sed -re "s:generated-resources:target/generated-resources:g")/plexus" \
		"$maven_dest/resources"
	done
 	for i in $(find . -name generated-sources|sed -re "s:(/target)|(\./)::g");
	do
		local maven_dest="$dest/$(dirname $i)/src/main"
		echo assemble "$i"
		mkdir -p  "$maven_dest"
		cp -rf \
		"$(echo $i|sed -re "s:generated-sources:target/generated-sources:g")/modello" \
		"$maven_dest/java"
	done 
}

assemble

