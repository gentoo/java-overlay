# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="GUI frontend for BibTeX, written in Java"
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/JabRef-${PV}-src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

RDEPEND=">=virtual/jre-1.4
	dev-java/spin
	=dev-java/glazedlists-1.5*
	>=dev-java/antlr-2.7.3
	dev-java/jgoodies-forms
	=dev-java/jgoodies-looks-2.0*
	>=dev-java/microba-0.4.3"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	>=dev-java/ant-core-1.4.1"

src_unpack() {
	unpack ${A}

	cd "${S}"
	# TODO submit upstream
	epatch "${FILESDIR}/${PN}-2.1-fix_jarbundler.patch"
	# cleans up the way the classpath is setup in build.xml.
	# in particular, it makes it use *.jar instead of particular files
	epatch "${FILESDIR}/${PN}-2.1-classpath_cleanup.patch"

	rm lib/*
	cd lib

	java-pkg_jar-from antlr
	java-pkg_jar-from spin
	java-pkg_jar-from glazedlists-1.5
	java-pkg_jar-from jgoodies-looks-2.0
	java-pkg_jar-from jgoodies-forms
	java-pkg_jar-from microba

}


src_compile() {
	eant jars $(use_doc -Dbuild.javadocs=build/docs/api javadocs)
}

src_install() {
	java-pkg_dojar build/lib/${PN}.jar

	use doc && java-pkg_dohtml -r build/docs/api
	dodoc src/txt/README

	java-pkg_dolauncher ${PN} \
		--main net.sf.jabref.JabRef

	newicon src/images/JabRef-icon.png JabRef-icon.png
	make_desktop_entry jabref JabRef JabRef-icon.png Office
}