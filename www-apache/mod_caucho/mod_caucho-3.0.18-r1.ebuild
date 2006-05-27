# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit apache-module autotools

DESCRIPTION="mod_caucho connects Resin and Apache2"
HOMEPAGE="http://www.caucho.com"
SRC_URI="http://www.caucho.com/download/resin-${PV}-src.tar.gz"
LICENSE="GPL-2"

KEYWORDS="~x86"
IUSE=""
SLOT="0"

# See apache-module.eclass for more information.
APACHE2_MOD_CONF="88_${PN}"
APACHE2_MOD_DEFINE="CAUCHO"

need_apache2

RDEPEND="${RDEPEND}"

S="${WORKDIR}/resin-${PV}"

src_unpack() {

	unpack "${A}"

	epatch "${FILESDIR}/${P}-gentoo.patch"

	cd "${S}"
	eautoreconf

	chmod 755 ./configure

}

src_compile() {

	econf --with-apxs=${APXS2} || die "econf failed"

	emake -C "${S}/modules/c/src/common/" || die "emake failed"
	emake -C "${S}/modules/c/src/apache2/" || die "emake failed"

}

src_install() {

	cd "${S}/modules/c/src/apache2"
	make DESTDIR="${D}" install || die "install failed"

	insinto ${APACHE2_MODULES_CONFDIR}
	doins ${FILESDIR}/${APACHE2_MOD_CONF}.conf || \
		die "internal ebuild error: '${FILESDIR}/${APACHE2_MOD_CONF}.conf' not found."

}
