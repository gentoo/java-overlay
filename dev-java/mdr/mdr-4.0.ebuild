# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Netbeans Metadata Repository project"

HOMEPAGE="http://mdr.netbeans.org"

BASELOCATION=" \
http://www.netbeans.org/download/4_0/fcs/200412081800/d5a0f13566068cb86e33a46ea130b207"

SRC_URI="${BASELOCATION}/netbeans-4_0-src-ide_sources.tar.bz2"

#We need to add many licenses here
LICENSE=""

SLOT="0"

KEYWORDS="~x86"

IUSE=""

DEPEND="app-arch/unzip
		virtual/jdk
		"

RDEPEND="virtual/jre"

S=${WORKDIR}/netbeans-src

src_compile() {
	local antflags="-Dnetbeans.no.pre.unscramble=true"
	cd nbbuild

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY

	yes yes 2>/dev/null | ant $antflags all-mdr || die "Compiling failed"

	#make the zip to easily collect the files
	cd $S/mdr
	ant download || die "Failed to package the files to a temporary zip"
}

src_install() {
	cd mdr
	unzip mdr-standalone.zip -d $T
	cd $T
	java-pkg_dojar *.jar
	dodoc licenses.txt
}
