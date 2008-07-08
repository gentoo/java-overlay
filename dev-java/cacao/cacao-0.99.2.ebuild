# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit eutils flag-o-matic java-vm-2

DESCRIPTION="Cacao Java Virtual Machine"
HOMEPAGE="http://www.cacaojvm.org/"
SRC_URI="http://www.complang.tuwien.ac.at/cacaojvm/download/${P}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""
CLASSPATH_SLOT=0.97
DEPEND="dev-java/gnu-classpath:${CLASSPATH_SLOT}"
RDEPEND="${DEPEND}"

CLASSPATH_DIR=/usr/gnu-classpath-${CLASSPATH_SLOT}

pkg_setup() {
	java-vm-2_pkg_setup
}

src_compile() {
	# A compiler can be forced with the JAVAC variable if needed
	unset JAVAC
	econf --bindir=/usr/${P}/bin \
		--libdir=/usr/${P}/lib \
		--datarootdir=/usr/${P}/share \
		--disable-dependency-tracking \
		--with-java-runtime-library-prefix=${CLASSPATH_DIR}
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodir /usr/bin
	dosym /usr/${P}/bin/cacao /usr/bin/cacao
	dodoc AUTHORS ChangeLog* NEWS README || die "failed to install docs"

	for files in ${CLASSPATH_DIR}/bin/g*;
	  do
	  dosym $files /usr/${P}/bin/$(echo $files|sed "s#$(dirname $files)/g##");
	done

	dodir /usr/${P}/jre/lib
	dosym ${CLASSPATH_DIR}/share/classpath/glibj.zip /usr/${P}/jre/lib/rt.jar
	dodir /usr/${P}/lib
	dosym ${CLASSPATH_DIR}/share/classpath/tools.zip /usr/${P}/lib

	# use ecj for javac
	if [ -e /usr/bin/ecj ]; then
		dosym /usr/bin/ecj /usr/${P}/bin/javac;
	else
		dosym $(ls -r /usr/bin/ecj-3*|head -n 1) /usr/${P}/bin/javac;
	fi

	set_java_env
}

pkg_postinst() {

	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
