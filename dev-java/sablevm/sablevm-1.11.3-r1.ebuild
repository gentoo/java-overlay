# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sablevm/sablevm-1.11.3.ebuild,v 1.8 2006/10/05 18:15:15 gustavoz Exp $

inherit eutils autotools java-vm-2

DESCRIPTION="A robust, clean, extremely portable, efficient, and specification-compliant Java virtual machine."
HOMEPAGE="http://sablevm.org/"

# karltk: According to Grzegorz Prokopski (gadek), the two tarfiles will merge
# into one in the future. For now, they consistently make concurrent releases,
# so I merged them into one ebuild.

SRC_URI="http://sablevm.org/download/release/${PV}/sablevm-${PV}.tar.gz
	http://sablevm.org/download/release/${PV}/sablevm-classpath-${PV}.tar.gz"
LICENSE="LGPL-2.1 GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="gtk debug"
DEPEND=">=dev-libs/libffi-1.20
	>=dev-libs/popt-1.7
	>=dev-java/jikes-1.19
	gtk? (
		>=x11-libs/gtk+-2.4
		>=media-libs/libart_lgpl-2.1
	)"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${WORKDIR}/sablevm-classpath-${PV}
	epatch ${FILESDIR}/gtk28.patch
	eautoconf
}

src_compile() {
	export LDFLAGS="$LDFLAGS -L/usr/lib/libffi" CPPFLAGS="$CPPFLAGS	-I/usr/include/libffi"

	# Compile the Classpath
	cd ${S}/sablevm-classpath-${PV}
	local myc="--with-jikes"
	econf ${myc} $(use_enable gtk gtk-peer) || die
	emake || die "emake failed"

	# Compile the VM
	cd ${S}/sablevm-${PV}
	econf $(use_enable debug debugging-features) \
		--disable-dependency-tracking || die
	emake || die "emake failed"
}

src_install() {
	# Install the Classpath
	cd ${S}/sablevm-classpath-${PV}
	einstall || die

	# Install the VM
	cd ${S}/sablevm-${PV}
	einstall || die

	set_java_env
}
