# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java

DESCRIPTION="A robust, clean, extremely portable, efficient, and specification-compliant Java virtual machine."
HOMEPAGE="http://sablevm.org/"

SRC_URI="http://sablevm.org/download/release/${PV}/${PN}-${PV}.tar.gz"

LICENSE="LGPL-2.1 GPL-2 libffi as-is IBM"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"

#
# libffi  - use system libffi instead of bundled one.
# nogjdoc - do not build gjdoc (useful to bootstrap if no SDK currently
#           installed to build antlr)
#
IUSE="gtk debug libffi nogjdoc"

PROVIDE="virtual/jdk
	virtual/jre"

DEPEND="!dev-java/sablevm
	dev-java/java-config
	libffi? ( >=dev-libs/libffi-1.20 )
	!nogjdoc? ( >=dev-java/antlr-2.7.1 )
	>=dev-libs/popt-1.7
	>=dev-java/jikes-1.22
	gtk? (
		>=x11-libs/gtk+-2.2
		>=media-libs/libart_lgpl-2.1
		>=media-libs/gdk-pixbuf-0.22
	)"
#RDEPEND=""

S=${WORKDIR}/${PN}-${PV}

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_compile() {
	export LDFLAGS="$LDFLAGS -L/usr/lib/libffi" \
	  CPPFLAGS="$CPPFLAGS -I/usr/include/libffi" \
	  JAR=${S}/bin/fastjar \
	  JAVAC=${S}/bin/javac \
	  JAVA=${S}/bin/java
	  
	econf \
	  $(use_enable gtk gtk-peer) \
	  $(use_enable debug debugging-features) \
	  $(use_with !libffi internal-libffi) \
	  $(use_enable !nogjdoc gjdoc) \
	  $(use_with !nogjdoc antlr-jar=`java-config --classpath=antlr`) \
	  --with-fastjar=internal || die

	emake || die "emake failed"
}

src_install() {
	make install DESTDIR=${D} || die

	gzip ${D}/usr/lib/sablevm/man/man1/*

	dosym /usr/share/man/man1/java-sablevm.1.gz \
	  /usr/lib/sablevm/man/man1/java.1.gz

	dosym /usr/share/man/man1/jikes.1.gz \
	  /usr/lib/sablevm/man/man1/javac.1.gz

	dosym fastjar.1.gz \
	  /usr/lib/sablevm/man/man1/jar.1.gz

	use nogjdoc ||
	  dosym gjdoc.1.gz \
	    /usr/lib/sablevm/man/man1/javadoc.1.gz

	set_java_env ${FILESDIR}/${VMHANDLE}
}
