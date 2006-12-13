# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2

DESCRIPTION="A Java plotting package"
HOMEPAGE="http://ptolemy.eecs.berkeley.edu/java/ptplot5.5/ptolemy/plot/doc/index.htm"
SRC_URI="http://ptolemy.eecs.berkeley.edu/java/ptplot${PV}/ptolemy/plot/${PN}${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc source"
RESTRICT="test"
DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${PN}${PV}

src_unpack() {
	unpack ${A}
	einfo "Removing bundled jar files."
	for i in `find . -name "*.jar"` ; do
		rm -f "${i}" || die "rm failed"
	done
	einfo "Removing bundled class files."
	for i in `find . -name "*.class"` ; do
		rm -f "${i}" || die "rm failed"
	done
	epatch "${FILESDIR}/${P}-classpath.patch"
}

src_compile() {
	export PTII=${S}
	econf || die "econf failed"
	make -C com/microstar
	emake || die "emake failed"
}

src_install() {
	make install
	make install -C com/microstar/
	if use doc ; then
		java-pkg_dohtml -r doc
	fi
	fperms 0755 bin/ptinvoke
	dobin bin/ptinvoke
	dosym /usr/bin/ptinvoke  /usr/bin/histogram
	dosym /usr/bin/ptinvoke  /usr/bin/ptplot
	dosym /usr/bin/ptinvoke  /usr/bin/pxgraph


	if use source; then
		java-pkg_dosrc ptolemy/*
		java-pkg_dosrc com/*
	fi

	java-pkg_dojar ${S}/ptolemy/gui/gui.jar || die " installing gui.jar"
	java-pkg_dojar ${S}/ptolemy/plot/*.jar || die "installingptolemy/plot/*.jar "
	java-pkg_dojar ${S}/ptolemy/util/*.jar || die " installing ptolemy/util/*.jar"
	java-pkg_dojar ${S}/com/microstar/xml/xml.jar || die " installing xml.jar"
	dosed "s:@PTII_DEFAULT@:\$(java-config -p ptplot):g" /usr/bin/ptinvoke || die "dosed fialed"
}
