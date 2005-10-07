# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

HIBERNATE_P="hibernate-2.1.8"

MY_PN=${PN/extensions/tools}
MY_P=${P/extensions/tools}
DESCRIPTION="Extra tools for Hibernate"
HOMEPAGE="http://www.hibernate.org/"
SRC_URI="mirror://sourceforge/hibernate/${P}.tar.gz
	mirror://sourceforge//hibernate/${HIBERNATE_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="jikes doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4
	=dev-java/velocity-1*
	=dev-java/jdom-1.0_beta9*
	=dev-java/hibernate-2*"

TOOLS="${S}/tools"
CONSOLE="${S}/console"

HIBERNATE_HOME="${WORKDIR}/hibernate-2.1"

VELOCITY="velocity-1 velocity.jar"
JDOM="jdom-1.0_beta9 jdom.jar"
HIBERNATE_CORE="hibernate-2 hibernate2.jar"
FORMS="jgoodies-forms"
LOOKS="jgoodies-looks"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-console_build.patch
	epatch ${FILESDIR}/${P}-hbm2java_timestamp.patch
	
	cd ${TOOLS}
	echo hibernate-core.jar=`java-pkg_jar-from ${HIBERNATE_CORE}` > build.properties

	einfo "Fixing jars in ${TOOLS}/lib"
	cd ${TOOLS}/lib
	java-pkg_jar-from ${VELOCITY} velocity-1.3.1.jar
	java-pkg_jar-from ${JDOM}

	cd ${CONSOLE}
	echo hibernate-core.jar=`java-pkg_jar-from ${HIBERNATE_CORE}` > build.properties
	einfo "Fixing jars in ${CONSOLE}/lib"
	cd ${CONSOLE}/lib

	# there isn't a need to replace the packed jars in hibernate-2.1/lib
	# because these libraries don't even seem to be used. It compiles fine
	# with an empty directory.
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}" 
	use doc && antflags="${antflags} javadoc"
	
	cd ${TOOLS}
	ant ${antflags} || die "Compile failed"
}

src_install() {
	cd ${TOOLS}
	java-pkg_dojar target/${MY_P}/${MY_PN}.jar
	java-pkg_dohtml -r target/${P_}/doc/api
	dodoc changelog.txt readme.txt
}
