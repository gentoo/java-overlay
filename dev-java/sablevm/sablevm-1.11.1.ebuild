# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java

DESCRIPTION="A robust, clean, extremely portable, efficient, and specification-compliant Java virtual machine."
HOMEPAGE="http://sablevm.org/"

# karltk: According to Grzegorz Prokopski (gadek), the two tarfiles will merge
# into one in the future. For now, they consistently make concurrent releases,
# so I merged them into one ebuild.

SRC_URI="http://sablevm.org/download/release/${PV}/sablevm-${PV}.tar.gz
	http://sablevm.org/download/release/${PV}/sablevm-classpath-${PV}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="x86 ~ppc amd64"
IUSE="gtk debug"
DEPEND=">=dev-libs/libffi-1.20
	>=dev-libs/popt-1.7
	>=dev-java/jikes-1.19
	gtk? (
		>=x11-libs/gtk+-2.2
		>=media-libs/libart_lgpl-2.1
		>=media-libs/gdk-pixbuf-0.22
	)"
#RDEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	cd ${S}/sablevm-classpath-${PV}
	epatch ${FILESDIR}/sablevm-classpath-svn-bug-patch.diff
	cp ${FILESDIR}/autogen-sablevm-classpath.sh autogen.sh
	./autogen.sh

	cd ${S}/sablevm-${PV}
	epatch ${FILESDIR}/sablevm-svn-bug-patch.diff
	cp ${FILESDIR}/autogen-sablevm.sh autogen.sh
	./autogen.sh
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
	econf $(use_enable debug debugging-features) || die
	emake || die "emake failed"
}

src_install() {
	# Install the Classpath
	cd ${S}/sablevm-classpath-${PV}
	einstall || die

	# Install the VM
	cd ${S}/sablevm-${PV}
	einstall || die

	dodir /usr/lib/sablevm/man/man1
	dosym ${ROOT}usr/share/man/man1/java-sablevm.1.gz /usr/lib/sablevm/man/man1/java.1.gz

	set_java_env ${FILESDIR}/${VMHANDLE}
}
