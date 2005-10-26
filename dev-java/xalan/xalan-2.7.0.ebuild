# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xalan/xalan-2.6.0-r2.ebuild,v 1.9 2005/09/03 21:16:36 hansmi Exp $

inherit java-pkg eutils

MY_P=${PN}-j_${PV//./_}
DESCRIPTION="XSLT processor"
HOMEPAGE="http://xml.apache.org/xalan-j/index.html"
SRC_URI="mirror://apache/xml/xalan-j/source/${MY_P}-src.tar.gz"
LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86"
IUSE="doc jikes source"
RDEPEND=">=virtual/jdk-1.4*
	dev-java/javacup
	dev-java/bcel
	>=dev-java/jakarta-regexp-1.3-r2
	=dev-java/bsf-2.3*
	>=dev-java/xerces-2.6.2-r1"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5.2
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from xerces-2 
#	java-pkg_jar-from javacup javacup.jar java_cup.jar
	java-pkg_jar-from javacup javacup.jar runtime.jar
	java-pkg_jar-from bcel bcel.jar BCEL.jar
	java-pkg_jar-from jakarta-regexp-1.3 jakarta-regexp.jar regexp.jar
#	java-pkg_jar-from bsf-2.3
	#java-pkg_jar-from jtidy
	#java-pkg_jar-from jlex jlex.jar JLex.jar
}

src_compile() {
	local antflags="-lib $(java-pkg_getjar gnu-jaxp gnujaxp.jar) jar"
	# TODO use doc
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "build failed"
}

src_install() {
	java-pkg_dojar build/xalan.jar
	use doc && java-pkg_dohtml -r ${WORKDIR}/docs/*
	use source && java-pkg_dosrc src/org
}
