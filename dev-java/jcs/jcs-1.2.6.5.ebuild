# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_PN="jakarta-turbine-jcs"
DESCRIPTION="JCS is a distributed caching system written in java for server-side java applications"
HOMEPAGE="http://jakarta.apache.org/jcs/"
# cvs -z3 -d :pserver:anoncvs@cvs.apache.org:/home/cvspublic co -r  JCS_1_2_6_5 jakarta-turbine-jcs
# rm  -r jakarta-turbine-jcs/tempbuild
# tar jcvf jcs-1.2.6.5.tar.bz2
SRC_URI="${P}.tar.bz2"

LICENSE="APACHE-2"
# TODO test that this slot is alright (maybe it needs 1.2.5?)
SLOT="1.2"
KEYWORDS="~x86"
IUSE="doc jikes"

COMMON_DEPEND="dev-java/jgroups
	=dev-java/servletapi-2.3*
	dev-java/commons-lang
	dev-java/xmlrpc
	dev-java/concurrent-util
	=dev-java/velocity-1*
	=dev-java/jisp-2.5*
	=dev-java/struts-1.1*
	dev-db/hsqldb"
DEPEND="virtual/jdk
	dev-java/ant-core
	jikes? (dev-java/jikes)
	${COMMON_DEPEND}"
RDEPEND="virtual/jre
	${COMMON_DEPEND}"

S=${WORKDIR}/${MY_PN}

LIBRARY_PKGS="jgroups,servletapi-2.3,commons-lang,xmlrpc,concurrent-util,velocity-1,jisp-2.5,struts,hsqldb"

src_unpack() {
	unpack ${A}

	cd ${S}
	# TODO submit jikes patch upstream
	epatch ${FILESDIR}/${P}-jikes.patch

	# use our own build.xml because jcs's is demented by maven
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	cat > build.properties <<-END
		classpath=$(java-pkg_getjars ${LIBRARY_PKGS})
	END
}

src_compile() {
	local antflags="jar -Dproject.name=${PN}"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
