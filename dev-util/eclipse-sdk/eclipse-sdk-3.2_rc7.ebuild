# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-sdk/eclipse-sdk-3.1.2-r2.ebuild,v 1.1 2006/04/20 13:49:19 nichoj Exp $

inherit eutils java-pkg-2 flag-o-matic check-reqs

MY_PV=${PV/_rc/RC}
DATESTAMP=200606021317
MY_A="eclipse-sourceBuild-srcIncluded-${MY_PV}.zip"
DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
#SRC_URI="http://ftp.osuosl.org/pub/eclipse/eclipse/downloads/drops/S-${MY_PV}-${DATESTAMP}/${MY_A}"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/S-${MY_PV}-${DATESTAMP}/${MY_A}
http://dev.gentoo.org/~nichoj/distfiles/${P}-patches.tar.bz2"
IUSE="nogecko-sdk gnome cairo opengl"
SLOT="3.2"
LICENSE="EPL-1.0"
# TODO might be able to have ia64 and ppc64 support
KEYWORDS="~x86 ~ppc ~amd64"
S="${WORKDIR}"

COMMON_DEP="
	>=x11-libs/gtk+-2.2.4
	!nogecko-sdk? ( net-libs/gecko-sdk )
	gnome? ( =gnome-base/gnome-vfs-2* =gnome-base/libgnomeui-2* )
	opengl? ( virtual/opengl )
	>=dev-java/ant-core-1.6.5
	>=dev-java/ant-tasks-1.6.5
	=dev-java/lucene-1*"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND="
	${COMMON_DEP}
	=virtual/jdk-1.4*
	>=virtual/jdk-1.5
	>=sys-apps/findutils-4.1.7
	app-arch/unzip
	app-arch/zip"
# Force 1.4 to be used for building
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

src_unpack() {
	unpack ${A}

	fix-swt-targets
	
	pushd plugins/org.apache.ant/lib >/dev/null
	rm *.jar
	java-pkg_jar-from ant-core,ant-tasks
	popd >/dev/null

	pushd plugins/org.junit >/dev/null
	rm *.jar
	java-pkg_jar-from junit
	popd >/dev/null

	pushd plugins/org.apache.lucene >/dev/null
	rm *.jar
	java-pkg_jar-from lucene-1 lucene.jar lucene-1.4.3.jar
	popd >/dev/null

	# TODO replace stuff in plugins/org.eclipse.team.cvs.ssh2
	# TODO replace stuff in plugins/org.eclipse.tomcat
	# TODO replace stuff in plugins/org.junit4

	# begin: patches/comments from fedora

	# Build JNI libs
	# FIXME:  these should be built by upstream build method
	# http://www.bagu.org/eclipse/plugin-source-drops.html
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=71637
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=86848
	# GNU XML issue identified by Michael Koch
	# patches 2, 4, 5
	epatch ${WORKDIR}/${P}-build.patch
	epatch ${WORKDIR}/${P}-libupdatebuild.patch
	epatch ${WORKDIR}/${P}-libupdatebuild2.patch 

	# Build swttools.jar
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=90364
	pushd plugins/org.eclipse.swt.gtk.linux.x86_64 >/dev/null
	epatch ${WORKDIR}/${P}-swttools.patch # patch18
	popd >/dev/null

	# install location should automatically be added to homedir 
	# if ECLIPSE_HOME is not writable
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=90630
	epatch ${WORKDIR}/${P}-updatehomedir.patch # patch22

	# .so files installed in a strange location
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=90535
	pushd plugins/org.eclipse.core.runtime >/dev/null
	epatch ${WORKDIR}/${P}-fileinitializer.patch # patch24
	popd >/dev/null

	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=98707 
	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=178726
# TODO figure out why this doesn't apply
#	pushd plugins/org.eclipse.compare >/dev/null
#	epatch ${WORKDIR}/${P}-compare-create-api.patch # patch 33
#	popd >/dev/null

	# JPackage []s in names of symlinks ...
	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=162177
	pushd plugins/org.eclipse.jdt.core >/dev/null
	epatch ${WORKDIR}/${P}-bz162177.patch # patch34
	popd >/dev/null

	epatch ${WORKDIR}/${P}-genjavadocoutput.patch # patch35

	# buildHelpIndex caused a OutOfMemoryException
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=114001
	epatch ${WORKDIR}/${P}-helpindexbuilder.patch # patch38

	epatch ${WORKDIR}/${P}-usebuiltlauncher.patch # patch40

	# Eclipse launcher does not follow symlinks
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=79592
	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=168726
	mkdir launchertmp
	unzip -d launchertmp \
		plugins/org.eclipse.platform/launchersrc.zip >/dev/null || die "unzip failed"
	pushd launchertmp >/dev/null
	epatch ${WORKDIR}/${P}-launcher-link.patch # patch47
	zip -9 -r ../launchersrc.zip * >/dev/null || die "zip failed"
	popd >/dev/null
	mv launchersrc.zip plugins/org.eclipse.platform
	rm -rf launchertmp

	pushd features/org.eclipse.platform.launchers >/dev/null
	epatch ${WORKDIR}/${P}-launcher-link.patch # patch47
	popd >/dev/null

	# Don't attempt to link to Sun's javadocs
	epatch ${WORKDIR}/${P}-javadoclinks.patch # patch48

	# generic releng plugins that can be used to build plugins
	# see this thread for deails: 
	# https://www.redhat.com/archives/fedora-devel-java-list/2006-April/msg00048.html
	pushd plugins/org.eclipse.pde.build >/dev/null
	epatch ${WORKDIR}/${P}-pde.build-add-package-build.patch # patch53
	sed --in-place "s:@eclipse_base@:${ECLIPSE_DIR}:" templates/package-build/build.properties
	popd >/dev/null

	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=191536
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=142861
	pushd plugins/org.eclipse.swt/Eclipse\ SWT >/dev/null
	epatch ${WORKDIR}/${P}-swt-rm-ON_TOP.patch # patch54
	popd >/dev/null

	# We need to disable junit4 and apt until GCJ can handle Java5 code
	# FIXME for some reason junit isn't using java5...
	epatch ${WORKDIR}/${P}-disable-junit4-apt.patch # patch55
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
	echo "-Djava.library.path=/usr/lib" >> ${D}/${ECLIPSE_DIR}/eclipse.ini

	debug-print "Installing eclipse-gtk binary"
	doexe eclipse || die "Failed to install eclipse binary"

	# Install startup script
	exeinto /usr/bin
	doexe ${FILESDIR}/eclipse-${SLOT}

	make_desktop_entry eclipse-${SLOT} "Eclipse ${PV}" "${ECLIPSE_DIR}/icon.xpm"
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

fix-swt-targets() {
	# Select the set of native libraries to compile
	local targets="make_swt make_awt make_atk"

	if use gnome ; then
		einfo "Enabling GNOME VFS support"
		targets="${targets} make_gnome"
	fi

	if ! use nogecko-sdk ; then
		einfo "Enabling embedded Mozilla support"
		targets="${targets} make_mozilla"
	fi

	if use cairo ; then
		einfo "Enabling CAIRO support"
		targets="${targets} make_cairo"
	fi

	if use opengl ; then
		einfo "Enabling OpenGL support"
		targets="${targets} make_glx"
	fi

	sed -i "s/^all:.*/all: ${targets}/" \
		"plugins/org.eclipse.swt/Eclipse SWT PI/gtk/library/make_linux.mak" \
		|| die "Failed to tweak make_linux.mak"
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

pkg_postinst() {
	einfo "Users can now install plugins via Update Manager without any"
	einfo "tweaking."
	echo
	einfo "Eclipse plugin packages (ie eclipse-cdt) will likely go away in"
	einfo "the near future until they can be properly packaged. Update Manager"
	einfo "is prefered in the meantime."
}
