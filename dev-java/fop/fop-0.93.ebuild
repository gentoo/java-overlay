# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/fop/fop-0.20.5-r3.ebuild,v 1.10 2006/01/23 14:13:00 nichoj Exp $

inherit eutils java-pkg-2 java-ant-2

#ESVN_REPO_URI="http://svn.apache.org/repos/asf/xmlgraphics/fop/tags/fop-0_93/"
#ESVN_PROJECT="fop-0_93"

DESCRIPTION="Formatting Objects Processor is a print formatter driven by XSL"
HOMEPAGE="http://xmlgraphics.apache.org/fop/"
SRC_URI="mirror://apache/xmlgraphics/${PN}/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"
#IUSE="doc examples jai jimi mathml xmlunit"
IUSE="doc examples source"

RDEPEND=">=virtual/jre-1.5
	=dev-java/avalon-framework-4.2*
	dev-java/xalan
	=dev-java/batik-1.6*
	>=dev-java/xerces-2.6.2
	dev-java/commons-io
	dev-java/commons-logging
	>=dev-java/xmlgraphics-commons-1.1
	=dev-java/servletapi-2.2*"
	
	
	#mathml? ( dev-java/jeuclid )"
	#jai? ( dev-java/sun-jai-bin )
	#jimi? ( dev-java/sun-jimi )
	#xmlunit? ( dev-java/xmlunit )
DEPEND=">=virtual/jdk-1.5
	${RDEPEND}
	>=dev-java/ant-1.5.4
	source? ( app-arch/zip )
	!dev-java/fop-bin"

src_unpack() {
	unpack ${A}

	cd ${S}/lib
	#epatch ${FILESDIR}/${PV}-startscript.patch

	local packages="avalon-framework-4.2 xalan xmlgraphics-commons-1 xerces-2
	commons-io-1 servletapi-2.2 batik-1.6"

	for package in ${packages}; do
		java-pkg_jarfrom ${package}
	done
	#cd ${S}/lib
	#mkdir ${S}/lib/b
	#mv ${S}/lib/batik* ${S}/lib/b
	#mv ${S}/lib/xmlgraphics* ${S}/lib/b
	#rm -f *.jar
	#mv ${S}/lib/b/* ${S}/lib
	#java-pkg_jar-from avalon-framework-4.2
	#java-pkg_jar-from xalan
	#java-pkg_jar-from xerces-2
	#java-pkg_jar-from commons-io-1
	#java-pkg_jar-from servletapi-2.2
	#if use jai; then
	#	java-pkg_jar-from sun-jai-bin
	#fi
	#if use jimi; then
	#	java-pkg_jar-from sun-jimi
	#fi
	#if use xmlunit; then
	#	java-pkg_jar-from xmlunit-1
	#fi
	#if use mathml; then
	#	cd ${S}/examples/mathml/lib
	#	java-pkg_jar-from jeuclid
	#fi
}

ANT_OPTS="-Xmx512m"
EANT_BUILD_TARGET="package"
EANT_DOC_TARGET="javadocs"
#EANT_EXTRA_ARGS="-Xmx512m"

#src_compile() {
#	local antflags="package"
#	if use doc; then
#		antflags="${antflags} javadocs"
#	fi
#	ant ${antflags} || die "compile failed"
#	if use mathml; then
#		cd ${S}/examples/mathml
#		ant || die "compele failed"
#	fi
#}

src_install() {
	java-pkg_dojar lib/batik*.jar
	java-pkg_dojar lib/xmlgraphics-commons*.jar

	java-pkg_dojar build/${PN}.jar
	if use mathml; then
		java-pkg_dojar examples/mathml/build/mathml-fop.jar
	fi

	dobin ${PN}

	if use doc; then
		dodoc CHANGES STATUS README
		java-pkg_dohtml -r ReleaseNotes.html build/javadocs/*
	fi

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -pPR examples ${D}/usr/share/doc/${PF}/examples
	fi
}
