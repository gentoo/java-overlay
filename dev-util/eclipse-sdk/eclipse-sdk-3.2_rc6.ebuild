# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-sdk/eclipse-sdk-3.1.2-r2.ebuild,v 1.1 2006/04/20 13:49:19 nichoj Exp $

inherit eutils java-pkg-2 flag-o-matic check-reqs

MY_PV=${PV/_rc/RC}
DATESTAMP=200605260010
MY_A="eclipse-sourceBuild-srcIncluded-${MY_PV}.zip"
DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
#SRC_URI="http://ftp.osuosl.org/pub/eclipse/eclipse/downloads/drops/S-${MY_PV}-${DATESTAMP}/${MY_A}"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/S-${MY_PV}-${DATESTAMP}/${MY_A}"
IUSE="nogecko-sdk gnome cairo opengl"
SLOT="3.2"
LICENSE="EPL-1.0"
KEYWORDS="~x86 ~ppc ~amd64"
S="${WORKDIR}"

COMMON_DEP="
	>=x11-libs/gtk+-2.2.4
	!nogecko-sdk? ( net-libs/gecko-sdk )
	gnome? ( =gnome-base/gnome-vfs-2* =gnome-base/libgnomeui-2* )
	opengl? ( virtual/opengl )"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND="
	${COMMON_DEP}
	=virtual/jdk-1.4*
	>=virtual/jdk-1.5
	>=dev-java/ant-1.6.2
	>=dev-java/ant-core-1.6.2-r4
	>=sys-apps/findutils-4.1.7
	app-arch/unzip
	app-arch/zip"
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4*"

ECLIPSE_DIR="/usr/lib/eclipse-${SLOT}"
ECLIPSE_LINKS_DIR="${ECLIPSE_DIR}/links"

# TODO:
# - use CFLAGS from make.conf when building native libraries
#   - must patch eclipse build files
#   - also submit patch to bugs.eclipse.org
# - ppc support not tested, but not explicitly broken either
# - make a extension location in /var/lib that's writable by 'eclipse' group
# - update man page

pkg_setup() {
	java-pkg-2_pkg_setup

	debug-print "Checking for sufficient physical RAM"
	CHECKREQS_MEMORY="768"
	check_reqs

	# All other gentoo archs match in eclipse build system except amd64
	if use amd64 ; then
		eclipsearch=x86_64
	else
		eclipsearch=${ARCH}
	fi

	if use x86 ; then
		jvmarch=i386
	else
		jvmarch=${ARCH}
	fi

	# Add the eclipse group, for our plugins/features directories
	enewgroup eclipse
}

ant_src_unpack() {
	unpack ${A}

	#   1: fix classpath (eclipse bug #128921)
	#   2: fix building of native code filesystem library
	#      - hard coded JAVA_HOME, use ebuild CFLAGS
	#   3: fix building of native update code library
	#      - remove hard coded x86 path
	#      - some gcc versions refuse if both -static and -fPIC are used
	epatch ${FILESDIR}/${PN}-3.2_rc3-gentoo.patch

	einfo "Cleaning out prebuilt code"
	clean-prebuilt-code

	einfo "Patching makefiles"
	fix_makefiles
}

src_compile() {
	# Figure out VM, set up ant classpath and native library paths
	setup-jvm-opts

	if ! use nogecko-sdk ; then
		einfo "Will compile embedded Mozilla support against net-libs/gecko-sdk"
		setup-mozilla-opts
	else
		einfo "Not building embedded Mozilla support"
	fi

	local java5vm=$(depend-java-query --get-vm ">=virtual/jdk-1.5")
	local java5home=$(GENTOO_VM=${java5vm} java-config --jdk-home)
	einfo "Using ${java5home} for java5home"
	# TODO patch build to take buildId
	./build -os linux \
		-arch ${eclipsearch} \
		-ws gtk \
		-java5home ${java5home} || die "build failed"
	cp eclipse/eclipse eclipse-gtk || die "Cannot find eclipse binary"
}

src_install() {
	dodir /usr/lib

	# TODO maybe there's a better way of installing than extracting the tar?
	[[ -f result/linux-gtk-${eclipsearch}-sdk.tar.gz ]] || die "tar.gz bundle was not built properly!"
	tar zxf result/linux-gtk-${eclipsearch}-sdk.tar.gz -C ${D}/usr/lib \
		|| die "Failed to extract the built package"

	mv ${D}/usr/lib/eclipse ${D}/${ECLIPSE_DIR}
	insinto ${ECLIPSE_DIR}
	exeinto ${ECLIPSE_DIR}

	debug-print "Installing eclipse-gtk binary"
	doexe eclipse-gtk || die "Failed to install eclipse binary"
	# need to rename inf file to eclipse-gtk.ini, see bug #128128
	newins eclipse.ini eclipse-gtk.ini

	# Install startup script
	exeinto /usr/bin
	doexe ${FILESDIR}/eclipse-${SLOT}
	doman ${FILESDIR}/eclipse.1

	make_desktop_entry eclipse-${SLOT} "Eclipse ${PV}" "${ECLIPSE_DIR}/icon.xpm"

	install-link-files

	# eventually, we'll have a user writable extension location, so we'll
	# comply with FHS 

	#dodir /var/lib/eclipse-${SLOT}
	#touch ${D}/var/lib/eclipse-${SLOT}/.eclipseextension
	#fowners root:eclipse /var/lib/eclipse-${SLOT}
	#fperms -R g+w /var/lib/eclipse-${SLOT}
	fperms -R g+w ${ECLIPSE_DIR}
	fowners -R root:eclipse ${ECLIPSE_DIR}
	find ${D}${ECLIPSE_DIR} -type d -exec chmod g+s {} \;
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

fix_makefiles() {
	# Select the set of native libraries to compile
	local targets="make_swt make_awt make_atk"

	if use gnome ; then
		einfo "Building GNOME VFS support"
		targets="${targets} make_gnome"
	fi

	if ! use nogecko-sdk ; then
		einfo "Building Mozilla embed support"
		targets="${targets} make_mozilla"
	fi

	if use cairo ; then
		einfo "Building CAIRO support"
		targets="${targets} make_cairo"
	fi

	if use opengl ; then
		einfo "Building OpenGL support"
		targets="${targets} make_glx"
	fi

	sed -i "s/^all:.*/all: ${targets}/" \
		"plugins/org.eclipse.swt/Eclipse SWT PI/gtk/library/make_linux.mak" \
		|| die "Failed to tweak make_linux.mak"
}

clean-prebuilt-code() {
	find ${S} -type f \( -name '*.class' -o -name '*.so' -o -name '*.so.*' -o -name 'eclipse' \) | xargs rm -f
}

setup-jvm-opts() {
	# Figure out correct boot classpath
	# karltk: this should be handled by the java-pkg eclass in setup-vm
	local bp="$(java-config --jdk-home)/jre/lib"
	local bootclasspath=$(java-config --runtime)
	if [[ ! -z "`java-config --java-version | grep IBM`" ]] ; then
		# IBM JDK
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/bin"
	else
		# Sun derived JDKs (Blackdown, Sun)
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/lib/${jvmarch}"
	fi

	einfo "Using bootclasspath ${bootclasspath}"
	einfo "Using JVM library path ${JAVA_LIB_DIR}"

	if [[ ! -f ${JAVA_LIB_DIR}/libawt.so ]] ; then
	    die "Could not find libawt.so native library"
	fi

	export AWT_LIB_PATH=${JAVA_LIB_DIR}
}

setup-mozilla-opts() {
	mozilla_dir="--mozdir-unset---"

	if [[ -f ${ROOT}/usr/lib/gecko-sdk/lib/libgtkembedmoz.so ]] ; then
		mozilla_dir=/usr/lib/gecko-sdk
	else
		# TODO need to update this appropriately for gecko-sdk
		eerror "You have enabled the embedded mozilla component, but no suitable"
		eerror "provider was found. You need gecko-sdk compiled against"
		eerror "gtk+ v2.0 or newer."
		eerror "To merge it, execute 'USE=\"gtk2\" emerge mozilla' as root."
		eerror "To disable embedded mozilla, remove \"mozilla\" from your USE flags."
		die "Need Mozilla compiled with gtk+-2.x support"
	fi

	export GECKO_SDK="${mozilla_dir}"
	# TODO should this be using pkg-config?
	export GECKO_INCLUDES="-include ${GECKO_SDK}/include/mozilla-config.h \
		-I${GECKO_SDK}/include/nspr \
		-I${GECKO_SDK}/include/nspr \
		-I${GECKO_SDK}/include/xpcom \
		-I${GECKO_SDK}/include/string \
		-I${GECKO_SDK}/include/embed_base \
		-I${JAVA_HOME}/include/linux"
	export GECKO_LIBS="-L${GECKO_SDK}/lib -lgtkembedmoz"
}

install_link_file() {
	local path=${1}
	local file=${2}

	echo "path=${path}" > "${D}/${ECLIPSE_LINKS_DIR}/${file}"
}

install-link-files() {
	dodir ${ECLIPSE_LINKS_DIR}
	install_link_file /opt/eclipse-extensions-3 eclipse-binary-extensions-3.link
	install_link_file /opt/eclipse-extensions-${SLOT} eclipse-binary-extensions-${SLOT}.link

	install_link_file /usr/lib/eclipse-extensions-3 eclipse-extensions-3.link 
	install_link_file /usr/lib/eclipse-extensions-${SLOT} eclipse-extensions-${SLOT}.link

#	install_link_file /var/lib/eclipse-3 eclipse-var-3.link
#	install_link_file /var/lib/eclipse-${SLOT} eclipse-var-${SLOT}.link
}

pkg_postinst() {
	einfo "In order to use the Update Manager, add yourself to the 'eclipse' group"
	echo
	einfo "Eclipse plugin packages (ie eclipse-cdt) will likely go away in"
	einfo "the near future until they can be properly packaged. Update Manager"
	einfo "is prefered in the meantime."
}
