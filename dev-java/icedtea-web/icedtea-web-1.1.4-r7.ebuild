# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea-web/icedtea-web-1.1.4-r7.ebuild,v 1.1 2011/11/24 20:57:04 sera Exp $
# Build written by Andrew John Hughes (ahughes@redhat.com)

EAPI="4"

inherit autotools eutils java-pkg-2 java-vm-2

DESCRIPTION="FOSS Java browser plugin and Web Start implementation"
HOMEPAGE="http://icedtea.classpath.org"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz"

LICENSE="GPL-2 GPL-2-with-linking-exception LGPL-2"
SLOT="7"
KEYWORDS="~amd64 ~x86"

IUSE="build doc javascript +nsplugin test"

RDEPEND="dev-java/icedtea:${SLOT}"
# Need system junit 4.8+. Bug #389795
DEPEND="${RDEPEND}
	javascript? ( dev-java/rhino:1.6 )
	nsplugin? (
		|| ( net-misc/npapi-sdk
			>=net-libs/xulrunner-1.9.1 ) )
	test? (	>=dev-java/junit-4.8:4 )"

# a bit of hack so the VM switching is triggered without causing dependency troubles
JAVA_PKG_NV_DEPEND=">=virtual/jdk-1.6"
JAVA_PKG_WANT_SOURCE="1.6"
JAVA_PKG_WANT_TARGET="1.6"

pkg_setup() {
	[[ "${MERGE_TYPE}" == "binary" ]] && return # bug 258423

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	else
		# migration logic
		if [[ -L /usr/lib/jvm/icedtea${SLOT} ]]; then
			JAVA_PKG_FORCE_VM="icedtea${SLOT}"
		else
			JAVA_PKG_FORCE_VM="icedtea-${SLOT}"
		fi
	fi

	einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_prepare() {
	# bug #356645
	epatch "${FILESDIR}"/0002-Respect-LDFLAGS.patch
	eautoreconf
}

src_configure() {
	local vmhome=$(java-config -O)

	if use build; then
		icedteadir="${ICEDTEA_BIN_DIR}"
		installdir="/opt/icedtea${SLOT}-web-bin"
	else
		icedteadir="/usr/$(get_libdir)/icedtea${SLOT}"
		installdir="/usr/$(get_libdir)/icedtea${SLOT}-web"
	fi

	unset_vars

	if use build || [[ ${vmhome} == ${icedteadir} ]] ; then
		VMHANDLE="icedtea-${SLOT}"
	else
		die "Unexpected install location of IcedTea${SLOT}"
	fi

	einfo "Installing IcedTea-Web in ${installdir}"
	einfo "Installing IcedTea-Web for Icedtea${SLOT} in ${icedteadir}"
	if [ ! -e ${vmhome} ] ; then
		eerror "Could not find JDK install directory ${vmhome}."
		die
	fi

	# we need to override all *dir variables that econf sets
	# man page (javaws) is installed directly to icedteadir because it's easier than symlinking, as we don't know
	# the suffix the man page will end up compressed with, anyway
	econf \
		--prefix=${installdir} --mandir=${icedteadir}/man --infodir=${installdir}/share/info --datadir=${installdir}/share \
		--with-jdk-home=${icedteadir} \
		$(use_enable doc docs) \
		$(use_enable nsplugin plugin) \
		$(use_with javascript rhino)
}

src_compile() {
	# we need this to override the src_compile from java-pkg-2
	default
}

src_install() {
	# parallel make problem bug #372235
	emake -j1 DESTDIR="${D}" install
	dodoc AUTHORS README NEWS

	if use nsplugin; then
		install_mozilla_plugin "${installdir}/$(get_libdir)/IcedTeaPlugin.so";
	fi

	for binary in javaws itweb-settings; do
		dosym ${installdir}/bin/${binary} ${icedteadir}/bin/${binary}
		dosym ${installdir}/bin/${binary} ${icedteadir}/jre/bin/${binary}
	done
}

pkg_postinst() {
	java-vm_check-nsplugin
	java_mozilla_clean_

	if use nsplugin; then
		elog "The icedtea browser plugin (NPPlugin) can be enabled using eselect java-nsplugin"
		elog "Note that the plugin works only in browsers based on xulrunner-1.9.1 or later"
		elog "such as Firefox 3.5+, Chromium and perhaps some others too."
	fi
}

pkg_prerm() {
	# override the java-vm-2 eclass check for removing a system VM, as it doesn't make sense here
	:;
}
