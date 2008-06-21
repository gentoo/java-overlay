# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-virtuals-2

DESCRIPTION="Java JDK tools"
HOMEPAGE="http://java.sun.com/javase"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="|| ( dev-java/sun-jdk dev-java/blackdown-jdk dev-java/ibm-jdk-bin dev-java/jrockit-jdk-bin dev-java/diablo-jdk )"

JAVA_VIRTUAL_VM=`echo sun-jdk-1.{4,5,6} blackdown-jdk-1.4 ibm-jdk-bin-1.{4,5,6} jrockit-jdk-bin-1.{4,5} diablo-jdk-1.5`
JAVA_VIRTUAL_VM_CLASSPATH="/lib/tools.jar"
