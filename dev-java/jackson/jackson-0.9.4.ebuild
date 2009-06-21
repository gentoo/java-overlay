# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/lucene/lucene-2.4.0.ebuild,v 1.3 2008/11/01 09:39:23 robbat2 Exp $

JAVA_PKG_IUSE="doc source test"
EANT_BUILD_TARGET=jars
EAPI=2

inherit java-pkg-2 java-ant-2

DESCRIPTION="High-performance JSON processor"
HOMEPAGE="http://jackson.codehaus.org"
SRC_DIR="${PN}-src-${PV}"
SRC_URI="http://jackson.codehaus.org/${PV}/${SRC_DIR}.tar.gz"
LICENSE="|| ( Apache-2.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RDEPEND=">=virtual/jre-1.5"
DEPEND="${RDEPEND}
	>=virtual/jdk-1.5
	dev-java/ant-nodeps
	test? (
		dev-java/ant-junit
		dev-java/junit:0
		)"
S="${WORKDIR}/${SRC_DIR}"

src_unpack() {
	mkdir "${S}" || die
	cd "${S}"
	unpack ${A}
}

java_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${P}-minimal.patch
	# Cleanup
	# bndtask-0.2.0.jar is needed for osgiJar in the ant process
	# It's findable here: 
	# https://opensource.luminis.net/wiki/display/SITE/OSGi+Bundle+Ant+Task
	# But I can't find the 'bnd' that it requires AND which works
	find "${S}" -iname '*.jar' ! -name bndtask-0.2.0.jar -exec rm \{\} \;
	if use test; then
		java-pkg_jar-from --build-only --into lib/junit junit
	fi

# - These are needed for coverage tests only:
# lib/cobertura/log4j-1.2.13.jar
# lib/cobertura/jakarta-oro-2.0.8.jar
# lib/cobertura/cobertura-1.9.jar
# lib/cobertura/asm-tree-2.2.1.jar
# lib/cobertura/asm-2.2.1.jar

# - Might not even be needed
# lib/ant/maven-ant-tasks-2.0.9.jar
# lib/ant/bndtask-0.2.0.jar

}

src_install() {
	dodoc release-notes/{VERSION,TODO,CREDITS} || die
	for i in {asl,lgpl} ; do
		java-pkg_newjar build/${PN}-${i}-${PV}.jar ${PN}-${i}.jar
	done

	use doc && java-pkg_dohtml -r build/javadoc
	use source && java-pkg_dosrc src/java/org
}

src_test() {
	java-pkg-2_src_test
}
