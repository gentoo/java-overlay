# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-fileupload/commons-fileupload-1.0.ebuild,v 1.18 2005/11/05 11:31:43 betelgeuse Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="The Commons FileUpload package makes it easy to add robust, high-performance, file upload capability to your servlets and web applications."
HOMEPAGE="http://jakarta.apache.org/commons/fileupload/"
SRC_URI="mirror://apache/jakarta/commons/fileupload/source/${P}-src.tar.gz"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.5
	~dev-java/servletapi-2.3
	=dev-java/commons-io-1*
	source? ( app-arch/unzip )"
RDEPEND=">=virtual/jre-1.3"
LICENSE="Apache-1.1"
SLOT="0"
# Missing dependencies: need package for javax.portlet.
KEYWORDS="-*"
#KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc source"

src_unpack() {
	unpack ${A}
	cd ${S}
	# Tweak build classpath and don't automatically run tests
	epatch "${FILESDIR}/${P}-gentoo.patch"
	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from commons-io-1
}

src_compile() {
	eant jar -Dnoget=true $(use_doc)
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/*
}
