# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2
DESCRIPTION="Library of matchers for building test expressions."
HOMEPAGE="http://code.google.com/p/hamcrest/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tgz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

CDEPEND=">=dev-java/easymock-2.2
	>=dev-java/jmock-1.0
	=dev-java/qdox-1.6*"
DEPEND=">=virtual/jdk-1.5
	test? (
		dev-java/ant-junit
		=dev-java/junit-3.8*
	)
	>=dev-java/jarjar-0.9
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	find -name "*.jar" | xargs rm -v
	java-ant_rewrite-classpath

	# These jars must be symlinked as specifying them using gentoo.classpath
	# does not work and both compilation and test fail
	java-pkg_jar-from --into lib/generator qdox-1.6 qdox.jar qdox-1.6.1.jar
	java-pkg_jar-from --into lib/integration easymock-2 easymock.jar easymock-2.2.jar
	java-pkg_jar-from --into lib/integration jmock-1.0 jmock.jar jmock-1.10RC1.jar
}

src_compile() {
	# javadoc fails if these files and directories do not exist
	if use doc ; then
		mkdir -p ${S}/build/generated-code
		echo "<html><body></body></html>" > ${S}/overview.html
	fi

	ANT_TASKS="jarjar-1" eant bigjar $(use_doc javadoc) -Dversion=${PV}
}

src_test() {
	ANT_TASKS="ant-junit jarjar-1" eant unit-test \
		-Dgentoo.classpath=$(java-pkg_getjars --build-only junit)
}

src_install() {
	for name in all core generator integration library text ; do
		java-pkg_newjar build/${PN}-${name}-${PV}.jar ${PN}-${name}.jar
	done

	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc ${PN}-core/src/main/java/org ${PN}-generator/src/main/java/org \
		${PN}-integration/src/main/java/org ${PN}-library/src/main/java/org \
		${PN}-text/src/main/java/org
}
