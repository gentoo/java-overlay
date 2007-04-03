# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"

inherit autotools java-pkg-2

DESCRIPTION="A javadoc compatible Java source documentation generator."
HOMEPAGE="http://www.cag.lcs.mit.edu/~cananian/Projects/GJ/"
SRC_URI="http://www.cag.lcs.mit.edu/~cananian/Projects/GJ/sinjdoc-latest/sinjdoc-0.5.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

CDEPEND="dev-java/javacup"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-annotations.patch"
	epatch "${FILESDIR}/${PN}-autotools-changes.patch"

	cd "${S}/lib"
	rm -v *.jar || die
	java-pkg_jar-from javacup javacup.jar cup.jar
}

src_compile() {
	eautoreconf
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	#Use this when upgrading to check what upstream wants to install
	#emake DESTDIR="${D}" install || die
	java-pkg_dojar ${PN}.jar
	java-pkg_dolauncher ${PN} --main net.cscott.sinjdoc.Main
	dodoc README AUTHORS ChangeLog || die
	use source && java-pkg_dosrc "${S}/src"
}
