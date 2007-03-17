# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

BUILD=6148

S="${WORKDIR}/${PN}-${BUILD}"
DESCRIPTION="An intelligent Java IDE intensely focused on developer productivity."
HOMEPAGE="http://www.jetbrains.com/idea/index.html"
SRC_URI="http://download.jetbrains.com/${PN}/${P}.tar.gz"
SLOT="0"
LICENSE="IntelliJ-IDEA"
KEYWORDS="~amd64 ~x86"
RESTRICT="nomirror nostrip"
IUSE="eclipse"

DEPEND=""
RDEPEND="=virtual/jdk-1.5*"

QA_TEXTRELS_x86="opt/${P}/bin/libbreakgen.so"

src_install () {
	dodir /usr/bin
	dodir /opt/${P}/
	dodir /usr/share/pixmaps

	insinto /opt/${P}/bin

	# Install executables
	insopts -m0755
	doins bin/idea.sh bin/inspect.sh

	# Install data files
	insopts -m0644
	doins bin/appletviewer.policy bin/libbreakgen.so bin/log4j.dtd bin/log.xml
	doins bin/libjniwrap.so bin/libp4api.so bin/libyjpagent.so
	doins bin/idea.vmoptions bin/idea.properties
	insinto /opt/${P}
	doins -r help lib plugins redist license
	use eclipse && doins -r eclipsePlugin

	# Install pixmaps
	insinto /usr/share/pixmaps
	doins bin/*.png
	
	# Install documentation
	dodoc *.txt

	# Launchers are necessary as IDEA depends on the fact being called from its
	# homedir.
	for i in idea inspect; do
		cat >${D}/opt/${P}/bin/$i-run.sh <<-EOF
#!/bin/sh
export IDEA_JDK=\`java-config -O\`
exec /opt/${P}/bin/$i.sh \$@
EOF
		fperms 755 /opt/${P}/bin/$i-run.sh

		ln -s ${D}/opt/${P}/bin/$i-run.sh ${D}/usr/bin/$i
	done

	make_desktop_entry idea "Intellij IDEA" idea32.png "Development;IDE"
}
