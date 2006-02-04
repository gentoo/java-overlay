# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN="j2me_wireless_toolkit"
MY_PV="${PV//./_}" # TODO use versionator instead
MY_P=${MY_PN}-${MY_PV}

A_bin=${MY_P}-linux-i386.bin
A_patch=${MY_P}-update_1-linux.zip

DESCRIPTION="Java 2 Micro Edition Wireless Toolkit for developing wireless applications"
HOMEPAGE="http://java.sun.com/products/j2mewtoolkit/"
SRC_URI="${A_bin} ${A_patch}"
LICENSE="sun-bcla-j2me"
SLOT="0"
KEYWORDS="~x86 -*"
IUSE="doc examples"
RESTRICT="fetch"
# Before going official with this all the jars should be checked for packed stuff
# I think the lib/jsrXXX.jar probably are at least packed jars
DEPEND=">=dev-java/sun-jaf-bin-1.0
		>=sun-javamail-bin-1.3
		app-arch/unzip"
RDEPEND="${DEPEND}
		>=virtual/jdk-1.4.2
		virtual/x11"

S=${WORKDIR}

MY_FILE=${DISTDIR}/${A}

pkg_nofetch() {
	einfo "Please download ${A} from:"
	einfo "http://java.sun.com/products/sjwtoolkit/download-2_2.html"
	einfo "and move it to ${DISTDIR}"
	
}

src_unpack() {
	if [ ! -r ${MY_FILE} ]; then
		eerror "cannot read ${A}. Please check the permission and try again."
		die
	fi
	#extract compressed data and unpack
	dd bs=2048 if=${MY_FILE} of=install.zip skip=10 2>/dev/null || die
	unzip install.zip >/dev/null || die
	rm install.zip

	#Set the java-bin-path in some scripts
	for file in ktoolbar emulator mekeytool prefs utils wscompile defaultdevice
	do
		sed ${WORKDIR}/bin/${file} --in-place --expression \
			"s@pathtowtk=\$@pathtowtk=\`java-config --jdk-home\`\"/bin/\"@" ||die
	done

	#replace included jar files with local versions
	cd bin
	rm -f activation.jar
	java-pkg_jar-from sun-jaf-bin activation.jar
	rm -f mail.jar
	java-pkg_jar-from sun-javamail-bin mail.jar
}

src_install() {
	local BIN_DESTINATION=/opt/${P}/bin
	cd ${WORKDIR}
	insinto /opt/${P}
	exeinto ${BIN_DESTINATION}
	dohtml *.html
	use doc && java-pkg_dohtml -r docs/*
	use examples && doins -r apps
	doins -r appdb bin lib wtklib
	fperms 755 ${BIN_DESTINATION}/*
	fperms 644 ${BIN_DESTINATION}/*.jar

	dodir /usr/bin
	dosym ${BIN_DESTINATION}/ktoolbar /usr/bin/ktoolbar
	make_desktop_entry ktoolbar
}
