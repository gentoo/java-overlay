# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
JAVA_PKG_IUSE="doc source test"
PROJ_PV="${PV}-ea"
PROJ_PN="jersey"
PROJ_P="${PROJ_PN}-${PROJ_PV}"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JAX-RS Reference Implementation for building RESTful Web services - core"
HOMEPAGE="https://jersey.dev.java.net/"

SRC_FILE="${PROJ_P}-src.tar.bz2"
SRC_URI="mirror://gentoo/${SRC_FILE}
		 mirror://gentoo/${SRC_FILE/src/src-generated}
		 http://dev.gentoo.org/~robbat2/java/${SRC_FILE}
		 http://dev.gentoo.org/~robbat2/java/${SRC_FILE/src/src-generated}"

LICENSE="|| ( CDDL GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

COMMON_DEPEND=">=dev-java/jsr311-api-1.1
			  java-virtuals/javamail
			  java-virtuals/jaxb-api:2
			  java-virtuals/stax-api
			  dev-java/istack-commons-runtime:1.1
			  java-virtuals/jaf"
DEPEND=">=virtual/jdk-1.5
		test? ( dev-java/ant-junit:0 dev-java/junit:0 )
		${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.5
		${COMMON_DEPEND}"

S="${WORKDIR}/${PROJ_P}/${PROJ_PN}/${PN}"

# Helper to generate the tarball :-)
# ( PN=jersey ; PV=1.1.0 ; . ${PN}*-${PV}.ebuild  ; src_tarball )
src_tarball() {
	SVN_SRC_URI="${HOMEPAGE}/svn/${PROJ_PN}/tags/${PROJ_P}"
	tarball="${PROJ_P}"
	svn export \
		--username guest --password '' --non-interactive \
		${SVN_SRC_URI} ${tarball} \
		&& \
	tar cvjf ${SRC_FILE} \
		--exclude '*.jar' \
		--exclude '*.zip' \
		${tarball} \
		&& \
	echo "New tarball located at ${SRC_FILE}" \
	echo "Now you should make ${SRC_FILE/src/src-generated}.tar.bz2 using the"
	echo "generate-sources maven targets, and symlink back to the real src"
	echo "directories. It's not automated yet :-("
}

java_prepare() {
	sed \
		-e "/@@GENTOO_PN@@/s,@@GENTOO_PN@@,${PN},g" \
		-e "/@@GENTOO_PV@@/s,@@GENTOO_PV@@,${PV},g" \
		<"${FILESDIR}"/generic-maven-build.xml \
		>build.xml

	java-pkg_jar-from javamail
	java-pkg_jar-from jsr311-api
	java-pkg_jar-from jaxb-api-2
	java-pkg_jar-from jaf
	java-pkg_jar-from stax-api
	java-pkg_jar-from istack-commons-runtime-1.1
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	use doc	&& java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java
}

src_test() {
	EANT_GENTOO_CLASSPATH="junit ant-core" \
	ANT_TASKS="ant-junit" \
	eant test
}
