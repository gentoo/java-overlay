# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_PN="jakarta-turbine-jcs"
DESCRIPTION="JCS is a distributed caching system written in java for server-side java applications"
HOMEPAGE="http://jakarta.apache.org/jcs/"
# svn co http://svn.apache.org/repos/asf/jakarta/jcs/tags/JCS_1_2_6_5/ jcs-1.2.6.5
# rm  -r jcs-1.2.6.5/tempbuild
# tar jcvf jcs-1.2.6.5.tar.bz2 jcs-1.2.6.5
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="1.2"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="dev-java/jgroups
	=dev-java/servletapi-2.3*
	dev-java/commons-lang
	dev-java/xmlrpc
	dev-java/concurrent-util
	dev-java/velocity
	=dev-java/jisp-2.5*
	=dev-java/struts-1.1*
	dev-db/hsqldb"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

#S=${WORKDIR}/${MY_PN}

LIBRARY_PKGS="jgroups,servletapi-2.3,commons-lang,xmlrpc,concurrent-util,velocity,jisp-2.5,struts-1.1,hsqldb"

src_unpack() {
	unpack ${A}

	cd ${S}
	# TODO submit jikes patch upstream
	#epatch ${FILESDIR}/${P}-jikes.patch

	# use our own build.xml because jcs's is demented by maven
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	cat > build.properties <<-END
		classpath=$(java-pkg_getjars ${LIBRARY_PKGS})
	END
}

src_compile() {
	local antflags="jar -Dproject.name=${PN}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
