# Copyright 2007-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/eclipse-sdk/eclipse-sdk-3.3.1.1.ebuild,v 1.1 2008/01/21 12:15:55 elvanor Exp $

# Notes: This is a preliminary ebuild of Eclipse-3.3
# It was based on the initial ebuild in the gcj-overlay, so much of the credit goes out to geki.

# Tomcat is almost no longer needed in 3.3 and removed in 3.4.
# See bug: https://bugs.eclipse.org/bugs/show_bug.cgi?id=173692
# Currently we remove the Tomcat stuff entirely - potentially this can still break things.
# We'll put it back if there is any bug report, which is unlikely.

# To unbundle a jar, do the following:
# 1) Rewrite the ebuild so it uses OSGi packaging
# 2) Add the dependency and add it to gentoo_jars/system_jars
# 3) Remove it from the build directory, and don't forget to modify the main Ant file
# so that it does *NOT* copy the file at the end
# 4) Install the symlink itself via java-pkg_jarfrom

# Jetty, Tomcat-jasper and Lucene analysis (1.9.1) jars have to stay bundled for now, until someone does some work on them.
# Hopefully, wltjr will soon package tomcat-jasper.

# Current patches are hard to maintain when revbumping.
# Two solutions:
# 1) Split patches so that there is one per file
# 2) Use sed, better solution I would say.

EAPI="1"
JAVA_PKG_IUSE="doc"
inherit java-pkg-2 java-ant-2 check-reqs

MY_PV="${PV/_rc/RC}"
DMF="S-${MY_PV}-200806091311"
MY_A="eclipse-sourceBuild-srcIncluded-${MY_PV}.zip"

DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_A}"

SLOT="3.4"
LICENSE="EPL-1.0"
IUSE="java6"
KEYWORDS="~amd64 ~ppc ~x86"

S=${WORKDIR}
PATCHDIR="${FILESDIR}/${SLOT}"
FEDORA="${PATCHDIR}/fedora"
ECLIPSE_DIR="/usr/lib/eclipse-${SLOT}"

CDEPEND="dev-java/ant-eclipse-ecj:${SLOT}
	dev-java/ant-core
	dev-java/junit:0
	dev-java/junit:4
	dev-java/swt:${SLOT}
	>=dev-java/jsch-0.1.36-r1
	>=dev-java/icu4j-3.8.1
	>=dev-java/commons-el-1.0-r2
	>=dev-java/commons-logging-1.1-r6
	>=dev-java/tomcat-servlet-api-5.5.25-r1:2.4
	dev-java/lucene:1.9
	dev-java/lucene-analyzers:1.9"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
	java6? ( >=virtual/jdk-1.6 )
	dev-java/ant-nodeps
	dev-java/cldc-api:1.1
	sys-apps/findutils
	app-arch/unzip
	app-arch/zip
	${CDEPEND}"

JAVA_PKG_BSFIX="off"

pkg_setup() {
	java-pkg-2_pkg_setup

	CHECKREQS_MEMORY="512"
	check_reqs

	eclipsearch=${ARCH}
	use amd64 && eclipsearch="x86_64"
}

src_unpack() {
	unpack ${A}
	patch-apply
	remove-bundled-stuff

	# no warnings / java5 / all output should be directed to stdout
	find ${S} -type f -name '*.xml' -exec \
		sed -r -e "s:(-encoding ISO-8859-1):\1 -nowarn:g" -e "s:(\"compilerArg\" value=\"):\1-nowarn :g" \
		-e "s:(<property name=\"javacSource\" value=)\".*\":\1\"1.5\":g" \
		-e "s:(<property name=\"javacTarget\" value=)\".*\":\1\"1.5\":g" -e "s:output=\".*(txt|log).*\"::g" -i {} \;

	# jdk home
	sed -r -e "s:^(JAVA_HOME =) .*:\1 $(java-config --jdk-home):" -e "s:gcc :gcc ${CFLAGS} :" \
		-i plugins/org.eclipse.core.filesystem/natives/unix/linux/Makefile || die "sed Makefile failed"

	while read line; do
		java-ant_rewrite-classpath "$line" > /dev/null
	done < <(find ${S} -type f -name "build.xml")
}

src_compile() {
	# Figure out correct boot classpath
	local bootclasspath=$(java-config --runtime)
	einfo "Using boot classpath ${bootclasspath}"

	java-pkg_force-compiler ecj-${SLOT}

	# system_jars will be used when compiling (javac)
	# gentoo_jars will be used when building JSPs and other ant tasks (not javac)
	local system_jars="$(java-pkg_getjars swt-${SLOT},icu4j,ant-core,jsch,junit-4,tomcat-servlet-api-2.4,lucene-1.9,lucene-analyzers-1.9):$(java-pkg_getjars --build-only ant-nodeps,cldc-api-1.1)"
	local gentoo_jars="$(java-pkg_getjars ant-core,icu4j,jsch,commons-logging,commons-el,tomcat-servlet-api-2.4)"
	local options="-q -Dnobootstrap=true -Dlibsconfig=true -Dbootclasspath=${bootclasspath} -DinstallOs=linux \
		-DinstallWs=gtk -DinstallArch=${eclipsearch} -Djava5.home=$(java-config --jdk-home)"
	use java6 && options="${options} -DJavaSE-1.6=${bootclasspath}"
	use doc && options="${options} -Dgentoo.javadoc=true"

	ANT_OPTS=-Xmx512M ANT_TASKS="ant-nodeps" \
		eant ${options} -Dgentoo.classpath="${system_jars}" -Dgentoo.jars="${gentoo_jars//:/,}"
}

src_install() {
	dodir /usr/lib

	[ -f result/linux-gtk-${eclipsearch}-sdk.tar.gz ] \
		|| die "tar.gz bundle was not built properly!"
	tar xzf result/linux-gtk-${eclipsearch}-sdk.tar.gz -C ${D}/usr/lib \
		|| die "Failed to extract the built package"

	mv ${D}/usr/lib/eclipse ${D}/${ECLIPSE_DIR}

	# install startup script
	dobin ${FILESDIR}/eclipse-${SLOT}
	chmod +x ${D}/${ECLIPSE_DIR}/eclipse

	insinto /etc
	doins ${FILESDIR}/${SLOT}/eclipserc

	make_desktop_entry eclipse-${SLOT} "Eclipse ${PV}" "${ECLIPSE_DIR}/icon.xpm"

	cd ${D}/${ECLIPSE_DIR}
	install-link-system-jars
}

pkg_postinst() {
	einfo
	einfo "Welcome to Eclipse ${PV} (Ganymede)!"
	einfo
	einfo "You can now install plugins via Update Manager without any"
	einfo "tweaking. This is the recommended way to install new features for Eclipse."
	einfo
	einfo "Please read http://gentoo-wiki.com/Eclipse"
	einfo "It contains a lot of useful information and help about Eclipse on Gentoo."
	einfo
	einfo "The FileInitializer Plugin is no more integrated."
	einfo "If you need it, get org.eclipse.equinox.initializer_x.y.z.jar from:"
	einfo "	http://download.eclipse.org/eclipse/equinox/"
	ewarn
	ewarn "UPGRADE WARNING"
	ewarn "You may do a backup of your ~/.eclipse and ~/workspace folders."
	ewarn "Otherwise configuration changes may confuse older Eclipse versions."
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

install-link-system-jars() {
	pushd plugins/ > /dev/null
	local ant_dir="$(basename plugins/org.apache.ant_*)"
	rm -rf plugins/org.apache.ant_*
	dosym /usr/share/ant-core ${ECLIPSE_DIR}/plugins/${ant_dir}

	java-pkg_jarfrom swt-${SLOT}
	java-pkg_jarfrom icu4j
	java-pkg_jarfrom jsch
	java-pkg_jarfrom commons-el
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom lucene-1.9
	java-pkg_jarfrom lucene-analyzers-1.9
	java-pkg_jarfrom tomcat-servlet-api-2.4

	popd > /dev/null

	pushd plugins/org.junit_*/ > /dev/null
	java-pkg_jarfrom junit
	popd > /dev/null

	pushd plugins/org.junit4*/ > /dev/null
	java-pkg_jarfrom junit-4
	popd > /dev/null
}

patch-apply() {
	# optimize launcher build
	mkdir launchertmp
	unzip -qq -d launchertmp plugins/org.eclipse.platform/launchersrc.zip > /dev/null || die "unzip failed"
	pushd launchertmp/ > /dev/null
	sed -r -e "s/CFLAGS = -O -s -Wall/CFLAGS = ${CFLAGS} -Wall/" \
		-i library/gtk/make_linux.mak || die "Failed to tweak make_linux.mak"
	zip -q -6 -r ../launchersrc.zip * >/dev/null || die "zip failed"
	popd > /dev/null
	mv launchersrc.zip plugins/org.eclipse.platform/launchersrc.zip
	rm -rf launchertmp

	# disable swt, jdk6
	# use sed where possible -> ease revbump :)
	sed -e "/..\/..\/plugins\/org.eclipse.ui.win32/,/<\/ant>/d" \
		-i features/org.eclipse.platform/build.xml
	sed -e "/dir=\"..\/..\/plugins\/org.eclipse.swt/,/<\/ant>/d" \
		-i features/org.eclipse.rcp/build.xml \
		-i features/org.eclipse.rcp.source/build.xml
	sed -e "/dir=\"..\/..\/plugins\/org.eclipse.ui.carbon\"/,/<\/ant>/d" \
		-i features/org.eclipse.rcp/build.xml

	sed -e "/dir=\"plugins\/org.eclipse.swt.gtk.linux.${eclipsearch}/d" \
		-e "/value=\"org.eclipse.swt.gtk.linux.${eclipsearch}/,/eclipse.plugins/d" \
		-i assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml

	if ! use java6; then
		sed -e "/..\/..\/plugins\/org.eclipse.jdt.apt.pluggable.core/,/<\/ant>/d" \
			-e "/..\/..\/plugins\/org.eclipse.jdt.compiler.apt/,/<\/ant>/d" \
			-e "/..\/..\/plugins\/org.eclipse.jdt.compiler.tool/,/<\/ant>/d" \
			-i features/org.eclipse.jdt/build.xml

		sed -e "/id=\"org.eclipse.jdt.apt.pluggable.core\"/,/<plugin/d" \
			-e "/id=\"org.eclipse.jdt.compiler.apt\"/,/<plugin/d" \
			-e "/id=\"org.eclipse.jdt.compiler.tool\"/,/<plugin/d" \
			-i features/org.eclipse.jdt/feature.xml

		sed -e "/dir=\"plugins\/org.eclipse.jdt.apt.pluggable.core\"/d" \
			-e "/dir=\"plugins\/org.eclipse.jdt.compiler.apt/d" \
			-e "/dir=\"plugins\/org.eclipse.jdt.compiler.tool\"/d" \
			-e "/value=\"org.eclipse.jdt.apt.pluggable.core/,/eclipse.plugins/d" \
			-e "/value=\"org.eclipse.jdt.compiler.apt/,/eclipse.plugins/d" \
			-e "/value=\"org.eclipse.jdt.compiler.tool/,/eclipse.plugins/d" \
			-i assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml
	fi

	sed -e "/plugins\/javax.servlet.source_/d" \
		-e "/plugins\/javax.servlet.jsp.source_/d" \
		-e "/plugins\/org.apache.jasper.source_/d" \
		-e "/plugins\/org.apache.commons.el.source_/d" \
		-e "/plugins\/org.apache.commons.logging.source_/d" \
		-e "/plugins\/org.apache.ant.source_/d" \
		-e "/plugins\/org.apache.lucene.source_/d" \
		-e "/plugins\/org.apache.lucene.analysis.source_/d" \
		-e "/value=\"javax.servlet.source_/,/eclipse.plugins/d" \
		-e "/value=\"javax.servlet.jsp.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.jasper.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.commons.el.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.commons.logging.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.ant.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.lucene.source_/,/eclipse.plugins/d" \
		-e "/value=\"org.apache.lucene.analysis.source_/,/eclipse.plugins/d" \
		-i package.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml

	# waaaaahhhhhhk !!!!11oneone
	epatch ${PATCHDIR}/eclipse_build-libs.diff
	epatch ${PATCHDIR}/eclipse_String.compareTo.diff
	epatch ${PATCHDIR}/eclipse_buildfix-pde.diff

	# JNI
	epatch ${FEDORA}/eclipse-libupdatebuild2.patch

	# Generic releng plugins that can be used to build plugins
	# https://www.redhat.com/archives/fedora-devel-java-list/2006-April/msg00048.html
	pushd plugins/org.eclipse.pde.build > /dev/null
	# %patch53
	epatch ${FEDORA}/eclipse-pde.build-add-package-build.patch
	sed -e "s:@eclipse_base@:${ECLIPSE_DIR}:g" -i templates/package-build/build.properties
	popd > /dev/null

	# Later we could produce a patch out of all these sed, but this is not the best solution
	# since this would make a lot of patches (x86, x86_64...) and would be hard to revbump

	# Following adds an additional classpath when building JSPs
	sed -i '/<path id="@dot\.classpath">/ a\
			<filelist dir="" files="${gentoo.jars}" />'  plugins/org.eclipse.help.webapp/build.xml

	# Following allows the doc USE flag to be honored
	sed -i -e '/<target name="generateJavadoc" depends="getJavadocPath"/ c\
		<target name="generateJavadoc" depends="getJavadocPath" if="gentoo.javadoc">' \
		-e '/<replace file="\${basedir}\/\${optionsFile}" token="@rt@" value="\${bootclasspath}/ c\
		<replace file="${basedir}/${optionsFile}" token="@rt@" value="${bootclasspath}:${gentoo.classpath}" />' \
		"plugins/org.eclipse.platform.doc.isv/buildDoc.xml"

	# Following disables Tomcat entirely
	sed -i '/plugins\/org\.eclipse\.tomcat"/{N;N;N;N;d;}' "features/org.eclipse.platform/build.xml"
	sed -i '/org\.eclipse\.tomcat/{N;N;N;d;}' "plugins/org.eclipse.platform.source/build.xml"
	sed -i '/<ant.*org\.eclipse\.tomcat/{N;N;d;}' "assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml"

	# This allows to compile osgi.util and osgi.service, and fixes IPluginDescriptor.class which is present compiled
	sed -i -e 's/<src path="\."/<src path="org"/' -e '/<include name="org\/"\/>/ d' \
	-e '/<subant antfile="\${customBuildCallbacks}" target="pre\.gather\.bin\.parts" failonerror="false" buildpath="\.">/ { n;n;n; a\
		<copy todir="${destination.temp.folder}/org.eclipse.osgi.services_3.1.200.v20071203" failonerror="true" overwrite="false"> \
			<fileset dir="${build.result.folder}/@dot"> \
				<include name="**"/> \
			</fileset> \
		</copy>
}' plugins/org.eclipse.osgi.services/build.xml

	sed -i -e 's/<src path="\."/<src path="org"/' -e '/<include name="org\/"\/>/ d' \
	-e '/<subant antfile="\${customBuildCallbacks}" target="pre\.gather\.bin\.parts" failonerror="false" buildpath="\.">/ { n;n;n; a\
		<copy todir="${destination.temp.folder}/org.eclipse.osgi.util_3.1.200.v20071203" failonerror="true" overwrite="false"> \
			<fileset dir="${build.result.folder}/@dot"> \
				<include name="**"/> \
			</fileset> \
		</copy>
}' 	plugins/org.eclipse.osgi.util/build.xml

	sed -i 	'/<mkdir dir="${temp\.folder}\/runtime_registry_compatibility\.jar\.bin"\/>/ a\
		<mkdir dir="classes"/> \
		<copy todir="classes" failonerror="true" overwrite="false"> \
			<fileset dir="${build.result.folder}/../org.eclipse.core.runtime/@dot/" includes="**/IPluginDescriptor.class" > \
			</fileset> \
		</copy>' plugins/org.eclipse.core.runtime.compatibility.registry/build.xml

	# This removes the copying operation for bundled jars
	sed -e "s/<copy.*com\.jcraft\.jsch.*\/>//" \
		-e "s/<copy.*com\.ibm\.icu.*\/>//" \
		-e "s/<copy.*org\.apache\.commons\.el_.*\/>//" \
		-e "s/<copy.*org\.apache\.commons\.logging_.*\/>//" \
		-e "s/<copy.*javax\.servlet\.jsp_.*\/>//" \
		-e "s/<copy.*javax\.servlet_.*\/>//" \
		-e "s/<copy.*org\.apache\.lucene_.*\/>//" \
		-e "s/<copy.*org\.apache\.lucene\.analysis_.*\/>//" \
		-i package.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml
}

remove-bundled-stuff() {
	# Remove pre-built eclipse binaries
	find ${S} -type f -name eclipse | xargs rm
	# ...  .so libraries
	find ${S} -type f -name '*.so' | xargs rm
	# ... .jar files
	rm plugins/org.eclipse.osgi/osgi/osgi*.jar \
		plugins/org.eclipse.osgi/supplement/osgi/osgi.jar \
		plugins/org.eclipse.swt/extra_jars/exceptions.jar

	rm -rf plugins/org.eclipse.swt.* plugins/org.apache.ant_*/*
	rm plugins/org.apache.commons.*.jar plugins/com.jcraft.jsch* \
		plugins/com.ibm.icu* plugins/org.junit_*/*.jar \
		plugins/org.junit4*/*.jar plugins/javax.*.jar \
		plugins/org.apache.lucene_*.jar plugins/org.apache.lucene.analysis_*.jar

	# Removing Tomcat stuff
	rm -rf plugins/org.eclipse.tomcat/

	# Remove bundled classes
	rm -rf plugins/org.eclipse.osgi.services/org
	unzip -q plugins/org.eclipse.osgi.services/src.zip -d plugins/org.eclipse.osgi.services/
	rm -rf plugins/org.eclipse.osgi.util/org
	unzip -q plugins/org.eclipse.osgi.util/src.zip -d plugins/org.eclipse.osgi.util/

	rm -rf plugins/org.eclipse.jdt.core/scripts/*.class
	rm -rf plugins/org.eclipse.core.runtime.compatibility.registry/classes
}
