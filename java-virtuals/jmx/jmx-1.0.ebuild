# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-virtuals-2

DESCRIPTION="Java Management Extension"
HOMEPAGE="http://java.sun.com/javase/technologies/core/mntr-mgmt/javamanagement/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="|| ( >=virtual/jre-1.5 dev-java/sun-jmx )
		>=dev-java/java-config-2.1.4"

JAVA_VIRTUAL_VM="sun-jdk-1.6 sun-jdk-1.5 ibm-jdk-bin-1.6
				sun-jre-1.6	sun-jre-1.5 ibm-jre-bin-1.6"
JAVA_VIRTUAL_PROVIDES="sun-jmx"
