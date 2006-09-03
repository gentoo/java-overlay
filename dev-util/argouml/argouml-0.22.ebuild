# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/argouml/argouml-0.19.6.ebuild,v 1.3 2006/02/24 05:11:47 vapier Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="modelling tool that helps you do your design using UML"
HOMEPAGE="http://argouml.tigris.org"
MY_PN="ArgoUML"
MY_P="${MY_PN}-${PV}"
SRC_URI="http://argouml-downloads.tigris.org/nonav/${P}/${MY_P}-src.tar.gz
	doc? ( http://argouml-downloads.tigris.org/nonav/${P}/argomanual-${PV}.pdf
	http://argouml-downloads.tigris.org/nonav/${P}/quickguide-${PV}.pdf
	http://argouml-downloads.tigris.org/nonav/${P}/cookbook-${PV}.pdf )"

LICENSE="BSD"
SLOT="0"
#KEYWORDS="~amd64 ~ppc ~ppc-macos ~x86"
KEYWORDS="-*"
IUSE="doc"
RESTRICT="nomirror"

RDEPEND=">=virtual/jre-1.3
	dev-java/swidgets
	dev-java/gef
	dev-java/toolbar
	dev-java/log4j"
DEPEND=">=virtual/jdk-1.3
	${RDEPEND}"

S=${WORKDIR}/${PN}/src_new

src_compile() {
	mkdir -p "${S}/../tests/testmodels"
	eant \
		-Dswidgets.jar.path="$(java-pkg_getjar swidgets swidgets.jar)" \
		-Dgef.jar.path="$(java-pkg_getjar gef gef.jar)" \
		-Dtoolbar.jar.path="$(java-pkg_getjar toolbar toolbar.jar)" \
		-Dlog4j.jar.path="$(java-pkg_getjar log4j log4j.jar)"
}

src_install() {
	dodir /opt/${PN}/lib/
	cp -pPR . ${D}/opt/${PN}/lib/ || die
	chmod -R 755 ${D}/opt/${PN}
	touch ${D}/opt/${PN}/lib/argouml.log
	chmod a+w ${D}/opt/${PN}/lib/argouml.log

	echo "#!/bin/sh" > ${PN}
	echo "cd /opt/${PN}/lib" >> ${PN}
	echo 'java -jar argouml.jar' >> ${PN}
	into /opt
	dobin ${PN}

	dodoc README.txt

	if use doc ; then
		insinto /usr/share/doc/${P}
		doins ${DISTDIR}/argomanual-${PV}.pdf
		doins ${DISTDIR}/quickguide-${PV}.pdf
		doins ${DISTDIR}/cookbook-${PV}.pdf
	fi
}
