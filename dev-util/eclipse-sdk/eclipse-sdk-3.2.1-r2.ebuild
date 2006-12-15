# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# THIS EBUILD IS THE PORTING ON GENTOO OF THE FEDORA BUILD FILE
# A HUGE "THANK YOU" TO THE FEDORA GUYS FOR THEIR EFFORT
#
# IF YOU WANT TO MAINTAIN THIS EBUILD, PLEASE CHECK "eclipse.spec" FILE AT
# http://cvs.fedora.redhat.com/viewcvs/devel/eclipse/
# (USE %patch COMMAND AS A REFERENCE TO THEIR ORIGINAL BUILD FILE)

inherit java-pkg-2 check-reqs

DATESTAMP="200609210945"
MY_A="eclipse-sourceBuild-srcIncluded-${PV}.zip"

DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/R-${PV}-${DATESTAMP}/${MY_A}
	http://www.fridrik.it/files/${PF}-patches.tar.bz2"
IUSE="branding cairo gnome opengl seamonkey tomcat"
SLOT="3.2"
LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~ppc ~x86"

S=${WORKDIR}

COMMON_DEP="
	>=dev-java/ant-1.6.5
	tomcat? (
		dev-java/commons-digester-rss
		=dev-java/mx4j-2.1*
		=dev-java/jakarta-regexp-1.3*
		>=www-servers/tomcat-5.5.17
	)
	=dev-java/lucene-1*
	=dev-java/junit-3*
	=dev-java/junit-4*
	dev-java/jsch
	>=x11-libs/gtk+-2.6
	cairo? ( >=x11-libs/cairo-1.0 )
	seamonkey? ( www-client/seamonkey )
	gnome? 	(
		=gnome-base/gnome-vfs-2*
		=gnome-base/libgnomeui-2*
	)
	opengl? ( virtual/opengl )
	=dev-java/eclipse-ecj-3.2*"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND="${COMMON_DEP}
	=virtual/jdk-1.4*
	>=virtual/jdk-1.5
	>=sys-apps/findutils-4.1.7
	app-arch/unzip
	app-arch/zip"
#	app-text/dos2unix" See comment some hundreds lines below

# Force 1.4 to be used for building
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4*"

# Force compiling with ecj
JAVA_PKG_FORCE_COMPILER="ecj-3.2"

ECLIPSE_DIR="/usr/lib/eclipse-${SLOT}"

# TODO:
# - keyword ppc64 and ia64
# - ppc support not tested, but not explicitly broken either
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
}

src_unpack() {
	unpack ${A}

	patch-apply-all

	# no warnings
	find ${S} -type f -name '*.xml' -exec 				\
		sed -r -e "s/(\"compilerArg\" value=\")/\1-nowarn /g" 	\
		-e "s/(-encoding ISO-8859-1)/\1 -nowarn/g" -i {} \;
}

src_compile() {
	# Figure out correct boot classpath
	# karltk: this should be handled by the java-pkg eclass in setup-vm
	local bootclasspath=$(java-config --runtime)

	# Correct awt .so path for ibm jdk
	if [[ $(java-pkg_get-vm-vendor) == "ibm" ]] ; then
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/bin"
	else
		# Sun derived JDKs (Blackdown, Sun)
		JAVA_LIB_DIR="$(java-config --jdk-home)/jre/lib/${jvmarch}"
	fi

	if [[ ! -f ${JAVA_LIB_DIR}/libawt.so ]] ; then
		die "Could not find libawt.so native library"
	fi

	export AWT_LIB_PATH=${JAVA_LIB_DIR}

	einfo "Using bootclasspath ${bootclasspath}"
	einfo "Using JVM library path ${JAVA_LIB_DIR}"

	if use seamonkey ; then
		einfo "Will compile embedded seamonkey support against www-client/seamonkey"

		setup-mozilla-opts
	else
		einfo "Not building embedded seamonkey support"
	fi

	local java5vm=$(depend-java-query --get-vm ">=virtual/jdk-1.5")
	local java5home=$(GENTOO_VM=${java5vm} java-config --jdk-home)

	einfo "Using ${java5home} for java5home"

	ANT_OPTS=-Xmx1024M \
		eant \
		-Dnobootstrap=true \
		-DinstallOs=linux -DinstallWs=gtk -DinstallArch=${eclipsearch} \
		-Dlibsconfig=true \
		-Dbootclasspath=${bootclasspath} \
		-Djava5.home=${java5home}
}

src_install() {
	dodir /usr/lib

	[[ -f result/linux-gtk-${eclipsearch}-sdk.tar.gz ]] \
		|| die "tar.gz bundle was not built properly!"
	tar zxf result/linux-gtk-${eclipsearch}-sdk.tar.gz -C ${D}/usr/lib \
		|| die "Failed to extract the built package"

	mv ${D}/usr/lib/eclipse ${D}/${ECLIPSE_DIR}

	debug-print "Installing eclipse-gtk binary"
	exeinto ${ECLIPSE_DIR}
	doexe eclipse || die "Failed to install eclipse binary"

	# Install startup script
	exeinto /usr/bin
	doexe ${FILESDIR}/eclipse-${SLOT}

	make_desktop_entry eclipse-${SLOT} "Eclipse ${PV}" "${ECLIPSE_DIR}/icon.xpm"

	cd ${D}/${ECLIPSE_DIR}

	install-link-system-jars
}

pkg_postinst() {
	einfo
	einfo "Users can now install plugins via Update Manager without any"
	einfo "tweaking."
	einfo
	einfo "Eclipse plugin packages (ie eclipse-cdt) will likely go away in"
	einfo "the near future until they can be properly packaged. Update Manager"
	einfo "is prefered in the meantime."
	einfo
	einfo "If you plan to use heavy plugins, mind to read"
	einfo "file://${ECLIPSE_DIR}/readme/readme_eclipse.html#Running%20Eclipse"
	einfo "about memory issues"
	einfo "(and to eventually modify ${ECLIPSE_DIR}/eclipse.ini)"
	einfo
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

setup-mozilla-opts() {
	export GECKO_SDK="/usr/$(get_libdir)/seamonkey"
	# TODO should this be using pkg-config?
	export GECKO_INCLUDES=$(pkg-config seamonkey-gtkmozembed --cflags)
	export GECKO_LIBS=$(pkg-config seamonkey-gtkmozembed --libs)
}

install-link-system-jars() {
	## BEGIN ANT ##
	pushd plugins/org.apache.ant_*/lib/ > /dev/null || die "pushd failed"
	rm *.jar
	java-pkg_jarfrom ant-core
	java-pkg_jarfrom ant-tasks
	popd > /dev/null
	## END ANT ##

	## BEGIN LUCENE ##
	pushd plugins/org.apache.lucene_*/ > /dev/null || die "pushd failed"
	rm lucene-1.4.3.jar
	java-pkg_jar-from lucene-1 lucene.jar lucene-1.4.3.jar
	popd > /dev/null
	## END LUCENE ##

	pushd plugins/org.junit4_*/ >/dev/null
	rm junit-4.1.jar
	java-pkg_jar-from junit-4 junit.jar junit-4.1.jar
	popd >/dev/null

	if use tomcat; then
		## BEGIN TOMCAT ##
		pushd plugins/org.eclipse.tomcat_* > /dev/null || die "pushd failed"
		mkdir lib
		pushd lib > /dev/null || die "pushd failed"
		java-pkg_jarfrom tomcat-5.5
		java-pkg_jarfrom mx4j-2.1
		java-pkg_jarfrom commons-beanutils-1.7
		java-pkg_jarfrom commons-collections
		java-pkg_jarfrom commons-dbcp
		java-pkg_jarfrom commons-digester
		java-pkg_jarfrom commons-digester-rss
		java-pkg_jarfrom commons-el
		java-pkg_jarfrom commons-fileupload
		java-pkg_jarfrom commons-launcher
		java-pkg_jarfrom commons-logging
		java-pkg_jarfrom commons-modeler
		java-pkg_jarfrom commons-pool
		java-pkg_jarfrom servletapi-2.4 servlet-api.jar servletapi5.jar
		java-pkg_jarfrom servletapi-2.4 jsp-api.jar jspapi.jar
		java-pkg_jarfrom jakarta-regexp-1.3
		ln -s /usr/share/tomcat-5.5/bin/bootstrap.jar bootstrap.jar
		popd > /dev/null
		popd > /dev/null
		## END TOMCAT ##
	fi
}

patch-local-cflags() {
	pushd plugins/org.eclipse.swt/Eclipse\ SWT\ PI/gtk/library >/dev/null || die "pushd failed"
	# %patch0 -p0
	# we prefer to sed the make_linux.mak file instead of applying a patch.
	# this improves maintainability and allows to inject our own CFLAGS

	sed -i "s/CFLAGS\ =\ -O\ -Wall/CFLAGS = ${CFLAGS}\ -Wall/" \
		make_linux.mak \
		|| die "Failed to tweak make_linux.mak"

	sed -i "s/MOZILLACFLAGS\ =\ -O/MOZILLACFLAGS = ${CXXFLAGS}/" \
		make_linux.mak \
		|| die "Failed to tweak make_linux.mak"

	# Select the set of native libraries to compile
	local targets="make_swt make_awt make_atk"

	if use gnome ; then
		einfo "Enabling GNOME VFS support"
		targets="${targets} make_gnome"
	fi

	if use seamonkey ; then
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

	sed -i "s/^all:.*/all: ${targets}/" make_linux.mak \
		|| die "Failed to tweak make_linux.mak"

	popd > /dev/null
}

patch-jni-libs() {
	# %patch2 -p0
	epatch ${WORKDIR}/${P}-build.gentoo.patch
	# %patch4 -p0
	epatch ${WORKDIR}/${P}-libupdatebuild.patch
	# %patch5 -p0
	epatch ${WORKDIR}/${P}-libupdatebuild2.patch

	# Build swttools.jar
	pushd plugins/org.eclipse.swt.gtk.linux.x86_64 >/dev/null || die "pushd failed"
	# %patch18 -p0
	epatch ${WORKDIR}/${P}-swttools.patch
	popd >/dev/null

	# %patch22 -p0
	epatch ${WORKDIR}/${P}-updatehomedir.patch
	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=90535

	# fridrik: fedora does not apply this anymore because they chekout
	# org.eclipse.equinox.initializer project from cvs. 'till a fix, we'll
	# keep the old patch
	pushd plugins/org.eclipse.core.runtime >/dev/null || die "pushd failed"
	# %patch24 -p0
	epatch ${WORKDIR}/${P}-fileinitializer.patch
	popd >/dev/null
}

patch-tomcat() {
	pushd plugins/org.eclipse.tomcat >/dev/null || die "pushd failed"
	# %patch28 -p0
	epatch ${WORKDIR}/${P}-tomcat55.patch
	# %patch29 -p0
	epatch ${WORKDIR}/${P}-tomcat55-build.patch
	popd >/dev/null

	sed --in-place "s/4.1.130/5.5.17/"                      \
			features/org.eclipse.platform/build.xml \
			plugins/org.eclipse.tomcat/build.xml    \
			assemble.*.xml

	pushd plugins/org.eclipse.help.webapp >/dev/null || die "pushd failed"
	# %patch31 -p0
	epatch ${WORKDIR}/${P}-webapp-tomcat55.patch
	popd >/dev/null
}

patch-launcher() {
	# Because the launcher source is zipped up, we need to unzip, patch, and re-pack
	mkdir launchertmp
	unzip -qq -d launchertmp plugins/org.eclipse.platform/launchersrc.zip >/dev/null || die "unzip failed"
	pushd launchertmp >/dev/null || die "pushd failed"
	# %patch47 -p1
	epatch ${WORKDIR}/${P}-launcher-link.patch
	zip -q -9 -r ../launchersrc.zip * >/dev/null || die "zip failed"
	popd >/dev/null
	mv launchersrc.zip plugins/org.eclipse.platform
	rm -rf launchertmp
}

patch-branding() {
	if use branding; then
		pushd plugins/org.eclipse.platform >/dev/null || die "pushd failed"
		cp ${WORKDIR}/splash.bmp .
		popd >/dev/null
	fi
}

patch-symlink-ant() {
	pushd plugins/org.apache.ant/lib/ > /dev/null || die "pushd failed"

	rm *.jar *src.zip

	java-pkg_jarfrom ant-core
	java-pkg_jarfrom ant-tasks

	popd > /dev/null
}

patch-symlink-tomcat() {
	pushd plugins/org.eclipse.tomcat/ > /dev/null || die "pushd failed"

	rm *.jar

	mkdir lib
	pushd lib/ > /dev/null || die "pushd failed"

	java-pkg_jarfrom tomcat-5.5
	java-pkg_jarfrom mx4j-2.1
	java-pkg_jarfrom commons-beanutils-1.7
	java-pkg_jarfrom commons-collections
	java-pkg_jarfrom commons-dbcp
	java-pkg_jarfrom commons-digester
	java-pkg_jarfrom commons-digester-rss
	java-pkg_jarfrom commons-el
	java-pkg_jarfrom commons-fileupload
	java-pkg_jarfrom commons-launcher
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom commons-modeler
	java-pkg_jarfrom commons-pool
	java-pkg_jarfrom servletapi-2.4 servlet-api.jar servletapi5.jar
	java-pkg_jarfrom servletapi-2.4 jsp-api.jar jspapi.jar
	java-pkg_jarfrom jakarta-regexp-1.3
	ln -s /usr/share/tomcat-5.5/bin/bootstrap.jar bootstrap.jar

	popd > /dev/null
	popd > /dev/null
}

patch-symlink-lucene() {
	pushd plugins/org.apache.lucene/ > /dev/null || die "pushd failed"

	rm *.jar *src.zip

	java-pkg_jar-from lucene-1 lucene.jar lucene-1.4.3.jar

	popd > /dev/null
}

patch-symlink-junit() {
	pushd plugins/org.junit4 > /dev/null || die "pushd failed"

	rm junit-4.1.jar
	java-pkg_jar-from junit-4 junit.jar junit-4.1.jar

	popd > /dev/null

	pushd plugins/org.junit > /dev/null || die "pushd failed"

	rm junit.jar
	java-pkg_jarfrom junit

	popd > /dev/null
}

patch-symlink-jsch() {
	pushd plugins/org.eclipse.team.cvs.ssh2/ > /dev/null || die "pushd failed"

	rm com.jcraft.jsch_*.jar
	java-pkg_jarfrom jsch

	popd > /dev/null
}

patch-apply-all() {
	patch-local-cflags

	patch-jni-libs

	use tomcat && patch-tomcat

	# pushd plugins/org.eclipse.compare
	# COMMENTED BY FEDORA %patch33 -p0
	# popd

	pushd plugins/org.eclipse.jdt.core >/dev/null || die "pushd failed"
	# %patch34 -p0
	epatch ${WORKDIR}/${P}-bz162177.patch
	# epatch ${WORKDIR}/${P}-ecj-square-bracket-classpath.patch
	# Use ecj for gcj
	# %patch57 -p0
	epatch ${WORKDIR}/${P}-ecj-gcj.patch
	popd >/dev/null

	# %patch38 -p0
	epatch ${WORKDIR}/${P}-helpindexbuilder.patch
	# %patch40 -p0
	epatch ${WORKDIR}/${P}-usebuiltlauncher.patch
	# COMMENTED BY FEDORA %patch43
	pushd plugins/org.eclipse.swt/Eclipse\ SWT\ Mozilla/common/library >/dev/null || die "pushd failed"
	# Build cairo native libs
	# %patch46
	epatch ${WORKDIR}/${P}-libswt-xpcomgcc4.patch
	popd >/dev/null

	patch-launcher

	pushd features/org.eclipse.platform.launchers >/dev/null || die "pushd failed"
	# %patch47 -p1
	epatch ${WORKDIR}/${P}-launcher-link.patch
	# epatch ${WORKDIR}/${P}-launcher-set-install-dir-and-shared-config.patch
	popd >/dev/null

	# %patch48 -p0
	epatch ${WORKDIR}/${P}-javadoclinks.gentoo.patch

	# %patch49 -p0
	epatch ${WORKDIR}/${P}-ecj-rpmdebuginfo.patch

	# generic releng plugins that can be used to build plugins
	# see this thread for deails:
	# https://www.redhat.com/archives/fedora-devel-java-list/2006-April/msg00048.html
	pushd plugins/org.eclipse.pde.build >/dev/null || die "pushd failed"
	# %patch53
	epatch ${WORKDIR}/${P}-pde.build-add-package-build.patch
	sed --in-place "s:@eclipse_base@:${S}:" templates/package-build/build.properties
	popd >/dev/null

	pushd plugins/org.eclipse.swt/Eclipse\ SWT >/dev/null || die "pushd failed"
	# %patch54
	epatch ${WORKDIR}/${P}-swt-rm-ON_TOP.patch
	popd >/dev/null

	pushd plugins/org.eclipse.swt >/dev/null || die "pushd failed"
	mv "Eclipse SWT Mozilla" Eclipse_SWT_Mozilla
	mv "Eclipse SWT PI" Eclipse_SWT_PI
	# Build against firefox:
	#  - fix swt profile include path
	#  - don't compile the mozilla 1.7 / firefox profile library -- build it inline
	#  - don't use symbols not in our firefox builds
	# FIXME:  add reference(s) to discussion(s) and bug(s)
	# Note:  I made this patch from within Eclipse and then did the following to
	#        it due to spaces in the paths:
	#  sed --in-place "s/Eclipse\ SWT\ Mozilla/Eclipse_SWT_Mozilla/g" eclipse-swt-firefox.patch
	#  sed --in-place "s/Eclipse\ SWT\ PI/Eclipse_SWT_PI/g" eclipse-swt-firefox.patch
	# %patch59
	epatch ${WORKDIR}/${P}-swt-firefox.patch
	mv Eclipse_SWT_Mozilla "Eclipse SWT Mozilla"
	mv Eclipse_SWT_PI "Eclipse SWT PI"
	popd >/dev/null

	pushd plugins/org.eclipse.swt.tools >/dev/null || die "pushd failed"
	mv "JNI Generation" JNI_Generation
	# %patch60
	epatch ${WORKDIR}/${P}-swt-firefox.2.patch
	mv JNI_Generation "JNI Generation"
	popd >/dev/null

	# FIXME check if this has been applied upstream
	pushd plugins/org.eclipse.platform.doc.isv >/dev/null || die "pushd failed"
	# %patch100 -p0
	epatch ${WORKDIR}/customBuildCallbacks.xml-add-pre.gather.bin.parts.patch
	popd >/dev/null

	pushd plugins/org.eclipse.platform.doc.user >/dev/null || die "pushd failed"
	# %patch100 -p0
	epatch ${WORKDIR}/customBuildCallbacks.xml-add-pre.gather.bin.parts.patch
	popd >/dev/null

	patch-branding

	# FIXME this should be patched upstream with a flag to turn on and off
	# all output should be directed to stdout
	find -type f -name \*.xml -exec sed --in-place -r "s/output=\".*(txt|log).*\"//g" "{}" \;

	# Remove existing .sos
	find -name \*.so | xargs rm

	# fridrik: updates path to jdk
	sed --in-place "s:JAVA_HOME = ~/vm/sun142:JAVA_HOME=$(java-config-1 -O):" \
		plugins/org.eclipse.core.filesystem/natives/unix/linux/Makefile \
		|| die "Failed to sed Makefile"

	ebegin "Symlinking system jars"
		patch-symlink-ant
		use tomcat && patch-symlink-tomcat
		patch-symlink-lucene
		patch-symlink-junit
		patch-symlink-jsch
	eend $?

	# FIXME: figure out what's going on with build.index on ppc64, s390x and i386   
	if [ ${ARCH} == "ppc64" ] || [ ${ARCH} == "s390" ] || [ ${ARCH} == "x86" ] || [ ${ARCH} == "ia64" ] ; then
		find plugins -type f -name \*.xml -exec sed --in-place "s/\(<antcall target=\"build.index\".*\/>\)/<\!-- \1 -->/" "{}" \;
	fi

	# the swt version is set to HEAD on ia64 but shouldn't be
	# FIXME: file a bug about this
	# get swt version
	SWT_MAJ_VER=$(grep maj_ver plugins/org.eclipse.swt/Eclipse\ SWT/common/library/make_common.mak | cut -f 2 -d =)
	SWT_MIN_VER=$(grep min_ver plugins/org.eclipse.swt/Eclipse\ SWT/common/library/make_common.mak | cut -f 2 -d =)
	SWT_VERSION=$SWT_MAJ_VER$SWT_MIN_VER
	swt_frag_ver=$(grep v$SWT_VERSION plugins/org.eclipse.swt.gtk.linux.x86/build.xml | sed "s:.*<.*\"\(.*\)\"/>:\1:")
	swt_frag_ver_ia64=$(grep "version\.suffix\" value=" plugins/org.eclipse.swt.gtk.linux.ia64/build.xml | sed "s:.*<.*\"\(.*\)\"/>:\1:")
	sed --in-place "s/$swt_frag_ver_ia64/$swt_frag_ver/g"    \
		plugins/org.eclipse.swt.gtk.linux.ia64/build.xml \
		assemble.org.eclipse.sdk.linux.gtk.ia64.xml      \
		features/org.eclipse.rcp/build.xml

	# nasty hack to get suppport for ppc64, s390(x) and sparc(64)
	# move all of the ia64 directories to ppc64 or s390(x) or sparc(64) dirs and replace 
	# the ia64 strings with ppc64 or s390(x)
	if [ ${ARCH} == "ppc64" ] || [ ${ARCH} == "s390" ] || [ ${ARCH} == "sparc" ] ; then
		# there is only partial support for ppc64 in 3.2 so we have to remove this 
		# partial support to get the replacemnt hack to work
		find -name \*ppc64\* | xargs rm -r

		# remove remove ppc64 support from features/org.eclipse.platform.source/feature.xml
		# replace ppc64 with a fake arch (ppc128) so we don't have duplicate ant targets
		find -type f -name \*.xml -exec sed --in-place "s/\(rootFileslinux_gtk_\)ppc64/\1ppc128/g" "{}" \;
		# remove org.eclipse.platform.source.linux.gtk.ppc64,3.2.0.v20060602-0010-gszCh-8eOaU1uKq
		sed --in-place "s/,.\{38\}ppc64.*macosx/,org.eclipse.platform.source.macosx/g" features/org.eclipse.platform.source/build.xml
		# replace final occurances with an existing arch
		sed --in-place "s/ppc64/x86_64/g" features/org.eclipse.platform.source/build.xml

		# remove remove ppc64 support from features/org.eclipse.platform.source/feature.xml
		mv features/org.eclipse.platform.source/feature.xml features/org.eclipse.platform.source/feature.xml.orig
		grep -v ppc64 features/org.eclipse.platform.source/feature.xml.orig > features/org.eclipse.platform.source/feature.xml

		# finally the replacement hack
		for f in $(find -name \*ia64\* | grep -v motif | grep -v ia64_32); do
		mv $f $(echo $f | sed "s/ia64/${ARCH}/")
		done
		find -type f -exec sed --in-place "s/ia64_32/@eye-eh-64_32@/g" "{}" \;
		find -type f -exec sed --in-place "s/ia64/${ARCH}/g" "{}" \;
		find -type f -exec sed --in-place "s/@eye-eh-64_32@/ia64_32/g" "{}" \;
	fi

	# delete included jars
	# FIXME: file a bug about these
	rm plugins/org.eclipse.swt.win32.win32.x86/swt.jar \
		plugins/org.eclipse.swt/extra_jars/exceptions.jar \
		plugins/org.eclipse.swt.tools/swttools.jar \
		features/org.eclipse.platform.launchers/bin/startup.jar
}
