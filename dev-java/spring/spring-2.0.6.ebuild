# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Spring is a layered Java/J2EE application framework, based on code published in Expert One-on-One J2EE Design and Development by Rod Johnson (Wrox, 2002)."
HOMEPAGE="http://www.springframework.org/"

# To recreate tarball do the following:
#
# 1. svn export http://subclipse.tigris.org/svn/subclipse/trunk/svnant/ 
# 2. Rename the directory svnant to svnant-1.1.0_rc2_pre3198, and tar & bzip2
#

SRC_URI="${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="2.0"

KEYWORDS=""
IUSE="source java5"

# Ideas for IUSE: AspectJ
#
#

CDEPEND="
	dev-java/commons-collections
	>=dev-java/commons-attributes-2.1
	>=dev-java/qdox-1.6
	>=dev-java/aspectj-1.5.3
	dev-java/commons-logging
	=dev-java/cglib-2.1*
	>=dev-java/commons-pool-1.3
	>=dev-java/jakarta-oro-2.0
	>=dev-java/ehcache-1.2.4
	dev-java/sun-jms
	dev-java/jta
	dev-java/c3p0
	dev-java/xapool	
	=dev-java/sun-ejb-spec-2.1*"

DEPEND="
	java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jdk-1.4* )
	dev-java/ant-core
	dev-java/antlr
	app-arch/zip
	dev-java/aopalliance
	>=dev-java/jamon-2.6
	dev-java/sun-connector
	${CDEPEND}"
	
RDEPEND="
	java5? ( 
		=virtual/jre-1.5*
		=dev-java/hibernate-annotations-3.0*
	)
	!java5? ( || ( =virtual/jre-1.4* =virtual/jre-1.5* ) )
	${CDEPEND}"
	

src_unpack() {
	unpack "${A}"
	cd "${S}"
	
	rm -rf lib/
	cp "${FILESDIR}/build.xml" ./
	java-ant_rewrite-classpath
}

# --with-dependencies

src_compile() {

	gentoo_jars="$(java-pkg_getjars --build-only --with-dependencies commons-collections,commons-attributes-2,qdox-1.6,aopalliance-1,jamon-2,sun-connector-1.5)"
	gentoo_jars="${gentoo_jars}:$(java-pkg_getjars --with-dependencies aspectj-1.5,commons-logging,cglib-2.1,commons-pool,jakarta-oro-2.0,ehcache-1.2,sun-jms,sun-ejb-spec,jta,c3p0)"

	ANT_OPTS="-Xmx1024M" eant "-Dgentoo.jars=${gentoo_jars//:/,}" alljars

	cp -r docs/reference/html_single reference
}

src_install() {
	java-pkg_dojar dist/*.jar dist/*/*.jar

	use source && java-pkg_dosrc src/* $(use java5 && echo tiger/src/*)
}

