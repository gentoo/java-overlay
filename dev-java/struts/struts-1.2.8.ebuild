# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/struts/struts-1.2.8.ebuild,v 1.1 2005/11/26 14:51:16 betelgeuse Exp $

inherit java-pkg

MY_P=${P}-src
DESCRIPTION="A powerful Model View Controller Framework for JSP/Servlets"
SRC_URI="mirror://apache/struts/source/${MY_P}.tar.gz"
HOMEPAGE="http://jakarta.apache.org/struts/index.html"
LICENSE="Apache-2.0"
SLOT="1.2"
RDEPEND=">=virtual/jre-1.4
	dev-java/antlr
	=dev-java/commons-beanutils-1.7*
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-digester-1.5
	>=dev-java/commons-fileupload-1.0
	>=dev-java/commons-logging-1.0.4
	~dev-java/commons-validator-1.1.4
	=dev-java/jakarta-oro-2.0*
	=dev-java/servletapi-2.3*"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-1.6.0
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"
IUSE="doc examples jikes source"
KEYWORDS="~amd64 ~ppc ~x86"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}

	# the build.xml expects this directory to exist
	mkdir ${S}/lib
	cd ${S}/lib

	# No property exists for this
	java-pkg_jar-from commons-collections
}

src_compile() {
	local antflags="compile.library"
	use doc && antflags="${antflags} compile.javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	# In the order the build process asks for these
	# They are copied in the build.xml to ${S}/target/library/
	antflags="${antflags} -Dcommons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.7 commons-beanutils.jar)"
	antflags="${antflags} -Dcommons-digester.jar=$(java-pkg_getjars commons-digester)"
	antflags="${antflags} -Dcommons-fileupload.jar=$(java-pkg_getjars commons-fileupload)"
	antflags="${antflags} -Dcommons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)"
	antflags="${antflags} -Dcommons-validator.jar=$(java-pkg_getjars commons-validator)"
	antflags="${antflags} -Djakarta-oro.jar=$(java-pkg_getjars jakarta-oro-2.0)"

	# Needed to compile
	antflags="${antflags} -Dservlet.jar=$(java-pkg_getjars servletapi-2.3)"
	antflags="${antflags} -Dantlr.jar=$(java-pkg_getjars antlr)"

	# only needed for contrib stuff which we don't currently build
#	antflags="${antflags} -Dstruts-legacy.jar=$(java-pkg_getjars struts-legacy)"

	ant ${antflags} || die "compile failed"
}

src_install() {
	java-pkg_dojar target/library/struts.jar

	#install the tld files
	insinto /usr/share/${PN}-${SLOT}/lib
	doins target/library/*.tld

	dodoc README STATUS.txt
	use doc && java-pkg_dohtml -r target/documentation/
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/example*/* ${D}/usr/share/doc/${PF}/examples
	fi
	use source && java-pkg_dosrc src/share/*
}
