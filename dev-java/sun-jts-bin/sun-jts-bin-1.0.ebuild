# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

At="jts${PV//./_}.zip"
DESCRIPTION="Java Transaction Service (JTS) specifies the implementation of a Transaction Manager which supports the Java Transaction API (JTA) 1.0"
HOMEPAGE="http://java.sun.com/products/jts/"
SRC_URI="${At}"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"
RESTRICT="fetch"

DEPEND="virtual/jdk
	app-arch/unzip
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre"
DOWNLOAD_URL="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=7310-jts-1.0-oth-JPR&SiteId=JSC&TransactionId=noreg"

pkg_nofetch() {
	einfo " "
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " distributables automagically."
	einfo " "
	einfo " 1. Visit ${HOMEPAGE}"
	einfo "   Direct link: ${DOWNLOAD_URL}"
	einfo " 2. Download ${At}"
	einfo " 3. Move file to ${DISTDIR}"
	einfo " "
}

src_unpack() {
	if [ ! -f "${DISTDIR}/${At}" ] ; then
		echo  " "
		echo  "!!! Missing ${DISTDIR}/${At}"
		echo  " "
		einfo " "
		einfo " Due to license restrictions, we cannot fetch the"
		einfo " distributables automagically."
		einfo " "
		einfo " 1. Visit ${HOMEPAGE}"
		einfo " 2. Download ${At}"
		einfo " 3. Move file to ${DISTDIR}"
		einfo " 4. Run emerge on this package again to complete"
		einfo " "
		die "User must manually download distfile"
	fi
	mkdir ${S}
	cd ${S}
	unpack ${A}
	cp ${FILESDIR}/build-${PVR}.xml build.xml
}

src_compile() {
	local antflags="-Dproject.name=jts jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/*.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
