# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portagemaster/portagemaster-0.2.1.ebuild,v 1.18 2006/10/05 14:34:49 gustavoz Exp $

JAVA_PKG_IUSE=""
WANT_ANT_TASKS="ant-core"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A java portage browser and installer"
HOMEPAGE="http://portagemaster.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""

DEPEND=">=virtual/jdk-1.4.1
	>=dev-java/ant-core-1.7"
RDEPEND=">=virtual/jre-1.4.1
	( || ( (
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libX11
				x11-libs/libXext
				x11-libs/libXi
				x11-libs/libXp
				x11-libs/libXt
				x11-libs/libXtst
			)
			virtual/x11
		)
	)"

S="${WORKDIR}/${PN}"

EANT_BUILD_TARGET="package"

src_install() {
	java-pkg_newjar "packages/${P}.jar"
	java-pkg_dolauncher
}
