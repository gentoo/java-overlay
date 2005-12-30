# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://gentooexperimental.org/distfiles/${P}-gentoo.tar.bz2"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/jelly-tags/tags/MAVEN_JELLY_TAGS_1_0_1/ maven-jelly-tags-1.0.1
# tar cjf maven-jelly-tags-1.0.1-gentoo.tar.bz2 maven-jelly-tags-1.0.1

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/build-${PV}.xml build.xml
	
	mkdir -p ${S}/target/lib
	cd ${S}/target/lib
	commons-jelly-tags_fix-common-jars
	commons-jelly-tags_fix-jars
}

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-grant
	java-pkg_jar-from commons-graph
	java-pkg_jar-from commons-jelly-1
	java-pkg_jar-from commons-jelly-tags-ant-1
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-logging
	java-pkg_jar-from maven-core-1
	java-pkg_jar-from werkz
}
