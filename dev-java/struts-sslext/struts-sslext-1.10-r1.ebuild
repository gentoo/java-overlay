# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="sslext"
MY_A="sslext-struts${PV}-src"
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_A}.tar.gz"

LICENSE=""
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc jikes"

COMMON_DEPEND="=dev-java/struts-1.1*
	=dev-java/servletapi-2.4*
	dev-java/commons-digester"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? ( dev-java/jikes )
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
	
ant_src_unpack() {
	mkdir -p ${S}/src
	cd ${S}/src
	unpack ${A}

	cd ${S}

	cp ${FILESDIR}/build-${PVR}.xml build.xml
	local classpath;
	for dependency in struts-1.1 servletapi-2.4 commons-digester; do
		local dependency_classpath=$(java-pkg_getjars ${dependency})
		if [ -z "${classpath}" ] ; then
			classpath=${dependency_classpath}
		else
			classpath="${classpath}:${dependency_classpath}"
		fi
	done

	echo "classpath=${classpath}" > build.properties
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	eant -Dproject.name=${PN} jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
