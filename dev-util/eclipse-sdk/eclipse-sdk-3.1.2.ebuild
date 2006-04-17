# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-sdk/eclipse-sdk-3.1.1.ebuild,v 1.1 2005/11/09 19:00:28 axxo Exp $

inherit eutils java-utils flag-o-matic

MY_A="eclipse-sourceBuild-srcIncluded-${PV}.zip"
RELEASE_DATE="200601181600"
DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/R-${PV}-${RELEASE_DATE}/${MY_A}"
IUSE="gecko-sdk gnome jikes source doc atk"
SLOT="3.1"
LICENSE="CPL-1.0"
KEYWORDS="~x86 ~ppc ~amd64"
S="${WORKDIR}"

RDEPEND=">=virtual/jre-1.4.2
	>=x11-libs/gtk+-2.2.4
	gecko-sdk? ( net-libs/gecko-sdk )
	atk? ( >=dev-libs/atk-1.6 )
	gnome? ( =gnome-base/gnome-vfs-2* =gnome-base/libgnomeui-2* )"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4.2
	jikes? ( >=dev-java/jikes-1.21 )
	>=dev-java/ant-1.6.2
	>=dev-java/ant-core-1.6.2-r4
	>=sys-apps/findutils-4.1.7
	app-arch/unzip
	app-arch/zip"

ECLIPSE_DIR="/usr/lib/eclipse-${SLOT}"
ECLIPSE_LINKS_DIR="${ECLIPSE_DIR}/links"

# TODO:
# - use CFLAGS from make.conf when building native libraries
#   - must patch eclipse build files
#   - also submit patch to bugs.eclipse.org
# - intergration to eclipse plugin ebuilds most likely broken
# - ppc support not tested, but not explicitly broken either

pkg_setup() {
	debug-print "Checking for sufficient physical RAM"
	check-ram
	debug-print "Checking for bad CFLAGS"
	check-cflags

	# Make sure our vm is sane
	java-utils_setup-vm
	java-utils_ensure-vm-version-ge 1 4 2

	# All other gentoo archs match in eclipse build system except amd64
	if use amd64 ; then
		eclipsearch=x86_64
	else
		eclipsearch=${ARCH}
	fi

	# All other gentoo archs match in sun jdk library patch except x86
	if use x86 ; then
		jvmarch=i386
	else
		jvmarch=${ARCH}
	fi

	# Add the eclipse group, for our plugin directories
	enewgroup eclipse
}

src_unpack() {
	unpack ${A}

	# TODO figure out what this does -nichoj
	epatch ${FILESDIR}/06-path-fixups.patch

	einfo "Setting up virtual machine"
	java-utils_setup-vm

	einfo "Cleaning out prebuilt code"
	clean-prebuilt-code

	einfo "Patching makefiles"
	fix_makefiles
	fix_amd64_ibm_jvm
}

src_compile() {
	# karltk: this should be handled by the java-pkg eclass in setup-vm 
	addwrite "/proc/self/maps"
	addwrite "/proc/cpuinfo"
	addwrite "/dev/random"

	# Figure out VM, set up ant classpath and native library paths
	setup-jvm-opts

	if use gecko-sdk ; then
		einfo "Will compile embedded Mozilla support against net-libs/gecko-sdk"
		setup-mozilla-opts
	else
		einfo "Not building embedded Mozilla support"
	fi

	use jikes && bootstrap_ant_opts="-Dbuild.compiler=jikes"

	debug-print "Bootstrapping bootstrap ecj"
	ant ${bootstrap_ant_opts} -q -f jdtcoresrc/compilejdtcorewithjavac.xml || die "Failed to bootstrap ecj"

	debug-print "Bootstrapping ecj"
	ant -lib jdtcoresrc/ecj.jar -q -f jdtcoresrc/compilejdtcore.xml || die "Failed to bootstrap ecj"

	debug-print "Compiling Eclipse -- see ${S}/compilelog.txt for details"
	ANT_OPTS="-Xmx1024M" \
		ant -lib jdtcoresrc/ecj.jar -q -f build.xml \
		-DinstallOs=linux \
		-DinstallWs=gtk \
		-DinstallArch=${eclipsearch} \
		-Dbootclasspath=${bootclasspath} \
		-Dlibsconfig=true \
		-DjavacTarget=1.4 \
		-DjavacSource=1.4 \
		-DjavacVerbose=false \
		-DjavacFailOnError=true \
		-DjavacDebugInfo=true \
		-DbuildId="Gentoo Linux ${PF}" \
		|| die "Failed to compile Eclipse"

	cp launchertmp/eclipse eclipse-gtk || die "Cannot find eclipse binary"

	# TODO use make_desktop_entry from eutils during src_install instead -nichoj
	create-desktop-entry
}

src_install() {
	dodir /usr/lib

	debug-print "Installing features and plugins"

	# TODO figure out if we need to extract this tarball -nichoj
	[ -f result/linux-gtk-${eclipsearch}-sdk.tar.gz ] || die "tar.gz bundle was not built properly!"
	tar zxf result/linux-gtk-${eclipsearch}-sdk.tar.gz -C ${D}/usr/lib || die "Failed to extract the built package"


	mv ${D}/usr/lib/eclipse ${D}/${ECLIPSE_DIR}
	insinto ${ECLIPSE_DIR}
	exeinto ${ECLIPSE_DIR}

	debug-print "Installing eclipse-gtk binary"
	doexe eclipse-gtk || die "Failed to install eclipse binary"
	# need to rename inf file to eclipse-gtk.ini, see bug #128128

	if use "!source" ; then
		debug-print "Removing source code"
		strip-src
	fi

	if use "!doc" ; then
		debug-print "Removing documentation"
		strip-docs
	fi

	# Install startup script
	exeinto /usr/bin
	doexe ${FILESDIR}/eclipse-${SLOT}

	# TODO use make_desktop_entry from eutils instead
	install-desktop-entry

	doman ${FILESDIR}/eclipse.1

	install-link-files
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

fix_makefiles() {
	# Comment out hard-coded JAVA_HOME
	sed -i 's/^JAVA_HOME/#JAVA_HOME/' plugins/org.eclipse.core.resources.linux/src/Makefile || die "Failed to patch Makefile"

	# Select the set of native libraries to compile
	local libs="make_swt make_awt make_atk"

	if use gnome ; then
		einfo "Building GNOME VFS support"
		libs="${libs} make_gnome"
	fi

	if use gecko-sdk ; then
		einfo "Building Mozilla embed support"
		libs="${libs} make_mozilla"
	fi

	if use atk ; then
		einfo "Building ATK support"
		libs="${libs} make_atk"
	fi

	sed -i "s/^all:.*/all: ${libs}/" "plugins/org.eclipse.swt/Eclipse SWT PI/gtk/library/make_linux.mak" || die "Failed to patch make_linux.mak"
}

fix_amd64_ibm_jvm() {
	# the ibm jdk ebuild should have fixed headers, but until then
	# we just fix the compiling here (see bug #97421)
	if use amd64 ; then
	    if [ ! -z "`java-config --java-version | grep IBM`" ] ; then
			einfo "Fixing IBM jdk header problem"
			find plugins -name "make_linux.mak" -print0 | xargs -0 sed -i -e 's/^CFLAGS =/CFLAGS = -D_JNI_IMPORT_OR_EXPORT_= /'
	    fi
	fi
}


clean-prebuilt-code() {
	find ${S} -type f \( -name '*.class' -o -name '*.so' -o -name '*.so.*' -o -name 'eclipse' \) | xargs rm -f
}

get-memory-total() {
	cat /proc/meminfo | grep MemTotal | sed -r "s/[^0-9]*([0-9]+).*/\1/"
}

check-ram() {
	local mem=$(get-memory-total)
	if [ $(get-memory-total) -lt 775000 ]; then
		echo
		ewarn "To build Eclipse, at least 768MB of RAM is recommended."
		ewarn "Your machine has less RAM. Continuing anyway. If the build"
		ewarn "stops with an error about invalid memory, increase your swap."
		echo
	fi
}

check-cflags() {
	local badflags="-fomit-frame-pointer -msse2"
	local error=false
	local flag

	for flag in ${badflags} ; do
		if is-flag ${flag}; then
			ewarn "Found offending option ${flag} in your CFLAGS"
			error=true
		fi
	done
	if [ ${error} == "true" ]; then
		echo
		ewarn "One or more potentially gruesome CFLAGS detected. When you run into trouble,"
		ewarn "please edit /etc/make.conf and remove all offending flags, then recompile"
		ewarn "Eclipse and all its dependencies before submitting a bug report."
		echo
		ewarn "In particular, gtk+ is extremely sensitive to which which flags it was"
		ewarn "compiled with."
		echo
		einfo "Tip: use equery depgraph \"=${PF}\" to list all dependencies."
		echo
		ebeep
	fi
}

setup-jvm-opts() {
	# Figure out correct boot classpath
	# karltk: this should be handled by the java-pkg eclass in setup-vm
	if [ ! -z "`java-config --java-version | grep IBM`" ] ; then
		# IBM JRE
		local bp="$(java-config --jdk-home)/jre/lib"
		bootclasspath="${bp}/core.jar:${bp}/xml.jar:${bp}/graphics.jar:${bp}/security.jar:${bp}/server.jar"
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/bin"
	else
		# Sun derived JREs (Blackdown, Sun)
		local bp="$(java-config --jdk-home)/jre/lib"
		bootclasspath="${bp}/rt.jar:${bp}/jsse.jar"
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/lib/${jvmarch}"
	fi

	einfo "Using bootclasspath ${bootclasspath}"
	einfo "Using JVM library path ${JAVA_LIB_DIR}"

	if [ ! -f ${JAVA_LIB_DIR}/libawt.so ] ; then
	    die "Could not find libawt.so native library"
	fi

	export AWT_LIB_PATH=${JAVA_LIB_DIR}
}

setup-mozilla-opts() {
	mozilla_dir="--mozdir-unset---"

	if [ -f ${ROOT}/usr/lib/gecko-sdk/lib/libgtkembedmoz.so ] ; then
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

build-native() {
	sh features/org.eclipse.platform.launchers/library/gtk/build.sh \
		-os linux -ws gtk \
		-arch ${eclipsearch} || die "Failed to build launcher"
}
create-desktop-entry() {
	sed -e "s/@PV@/${PV}/" ${FILESDIR}/eclipse-${SLOT}.desktop \
		> eclipse-${SLOT}.desktop || die "Failed to create desktop entry"
}

install-desktop-entry() {
	dodir /usr/share/applications
	insinto /usr/share/applications
	doins eclipse-${SLOT}.desktop
}

install_link_file() {
	local file=${1}
	local path=${2}

	echo "path=${path}" > ${D}/${ECLIPSE_LINKS_DIR}/"${file}"
}

# TODO figure out if we really need the *-3.link files -nichoj
# TODO there's a problem with actually installing the files.
install-link-files() {
	einfo "Installing link files"

	dodir ${ECLIPSE_LINKS_DIR}
	install_link_file /opt/eclipse-extensions-3 eclipse-binary-extensions-3.link
	install_link_file /opt/eclipse-extensions-3.1 eclipse-binary-extensions-3.1.link

	install_link_file /usr/lib/eclipse-extensions-3 eclipse-extensions-3.link
	install_link_file /usr/lib/eclipse-extensions-3.1 eclipse-extensions-3.1.link

	install_link_file /var/lib/eclipse-3 eclipse-var-3.link
	install_link_file /var/lib/eclipse-3.1 eclipse-var-3.1.link
}

strip-src() {
	local bp=${D}/${ECLIPSE_DIR}

	rm -rf ${bp}/plugins/org.eclipse.pde.source_3* \
		${bp}/plugins/org.eclipse.jdt.source_3* \
		${bp}/plugins/org.eclipse.platform.source.linux.* \
		${bp}/plugins/org.eclipse.platform.source_3* \
		${bp}/features/org.eclipse.jdt.source_3* \
		${bp}/features/org.eclipse.pde.source_3* \
		${bp}/features/org.eclipse.platform.source_3*
}

strip-docs() {
	local bp=${D}/${ECLIPSE_DIR}

	rm -rf ${bp}/plugins/org.eclipse.platform.doc.* \
		${bp}/plugins/org.eclipse.jdt.doc.* \
		${bp}/plugins/org.eclipse.pde.doc.*
}
