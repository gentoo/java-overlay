# -----------------------------------------------------------------------------
#  Set CLASSPATH and Java options
#
#  $Id: setclasspath.sh,v 1.7.2.1 2004/08/21 15:49:50 yoavs Exp $
# -----------------------------------------------------------------------------

# Make sure prerequisite environment variables are set
if [ -z "$JAVA_HOME" ]; then
  echo "The JAVA_HOME environment variable is not defined"
  echo "This environment variable is needed to run this program"
  exit 1
fi

if [ ! -x "$JAVA_HOME"/bin/java -o ! -x "$JAVA_HOME"/bin/jdb -o ! -x "$JAVA_HOME"/bin/javac ]; then
  echo "The JAVA_HOME environment variable is not defined correctly"
  echo "This environment variable is needed to run this program"
  echo "NB: JAVA_HOME should point to a JDK not a JRE"
  exit 1
fi

if [ -z "$BASEDIR" ]; then
  echo "The BASEDIR environment variable is not defined"
  echo "This environment variable is needed to run this program"
  exit 1
fi

if [ ! -x "$BASEDIR"/bin/setclasspath.sh ]; then
  echo "The BASEDIR environment variable is not defined correctly"
  echo "This environment variable is needed to run this program"
  exit 1
fi

# Set the default -Djava.endorsed.dirs argument
JAVA_ENDORSED_DIRS="$BASEDIR"/common/endorsed

# Set standard CLASSPATH
CLASSPATH="${CLASSPATH}":"$JAVA_HOME"/lib/tools.jar

# Set standard commands for invoking Java.
_RUNJAVA="$JAVA_HOME"/bin/java
_RUNJDB="$JAVA_HOME"/bin/jdb
_RUNJAVAC="$JAVA_HOME"/bin/javac
