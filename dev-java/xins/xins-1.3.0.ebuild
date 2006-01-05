# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="Open-source Java-based Web Services RPC technology, supporting XML-RPC, SOAP and REST"
HOMEPAGE="http://xins.sourceforge.net/"
SRC_URI="mirror://sourceforge/xins/${P}.tgz"

LICENSE="BSD"
SLOT="1.3"
KEYWORDS="~x86"
IUSE="debug doc examples jikes source"

RDEPEND=">=virtual/jdk-1.4
	>=dev-java/commons-logging-1.0
	>=dev-java/commons-codec-1.3
	=dev-java/commons-httpclient-3*
	=dev-java/jakarta-oro-2.0*
	>=dev-java/log4j-1.2
	=dev-java/servletapi-2.3*
	>=dev-java/xmlenc-0.52"

DEPEND="${RDEPEND}
	>=dev-java/ant-1.6.5
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -rf build docs lib/*
	epatch ${FILESDIR}/${PN}-script.patch
}

src_compile() {
	local antflags="java"
	local classpath="$(java-pkg_getjars commons-logging,commons-codec,commons-httpclient-3,jakarta-oro-2.0,log4j,servletapi-2.3,xmlenc || die 'Unable to set classpath')"
	use debug && antflags="-Djavac.debug=true ${antflags}"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc-public"
	ant ${antflags} -lib "${classpath}" || die "Processing of Ant build file failed."

	dosed "s/%%PN-SLOT%%/${PN}-${SLOT}/g" bin/xins

	if use doc; then
		mv docs/javadoc docs/api || die "Renaming javadoc failed."
	fi
}

src_install() {
	java-pkg_dojar build/*.jar

	local SD=/usr/share/${PN}-${SLOT}
	local LI=${SD}/installment
	dobin bin/xins

	use source && java-pkg_dosrc src/java-*/*

	dodir ${LI}
	insinto "${LI}"
	doins -r .version.properties build.xml src || die "doins failed"
	rm -rf "${D}/${LI}"/src/java-* || die "failed to remove sources."

	cd "${D}/${LI}"
	ln -s  ../lib build

	cd "${S}"

#	dodir ${LI}/lib

	use doc && java-pkg_dohtml -r docs/api
	dodoc NOTES CHANGES || die "dodoc failed"

	if use examples; then
		local ED=/usr/share/doc/${PF}/examples
		dodir ${ED}
		cp -R demo/* "${D}/${ED}/"
	fi
}
