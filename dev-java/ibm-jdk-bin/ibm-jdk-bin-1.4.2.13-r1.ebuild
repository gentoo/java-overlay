# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_SUPPORTS_GENERATION_1="true"
JAVA_VM_BUILD_ONLY="TRUE"
inherit java-vm-2 eutils versionator

JDK_RELEASE=$(get_version_component_range 1-3)
SERVICE_RELEASE=$(get_version_component_range 4)
RPM_PV="${JDK_RELEASE}-${SERVICE_RELEASE}.0"

JDK_DIST_PREFIX="IBMJava2-SDK-${RPM_PV}"
JAVACOMM_DIST_PREFIX="IBMJava2-JAVACOMM-${RPM_PV}"

X86_JDK_DIST="${JDK_DIST_PREFIX}.tgz"
X86_JAVACOMM_DIST="${JAVACOMM_DIST_PREFIX}.tgz"

# wonder why amd64 has this extra special AMD64 in its filename...
AMD64_JDK_DIST="IBMJava2-SDK-AMD64-${RPM_PV}.x86_64.tgz"
AMD64_JAVACOMM_DIST="IBMJava2-JAVACOMM-AMD64-${RPM_PV}.x86_64.tgz"

PPC_JDK_DIST="${JDK_DIST_PREFIX}.ppc.tgz"
PPC_JAVACOMM_DIST="${JAVACOMM_DIST_PREFIX}.ppc.tgz"

PPC64_JDK_DIST="${JDK_DIST_PREFIX}.ppc64.tgz"
PPC64_JAVACOMM_DIST="${JAVACOMM_DIST_PREFIX}.ppc64.tgz"

if use x86; then
	JDK_DIST=${X86_JDK_DIST}
	JAVACOMM_DIST=${X86_JAVACOMM_DIST}
	S="${WORKDIR}/IBMJava2-142"
	LINK_ARCH="ia32"
elif use amd64; then
	JDK_DIST=${AMD64_JDK_DIST}
	JAVACOMM_DIST=${AMD64_JAVACOMM_DIST}
	S="${WORKDIR}/IBMJava2-amd64-142"
	LINK_ARCH="amd64"
elif use ppc; then
	JDK_DIST=${PPC_JDK_DIST}
	JAVACOMM_DIST=${PPC_JAVACOMM_DIST}
	S="${WORKDIR}/IBMJava2-ppc-142"
	LINK_ARCH="ip32"
elif use ppc64; then
	JDK_DIST=${PPC64_JDK_DIST}
	JAVACOMM_DIST=${PPC64_JAVACOMM_DIST}
	S="${WORKDIR}/IBMJava2-ppc64-142"
	LINK_ARCH="ip64"
fi

DIRECT_DOWNLOAD="https://www14.software.ibm.com/webapp/iwm/web/preLogin.do?source=lxdk&S_PKG=${LINK_ARCH}142sr${SERVICE_RELEASE}&cp=UTF-8&S_TACT=105AGX05&S_CMP=JDK"

DESCRIPTION="IBM Java SE Development Kit"
HOMEPAGE="http://www.ibm.com/developerworks/java/jdk/"
DOWNLOADPAGE="${HOMEPAGE}linux/download.html"
# bug #125178
ALT_DOWNLOADPAGE="${HOMEPAGE}linux/older_download.html"

SRC_URI="x86? ( ${X86_JDK_DIST} )
	amd64? ( ${AMD64_JDK_DIST} )
	ppc? ( ${PPC_JDK_DIST} )
	ppc64? ( ${PPC64_JDK_DIST} )
	javacomm? (
		x86? ( ${X86_JAVACOMM_DIST} )
		amd64? ( ${AMD64_JAVACOMM_DIST} )
		ppc? ( ${PPC_JAVACOMM_DIST} )
		ppc64? ( ${PPC64_JAVACOMM_DIST} )
	)"

LICENSE="IBM-J1.4"
SLOT="1.4"
KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"
IUSE="X alsa examples javacomm nsplugin"

RDEPEND="=virtual/libstdc++-3.3
	alsa? ( media-libs/alsa-lib )
	X? (
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXp
		x11-libs/libXtst
		x11-libs/libXt
		x11-libs/libX11
	)"

RESTRICT="fetch"

QA_TEXTRELS_amd64="opt/${P}/jre/bin/libj9jit23.so
	opt/${P}/jre/bin/libjclscar_23.so
	opt/${P}/jre/bin/j9vm/libjclscar_23.so
	opt/${P}/jre/bin/j9vm/libj9jit23.so
	opt/${P}/jre/bin/libjclscar_22.so
	opt/${P}/jre/bin/libj9jit22.so"
QA_TEXTRELS_ppc64="opt/${P}/jre/bin/classic/libjvm.so"
QA_TEXTRELS_ppc="opt/${P}/jre/bin/libjitc.so
	opt/${P}/jre/bin/libjaas.so"
QA_TEXTRELS_x86="opt/${P}/jre/bin/lib*.so
	opt/${P}/jre/bin/javaplugin.so
	opt/${P}/jre/bin/classic/libjvm.so
	opt/${P}/jre/bin/classic/libcore.so"

pkg_nofetch() {
	einfo "Due to license restrictions, we cannot redistribute or fetch the distfiles"
	einfo "Please visit: ${DOWNLOADPAGE}"

	einfo "Under Java 1.4.2, download SR${SERVICE_RELEASE} for your arch:"
	einfo "${JDK_DIST}"
	if use javacomm ; then
		einfo "${JAVACOMM_DIST}"
	fi
	einfo "You can also use direct link to your arch download page:"
	einfo "${DIRECT_DOWNLOAD}"
	einfo "Place the file(s) in: ${DISTDIR}"
	einfo "Then restart emerge: 'emerge --resume'"

	einfo "Note: if SR${SERVICE_RELEASE} is not available at ${DOWNLOADPAGE}"
	einfo "it may have been moved to ${ALT_DOWNLOADPAGE}. Lately that page"
	einfo "isn't updated, but the files should still available through the"
	einfo "direct link to arch download page. If it doesn't work, file a bug."
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# bug #126105
	epatch "${FILESDIR}/${PN}-jawt.h.patch"
}

src_compile() { true; }

src_install() {
	# javaws is on x86 only
	if use x86; then
		# The javaws execution script is 777 why?
		chmod 0755 "${S}"/jre/javaws/javaws

		# bug #147259
		dosym ../jre/javaws/javaws /opt/${P}/bin/javaws
		dosym ../javaws/javaws /opt/${P}/jre/bin/javaws
	fi

	# Copy all the files to the designated directory
	dodir /opt/${P}
	cp -pR "${S}"/{bin,jre,lib,include,src.jar} "${D}"/opt/${P}/

	dodir /opt/${P}/share
	if use examples; then
		cp -pPR "${S}"/demo "${D}"/opt/${P}/share/
	fi

	# setting the ppc stuff
	if use ppc; then
		dosed s:/proc/cpuinfo:/etc//cpuinfo:g /opt/${P}/jre/bin/libjitc.so
		dosed s:/proc/cpuinfo:/etc//cpuinfo:g /opt/${P}/jre/bin/libjitc_g.so
		insinto /etc
		doins "${FILESDIR}/cpuinfo"
	fi

	if use x86 && use nsplugin; then
		local plugin="libjavaplugin_oji.so"

		if has_version '>=sys-devel/gcc-3' ; then
			plugin="libjavaplugin_ojigcc3.so"
		fi

		install_mozilla_plugin /opt/${P}/jre/bin/${plugin}
	fi

	dohtml -a html,htm,HTML -r docs
	dodoc "${S}"/docs/COPYRIGHT

	set_java_env
	java-vm_revdep-mask
}
