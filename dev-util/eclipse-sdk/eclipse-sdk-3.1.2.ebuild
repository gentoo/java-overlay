# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-sdk/eclipse-sdk-3.1.1.ebuild,v 1.1 2005/11/09 19:00:28 axxo Exp $

inherit eutils java-utils

MY_A="eclipse-sourceBuild-srcIncluded-${PV}.zip"
RELEASE_DATE="200601181600"
DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/R-${PV}-${RELEASE_DATE}/${MY_A}"
# firefox has been removed, because 1.5 seems to cause some problems
IUSE="gnome mozilla jikes nosrc nodoc atk"
SLOT="3.1"
LICENSE="CPL-1.0"
KEYWORDS="~x86 ~ppc ~amd64"

RDEPEND=">=virtual/jre-1.4.2
	>=x11-libs/gtk+-2.2.4
	mozilla? ( >=www-client/mozilla-1.7 )
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

# TODO:
# - use CFLAGS from make.conf when building native libraries
#   - must patch eclipse build files
#   - also submit patch to bugs.eclipse
# - intergration to eclipse plugin ebuilds most likely broken
# - ppc support not tested, but not explicitly broken either

pkg_setup() {

	einfo "Checking for sufficient physical RAM"
	check-ram
	check-cflags

	java-utils_setup-vm

	java-utils_ensure-vm-version-ge 1 4 2

	# all other gentoo archs match in eclipse build system except amd64
	if [ ${ARCH} == 'amd64' ] ; then
		eclipsearch=x86_64
	else
		eclipsearch=${ARCH}
	fi

	# all other gentoo archs match in sun jdk library patch except x86
	if [ ${ARCH} == 'x86' ] ; then
		jvmarch=i386
	else
		jvmarch=${ARCH}
	fi
}

src_unpack() {

	mkdir ${S}
	cd ${S}
	unpack ${MY_A} || die "Could not unpack ${MY_A}"

	epatch ${FILESDIR}/06-path-fixups.patch

	einfo "Setting up virtual machine"
	java-utils_setup-vm

	einfo "Cleaning out prebuilt code"
	clean-prebuilt-code

	einfo "Patching makefiles"
	process-makefiles

	patch_amd64_ibm_jvm

}

src_compile() {

	# karltk: this should be handled by the java-pkg eclass in setup-vm 
	addwrite "/proc/self/maps"
	addwrite "/proc/cpuinfo"
	addwrite "/dev/random"

	# Figure out VM, set up ant classpath and native library paths
	setup-jvm-opts

	${use_gtk} && use mozilla && setup-mozilla-opts

	use jikes && bootstrap_ant_opts="-Dbuild.compiler=jikes"

	einfo "Bootstrapping bootstrap ecj"
	ant ${bootstrap_ant_opts} -q -f jdtcoresrc/compilejdtcorewithjavac.xml || die "Failed to bootstrap ecj"

	einfo "Bootstrapping ecj"
	ant -lib jdtcoresrc/ecj.jar -q -f jdtcoresrc/compilejdtcore.xml || die "Failed to bootstrap ecj"

	einfo "Compiling Eclipse -- see ${S}/compilelog.txt for details"
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

	einfo "Creating .desktop entry"
	create-desktop-entry
}

src_install() {

	eclipse_dir="/usr/lib/eclipse-${SLOT}"

	dodir /usr/lib

	einfo "Installing features and plugins"

	[ -f result/linux-gtk-${eclipsearch}-sdk.tar.gz ] || die "tar.gz bundle was not built properly!"
	tar zxf result/linux-gtk-${eclipsearch}-sdk.tar.gz -C ${D}/usr/lib || die "Failed to extract the built package"


	mv ${D}/usr/lib/eclipse ${D}/${eclipse_dir}

	insinto ${eclipse_dir}

	# Install launchers and native code
	exeinto ${eclipse_dir}

	einfo "Installing eclipse-gtk binary"
	doexe eclipse-gtk || die "Failed to install eclipse binary"

	if use nosrc ; then
		einfo "Stripping away source code"
		strip-src
	fi

	if use nodoc ; then
		einfo "Stripping away documentation"
		strip-docs
	fi

	# Install startup script
	exeinto /usr/bin
	doexe ${FILESDIR}/eclipse-${SLOT}

	install-desktop-entry

	doman ${FILESDIR}/eclipse.1

	install-link-files
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

function setup-mozilla-opts()
{
	mozilla_dir="--mozdir-unset---"

	# firefox support disabled for now
#	if [ -f ${ROOT}/usr/lib/MozillaFirefox/libgtkembedmoz.so ] ; then
#		einfo "Compiling against www-client/mozilla-firefox"
#		mozilla_dir=/usr/lib/MozillaFirefox
#	el
	if [ -f ${ROOT}/usr/lib/mozilla/libgtkembedmoz.so ] ; then
		einfo "Compiling against www-client/mozilla"
		mozilla_dir=/usr/lib/mozilla
	else
		eerror "You have enabled the embedded mozilla component, but no suitable"
		eerror "provider was found. You need Mozilla or Firefox compiled against"
		eerror "gtk+ v2.0 or newer."
		eerror "To merge it, execute 'USE=\"gtk2\" emerge mozilla' as root."
		eerror "To disable embedded mozilla, remove \"mozilla\" from your USE flags."
		die "Need Mozilla compiled with gtk+-2.x support"
	fi

	export GECKO_SDK="${mozilla_dir}"
	export GECKO_INCLUDES="-include ${GECKO_SDK}/include/mozilla-config.h \
		-I${GECKO_SDK}/include/nspr \
		-I${GECKO_SDK}/include/nspr \
		-I${GECKO_SDK}/include/xpcom \
		-I${GECKO_SDK}/include/string \
		-I${GECKO_SDK}/include/embed_base \
		-I${JAVA_HOME}/include/linux"
	export GECKO_LIBS="-L${GECKO_SDK} -lgtkembedmoz"
}

function build-native() {
	sh features/org.eclipse.platform.launchers/library/gtk/build.sh \
		-os linux -ws gtk \
		-arch ${eclipsearch} || die "Failed to build launcher"
}

function process-makefiles() {

	# Comment out hard-coded JAVA_HOME
	sed -i 's/^JAVA_HOME/#JAVA_HOME/' plugins/org.eclipse.core.resources.linux/src/Makefile || die "Failed to patch Makefile"

	# Select the set of native libraries to compile
	local libs="make_swt make_awt make_atk"

	if use gnome ; then
		einfo "Building GNOME VFS support"
		libs="${libs} make_gnome"
	fi

	if use mozilla ; then
		einfo "Building Mozilla embed support"
		libs="${libs} make_mozilla"
	fi

	if use atk ; then
		einfo "Building ATK support"
		libs="${libs} make_atk"
	fi

	sed -i "s/^all:.*/all: ${libs}/" "plugins/org.eclipse.swt/Eclipse SWT PI/gtk/library/make_linux.mak" || die "Failed to patch make_linux.mak"
}

function create-desktop-entry() {

	cat ${FILESDIR}/eclipse-${SLOT}.desktop | \
		sed -e "s/@PV@/${PV}/" \
		> eclipse-${SLOT}.desktop || die "Failed to create desktop entry"
}

function install-desktop-entry() {

	dodir /usr/share/applications
	insinto /usr/share/applications
	doins eclipse-${SLOT}.desktop
}

function clean-prebuilt-code() {

	find ${S} -type f \( -name '*.class' -o -name '*.so' -o -name '*.so.*' -o -name 'eclipse' \) | xargs rm -f
}

function get-memory-total() {
	cat /proc/meminfo | grep MemTotal | sed -r "s/[^0-9]*([0-9]+).*/\1/"
}

function check-ram() {

	local mem=$(get-memory-total)
	[ $(get-memory-total) -lt 775000 ] &&
		(
		echo
		ewarn "To build Eclipse, at least 768MB of RAM is recommended."
		ewarn "Your machine has less RAM. Continuing anyway. If the build"
		ewarn "stops with an error about invalid memory, increase your swap."
		echo
		)
}

function install-link-files() {

	einfo "Installing link files"

	dodir /usr/lib/eclipse-${SLOT}/links

	echo "path=/opt/eclipse-extensions-3" > ${D}/${eclipse_dir}/links/eclipse-binary-extensions-3.link
	echo "path=/opt/eclipse-extensions-3.1" > ${D}/${eclipse_dir}/links/eclipse-binary-extensions-3.1.link

	echo "path=/usr/lib/eclipse-extensions-3" > ${D}/${eclipse_dir}/links/eclipse-extensions-3.link
	echo "path=/usr/lib/eclipse-extensions-3.1" > ${D}/${eclipse_dir}/links/eclipse-extensions-3.1.link
}

function patch_amd64_ibm_jvm() {
	# the ibm jdk ebuild should have fixed headers, but until then
	# we just fix the compiling here (see bug #97421)
	if [ ${ARCH} == 'amd64' ]; then
	    if [ ! -z "`java-config --java-version | grep IBM`" ] ; then
		einfo "Fixing IBM jdk header problem"
		find plugins -name "make_linux.mak" -print0 | xargs -0 sed -i -e 's/^CFLAGS =/CFLAGS = -D_JNI_IMPORT_OR_EXPORT_= /'
	    fi
	fi
}

function setup-jvm-opts() {

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

function strip-src() {

	local bp=${D}/${eclipse_dir}

	rm -rf ${bp}/plugins/org.eclipse.pde.source_3*
	rm -rf ${bp}/plugins/org.eclipse.jdt.source_3*
	rm -rf ${bp}/plugins/org.eclipse.platform.source.linux.*
	rm -rf ${bp}/plugins/org.eclipse.platform.source_3*

	rm -rf ${bp}/features/org.eclipse.jdt.source_3*/
	rm -rf ${bp}/features/org.eclipse.pde.source_3*/
	rm -rf ${bp}/features/org.eclipse.platform.source_3*/
}

function strip-docs() {
	local bp=${D}/${eclipse_dir}

	rm -rf ${bp}/plugins/org.eclipse.platform.doc.*
	rm -rf ${bp}/plugins/org.eclipse.jdt.doc.*
	rm -rf ${bp}/plugins/org.eclipse.pde.doc.*
}

function check-cflags() {

	einfo "Checking for bad CFLAGS"

	local badflags="-fomit-frame-pointer -msse2"
	local error=false

	for x in ${badflags} ; do
		if [ ! -z "$(echo ${CFLAGS} | grep -- $x)" ] ; then
			ewarn "Found offending option $x in your CFLAGS"
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

