# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.06-r2.ebuild,v 1.2 2006/03/12 13:31:29 betelgeuse Exp $

inherit java eutils

jcefile="jce_policy-1_5_0.zip"

S="${WORKDIR}/jdk${MY_PVL}"
DESCRIPTION="Sun's J2SE Cryptographic extensions, version ${PV}"
HOMEPAGE="http://java.sun.com/j2se/1.5.0/"
SRC_URI="$jcefile"
SLOT="1.5"
LICENSE="sun-bcla-java-vm"
KEYWORDS="~x86 ~amd64"
RESTRICT="fetch"
IUSE=""

DEPEND="app-arch/unzip"

FETCH_JCE="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jce_policy-1.5.0-oth-JPR&SiteId=JSC&TransactionId=noreg"

pkg_nofetch() {
	einfo "Please download ${jcefile} from:"
	einfo ${FETCH_JCE}
	einfo "Java(TM) Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files"
	einfo "and move it to ${DISTDIR}"
}

src_unpack() {
	if [ ! -r ${DISTDIR}/${jcefile} ]; then
		die "cannot read ${jcefile}. Please check the permission and try again."
	fi
}

src_install() {

	dodir /opt/${P}/jre/lib/security

	cd ${D}/opt/${P}/jre/lib/security
	unzip ${DISTDIR}/${jcefile} || die "failed to unzip jce"
	mv jce unlimited-jce
	dodir /opt/${P}/jre/lib/security/strong-jce
#	mv ${D}/opt/${P}/jre/lib/security/US_export_policy.jar ${D}/opt/${P}/jre/lib/security/strong-jce
#	mv ${D}/opt/${P}/jre/lib/security/local_policy.jar ${D}/opt/${P}/jre/lib/security/strong-jce
#	dosym /opt/${P}/jre/lib/security/unlimited-jce/US_export_policy.jar /opt/${P}/jre/lib/security/
#	dosym /opt/${P}/jre/lib/security/unlimited-jce/local_policy.jar /opt/${P}/jre/lib/security/
}
