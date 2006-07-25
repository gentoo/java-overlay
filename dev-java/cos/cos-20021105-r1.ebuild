# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=05Nov2002
MY_P=${PN}-${MY_PV}
DESCRIPTION=" The com.oreilly.servlet package is the \"must have\" class library for servlet developers."
HOMEPAGE="http://servlets.com/cos/"
SRC_URI="http://servlets.com/${PN}/${MY_P}.zip"

LICENSE="cos"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

# TODO determine vm version requirements
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	=dev-java/servletapi-2.3*"
S=${WORKDIR}/${PN}

src_unpack() {
	mkdir ${S}
	cd ${S}
	unpack ${A}

	rm -r lib classes *.war
	# TODO I'm not sure how to fix the compilation error for this class
	# so i'll just delete it for now..
	rm src/com/oreilly/servlet/CacheHttpServlet.java

	cp ${FILESDIR}/build-${PV}.xml build.xml
	cat > build.properties <<-EOF
		classpath=$(java-pkg_getjars servletapi-2.3)
	EOF
}

src_compile() {
	eant -Dproject.name=${PN} jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc readme.txt

	use doc && java-pkg_dohtml -r dist/doc/api
}
