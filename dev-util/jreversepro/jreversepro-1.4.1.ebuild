# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

MY_PN="jrevpro"
DESCRIPTION="Java Decompiler / Disassembler written entirely in Java"
HOMEPAGE="http://jrevpro.sourceforge.net/"
SRC_URI="mirror://sourceforge/jrevpro/${P}-src.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}
	cd ${S}
	
	# TODO submit these upstream
	# Fix 1.5
	epatch ${FILESDIR}/${P}-java15.patch

	# Fix jref.ini -> .jrefrc
	epatch ${FILESDIR}/${P}-homedir.patch

	# misc build.xml tweaks, ie:
	# creates ${lib.dir}, changes makejar target to jar,
	# don't do depend on checkstyle for compile
	epatch ${FILESDIR}/${P}-build_xml.patch
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} docs"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	ant ${antflags} || die "compilation failed"
}

src_install() {
	java-pkg_dojar lib/${PN}.jar

	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc -r src/*

	cat > ${MY_PN} <<-END
	#!/bin/bash
	java -jar \$(java-config -p ${PN})
	END
	dobin ${MY_PN}
}
				
