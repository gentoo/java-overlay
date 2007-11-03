# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2
DESCRIPTION="base poms for maven"
HOMEPAGE="http://maven.apache.org"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=">virtual/jdk-1.4"
RDEPEND=">virtual/jre-1.4"

S="${WORKDIR}"
src_unpack() {
	for i in "${FILESDIR}"/*xml; do
		cp $i ${S} || die
	done
	java-maven-2_rewrite_poms maven-2.1.xml maven-parent-2.1.xml
}


src_install() {
	for i in maven-2.1.xml maven-parent-2.1.xml; do
		einfo "Installing ${i} pom"
		java-maven-2_install_one ${i}
	done
}


##
## Note: install base poms (maven one and maven-parent one) for maven to work properly
## they are there : * http://svn.apache.org/repos/asf/maven/pom/trunk/maven/pom.xml
##                  * http://svn.apache.org/repos/asf/maven/components/trunk/pom.xml
##
## When bumping think to:
## for maven parent: remove parent node
## for maven       : remove relativepath and adapt version  any parent entry to adapt to maven parent...

# maven-base current version to apply to ebuilds in tree using it: 5#
#
# mavencurrent version to apply to ebuilds in tree using it: 2.1-SNAPSHOT
