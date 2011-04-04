# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Build written by Andrew John Hughes (ahughes@redhat.com)

EAPI="2"

inherit eutils java-pkg-2 java-vm-2

LICENSE="GPL-2 GPL-2-with-linking-exception LGPL-2"
SLOT="7"
#KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="FOSS Java browser plugin and Web Start implementation"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="doc +nsplugin"

RDEPEND="dev-java/icedtea:7
	 nsplugin? ( >=net-libs/xulrunner-1.9.1 )"
DEPEND="${RDEPEND}"

# a bit of hack so the VM switching is triggered without causing dependency troubles
JAVA_PKG_NV_DEPEND=">=virtual/jdk-1.6"
JAVA_PKG_WANT_SOURCE="1.6"
JAVA_PKG_WANT_TARGET="1.6"

pkg_setup() {
	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version dev-java/icedtea:7; then
		JAVA_PKG_FORCE_VM="icedtea7"
	else
		JAVA_PKG_FORCE_VM=""
		# don't die just yet if merging a binpkg - bug #258423
		DIE_IF_NOT_BINPKG=true
	fi

	# if the previous failed, don't even run java eclasses pkg_setup
	# as it might also die when no VM is present
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
		java-vm-2_pkg_setup
		java-pkg-2_pkg_setup
	fi
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_unpack() {
	if [[ -n ${DIE_IF_NOT_BINPKG} ]]; then
		die "Unable to find a supported VM for building"
	fi

	default
}

src_configure() {
	local vmhome=$(java-config -O)
	local icedtea7dir="${ROOT}usr/$(get_libdir)/icedtea7"

	unset_vars

	if [[ ${vmhome} == ${icedtea7dir} ]] ; then
		installdir=${vmhome}
		VMHANDLE="icedtea7"
	else
		die "Unexpected install location of IcedTea7"
	fi

	elog "Installing IcedTea-Web in ${installdir}"
	if [ ! -e ${installdir} ] ; then
		eerror "Could not find JDK install directory ${installdir}."
	fi

	econf \
		--prefix=${installdir} \
		--with-jdk-home=${vmhome} \
		$(use_enable doc docs) \
		$(use_enable nsplugin plugin) \
		|| die "configure failed"
}

src_compile() {
	# we need this to override the src_compile from java-pkg-2
	default
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS README NEWS || die

	if use nsplugin; then
		local arch=${ARCH};
		use x86 && arch=i386;
		install_mozilla_plugin "${installdir}/jre/lib/${arch}/IcedTeaPlugin.so";
	fi
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
