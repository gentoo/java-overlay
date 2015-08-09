# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils java-pkg-2

DESCRIPTION="A Java plotting package"
HOMEPAGE="http://ptolemy.eecs.berkeley.edu/java/${PN}${PV}/ptolemy/plot/doc/index.htm"
SRC_URI="http://ptolemy.eecs.berkeley.edu/java/${PN}${PV}/ptolemy/plot/${PN}${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc source"
RESTRICT="test" #Test target broken and no tests available.
DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${PN}${PV}

src_unpack() {
	unpack ${A}
	einfo "Removing bundled jar files."
	for i in `find . -name "*.jar"` ; do
		rm -v -f "${i}" || die "rm failed"
	done
	einfo "Removing bundled class files."
	for i in `find . -name "*.class"` ; do
		rm -v -f "${i}" || die "rm failed"
	done
	epatch "${FILESDIR}/${P}-classpath.patch"
}

src_compile() {
	export PTII=${S}
	econf || die "econf failed"
	emake -C com/microstar || die "emake com.microstar failed"
	emake || die "emake failed"
}

src_install() {
	#The following make install doesn't really install anything but are required for things to work.
	make install || die "local make install failed"
	make install -C com/microstar/ || die "local com.microstar make install failed"
	fperms 0755 bin/ptinvoke
	dobin bin/ptinvoke
	dosym /usr/bin/ptinvoke  /usr/bin/histogram
	dosym /usr/bin/ptinvoke  /usr/bin/ptplot
	dosym /usr/bin/ptinvoke  /usr/bin/pxgraph
	use doc && java-pkg_dohtml -r doc ptolemy/plot/doc && java-pkg_dojavadoc doc/codeDoc
	use source && java-pkg_dosrc ptolemy/* com/*
	java-pkg_dojar ptolemy/gui/gui.jar ptolemy/plot/*.jar ptolemy/util/*.jar com/microstar/xml/xml.jar
	dosed "s:@PTII_DEFAULT@:\$(java-config -p ptplot):g" /usr/bin/ptinvoke || die "dosed fialed"
}
