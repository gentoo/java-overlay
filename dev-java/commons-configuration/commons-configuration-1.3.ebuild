# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-fileupload/commons-fileupload-1.1.1.ebuild,v 1.2 2006/10/10 20:39:41 caster Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Commons Configuration provides a generic configuration interface which enables an application to read configuration data from a variety of sources."
HOMEPAGE="http://jakarta.apache.org/commons/configuration/"
SRC_URI="mirror://apache/jakarta/commons/configuration/source/${P}-src.tar.gz"

COMMON_DEPENDS=">=dev-java/commons-beanutils-1.7.0
	>=dev-java/commons-codec-1.3
	>=dev-java/commons-collections-3.1
	>=dev-java/commons-dbcp-1.1
	>=dev-java/commons-digester-1.6
	>=dev-java/commons-jxpath-1.2
	>=dev-java/commons-lang-2.1
	>=dev-java/commons-logging-1.0.4
	>=dev-java/commons-pool-1.1
	>=dev-db/hsqldb-1.7.2.2
	=dev-java/servletapi-2.3*
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.7
	>=dev-java/xml-commons-1.0_beta2"
DEPEND=">=virtual/jdk-1.3
	${COMMON_DEPENDS}
	source? ( app-arch/unzip )"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEPENDS}"
LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~x86"
IUSE="doc source"

S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Tweak build classpath and don't automatically run tests
	epatch "${FILESDIR}/${P}-gentoo.patch"

	mkdir -p ${S}/target/lib
	cd ${S}/target/lib
	java-pkg_jar-from commons-beanutils-1.7
	java-pkg_jar-from commons-codec
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-dbcp
	java-pkg_jar-from commons-digester
	java-pkg_jar-from commons-jxpath
	java-pkg_jar-from commons-lang-2.1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-pool
	java-pkg_jar-from hsqldb
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from xalan
	java-pkg_jar-from xerces-2
	java-pkg_jar-from xml-commons
}

src_compile() {
	eant jar -Dnoget=true $(use_doc)
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/*
}
