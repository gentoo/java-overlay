# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="sslext"
MY_A="sslext-struts${PV}-src"
DESCRIPTION="Extension to Struts that allows automatically switching between the http and https."
HOMEPAGE="http://sslext.sourceforge.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_A}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="=dev-java/struts-1.1*
	~dev-java/servletapi-2.4
	dev-java/commons-digester
	dev-java/commons-logging"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

src_unpack() {
	mkdir -p "${S}/src"
	cd "${S}/src"
	unpack ${A}

	cd "${S}"
	cp "${FILESDIR}/build-${PV}.xml" build.xml
	local classpath
	classpath=$(java-pkg_getjars struts-1.1,servletapi-2.4,commons-digester,commons-logging)
	echo "classpath=${classpath}" > build.properties
}

src_compile() {
	eant -Dproject.name=${PN} jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
