#! /bin/sh
#
# This script launch the Jext the Java text editor.
# It checks for a $HOME/.jext directory and eventually creates it.
# Next it checks for a $HOME/.jext/variables file which define the JEXT_HOME JAVA_CMD and JAVA_OPT variables.
# If this file doesn't exist the script creates it by asking the options to the user.


# Sharpshooter 23/02/2002
# Modified by Todd Berman <tberman@gentoo.org> 23/05/2003

# Help

if  [ "$1" = "--help" ]
then
	echo "This script launch Jext the Java text editor."
	echo "Usage : $0 [files]"
	exit 0
fi



# Check for the user's ~/.jext directory.
if ! [ -d ~/.jext ]
then
	echo "It seems you don't have a .jext directory in your home dir."
	echo "I create it."
	echo
	mkdir -p ~/.jext/xinsert

fi



# Check for the $HOME/.jext/variables file.
if ! [ -f ~/.jext/variables ]
then
	echo "JEXT_HOME="/usr/share/jext/lib > ~/.jext/variables
	echo "JAVA_CMD=java" >>~/.jext/variables
fi


# Extract the contents of the ~/.jext/variables file.
JEXT_HOME=`grep JEXT_HOME ~/.jext/variables | cut -f2 -d=`
JAVA_CMD=`grep JAVA_CMD ~/.jext/variables | cut -f2 -d=`
JAVA_OPT=`grep JAVA_OPT ~/.jext/variables | cut -f2 -d=`


# Launch JEXT
exec "$JAVA_CMD" $JAVA_OPTS -Dpython=`java-config --classpath=jython` -classpath "`java-config --classpath=jython,jext`" org.jext.Jext "$@"
