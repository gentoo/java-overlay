# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=0.45
MY_P=${PN}-${MY_PV}
DESCRIPTION="Declarative Velocity Style Language."
HOMEPAGE="http://jakarta.apache.org/velocity/dvsl/index.html"
# TODO figure out how i checked this out...
# TODO find out if there's a tagged branch or something
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"

# I'm guessing some sort of apache-ness
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="=dev-java/crimson-1*
	=dev-java/dom4j-1*
	dev-java/gnu-jaxp
	dev-java/velocity
	dev-java/xalan
	=dev-java/xerces-1.3*"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	dev-java/ant-core
	${COMMON_DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -r lib/*.jar

	local classpath
	for jars in crimson-1 dom4j-1 gnu-jaxp velocity xalan ant-core; do
		classpath="${classpath}:`java-pkg_getjars ${jars}`"
	done

	echo "portage.classpath=${classpath}" > build.properties
}

EANT_DOC_TARGET="javadocs"

src_install() {
	java-pkg_newjar velocity-${MY_P}.jar ${PN}.jar
	java-pkg_register-ant-task

	use doc && java-pkg_dojavadoc target/api
}
