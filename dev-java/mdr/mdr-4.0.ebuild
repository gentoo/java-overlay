# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Netbeans Metadata Repository project"

HOMEPAGE="http://mdr.netbeans.org"

SRC_URI="netbeans-4_0-src-ide_sources.tar.bz2"

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
	local antflags
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	cd nbbuild

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY

	yes yes 2>/dev/null | ant all-mdr || die "Compiling failed"
	cd $S/mdr

	#make the zip to easily collect the files
	ant download || die "Failed to package the files to a temporary zip"
}

src_install() {
	cd mdr
	unzip mdr-standalone.zip -d $T
	cd $T
	java-pkg_dojar *.jar
	dodoc licenses.txt versioninfo.txt
}
