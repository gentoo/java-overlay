# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/itext/itext-1.4.8.ebuild,v 1.7 2007/02/04 15:32:13 nixnut Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java library that generate documents in the Portable Document Format (PDF) and/or HTML."
HOMEPAGE="http://www.lowagie.com/iText/"
SRC_URI="mirror://sourceforge/itext/${PN}-src-${PV}.tar.gz"

IUSE="doc source"

LICENSE="MPL-1.1"
SLOT="1.4"
KEYWORDS="~x86 ~amd64"

DEPEND=">=virtual/jdk-1.4 source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	mkdir "${WORKDIR}/src" || die
	cd "${WORKDIR}/src" || die
	unpack "${PN}-src-${PV}.tar.gz"
	for antfile in ant/*.xml;do
		java-ant_bsfix_one "${antfile}"
	done

}

src_compile() {
	cd "${WORKDIR}/src" || die
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar build/bin/*.jar

	use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc build/docs
}

