# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Jetty and Jasper have to stay bundled for now, until someone does some work on them.

# ECF also has to stay bundled due to a chicken and egg situation. We could use
# the bundled version to build Eclipse and then build ECF later but it's still
# a pain to build without using chewi-overlay.

# Current patches are hard to maintain when revbumping.
# Two solutions:
# 1) Split patches so that there is one per file
# 2) Use sed, better solution I would say.

EAPI="1"

JAVA_ANT_DISABLE_ANT_CORE_DEP="true"
WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2 check-reqs

DMF="R-${PV}-200809111700"
MY_A="eclipse-sourceBuild-srcIncluded-${PV}.zip"

DESCRIPTION="Eclipse Tools Platform"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_A}"

SLOT="3.4"
LICENSE="EPL-1.0"
IUSE="doc java6 source"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}"
PATCHDIR="${FILESDIR}/${SLOT}"
ECLIPSE_DIR="/usr/$(get_libdir)/eclipse-${SLOT}"
BUILDPARSER="/usr/$(get_libdir)/javatoolkit/bin/buildparser"

CDEPEND="dev-java/swt:${SLOT}
	dev-java/ant-eclipse-ecj:${SLOT}
	>=dev-java/ant-1.7.1
	>=dev-java/ant-core-1.7.1
	>=dev-java/asm-3.1:3
	>=dev-java/jsch-0.1.36-r1
	>=dev-java/icu4j-3.8.1:0
	>=dev-java/commons-el-1.0-r2
	>=dev-java/commons-logging-1.1-r6
	>=dev-java/lucene-analyzers-1.9.1-r1:1.9
	>=dev-java/tomcat-servlet-api-5.5.25-r1:2.4
	dev-java/cldc-api:1.1
	dev-java/junit:0
	dev-java/junit:4
	dev-java/lucene:1.9
	dev-java/sat4j-core:2
	dev-java/sat4j-pseudo:2"

RDEPEND="${CDEPEND}
	${JAVA_ANT_E_DEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	java6? ( >=virtual/jdk-1.6 )
	>=dev-java/javatoolkit-0.3
	app-arch/unzip
	app-arch/zip"

JAVA_PKG_BSFIX="off"

pkg_setup() {
	java-pkg-2_pkg_setup

	CHECKREQS_MEMORY="512"
	check_reqs

	if use doc ; then
		ewarn "Having the doc USE flag enabled greatly increases the build time. You might"
		ewarn "want to disable it for ${PN} if you don't need it."
	fi

	eclipsearch=${ARCH}
	use amd64 && eclipsearch="x86_64"
}

src_unpack() {
	unpack ${A}
	patch-apply
	remove-bundled-stuff

	while read line; do
		java-ant_rewrite-classpath "${line}" > /dev/null
	done < <(find "${S}" -type f -name "build.xml")
}

src_compile() {
	java-pkg_force-compiler ecj-${SLOT}

	local bootclasspath=$(java-config --runtime)
	local options="-q -Dnobootstrap=true -Dlibsconfig=true -Dbootclasspath=${bootclasspath} -DinstallOs=linux \
		-DinstallWs=gtk -DinstallArch=${eclipsearch} -Djava5.home=$(java-config --jdk-home)"

	use java6 && options="${options} -DJavaSE-1.6=${bootclasspath}"

	ANT_OPTS="-Xmx512M" eant ${options}

	# Generate P2 metadata.
	`java-config -J` -jar eclipse/plugins/org.eclipse.equinox.launcher_*.jar -data workspace \
		-application org.eclipse.equinox.p2.metadata.generator.EclipseGenerator -flavor tooling \
		-metadataRepositoryName "Gentoo Eclipse" -artifactRepositoryName "Gentoo Eclipse" \
		-metadataRepository "file:eclipse/metadata" -artifactRepository "file:eclipse/metadata" \
		-root "Gentoo Eclipse SDK" -rootVersion "${SLOT}" -source eclipse -append -publishArtifacts || die
}

src_install() {
	# Root files don't get included by P2.
	insinto "${ECLIPSE_DIR}"
	doins -r features/org.eclipse.platform/rootfiles/{.eclipseproduct,*}

	# Workaround https://bugs.eclipse.org/bugs/show_bug.cgi?id=241430...
	rm -rf eclipse/configuration/.settings || die

	# Install using P2.
	`java-config -J` -Declipse.p2.data.area="file:${D}/${ECLIPSE_DIR}/p2" \
		-jar eclipse/plugins/org.eclipse.equinox.launcher_*.jar -data workspace \
		-application org.eclipse.equinox.p2.director.app.application -flavor tooling \
		-metadataRepository "file:eclipse/metadata" -artifactRepository "file:eclipse/metadata" \
		-installIU "Gentoo Eclipse SDK" -version "${SLOT}" -p2.os linux -p2.ws gtk -p2.arch ${eclipsearch} \
		-profile SDKProfile -profileProperties org.eclipse.update.install.features=true  \
		-destination "${D}/${ECLIPSE_DIR}" -bundlepool "${D}/${ECLIPSE_DIR}" -roaming || die

	cd "${D}/${ECLIPSE_DIR}" || die

	# Delete unneeded files.
	rm -rf p2/org.eclipse.equinox.p2.core || die

	# Restore symlinks. P2 has ignored them.
	rm -rf plugins/org.apache.ant_*/{bin,lib} || die
	ln -snf /usr/share/ant/bin plugins/org.apache.ant_*/ || die
	ln -snf /usr/share/ant/lib plugins/org.apache.ant_*/ || die
	cp -af "${S}"/plugins/org.junit_*/*.jar plugins/org.junit_*/ || die
	cp -af "${S}"/plugins/org.junit4/*.jar plugins/org.junit4_*/ || die

	# Install startup script.
	dobin "${FILESDIR}/${SLOT}/eclipse-${SLOT}" || die

	# Install global rc script.
	insinto /etc
	doins "${FILESDIR}/${SLOT}/eclipserc-${SLOT}" || die

	# Install icon and make desktop entry.
	newicon "${S}/features/org.eclipse.equinox.executable/bin/gtk/linux/x86/icon.xpm" eclipse.xpm || die
	make_desktop_entry eclipse-${SLOT} "Eclipse ${PV}" eclipse.xpm || die
}

pkg_postinst() {
	einfo "Welcome to Eclipse ${PV} (Ganymede)!"
	einfo " "
	einfo "You can now install plugins via Update Manager without any"
	einfo "tweaking. This is the recommended way to install new features for Eclipse."
	einfo " "
	einfo "Please read http://gentoo-wiki.com/Eclipse"
	einfo "It contains a lot of useful information and help about Eclipse on Gentoo."
	einfo " "
	einfo "The FileInitializer Plugin is no longer integrated."
	einfo "If you need it, get org.eclipse.equinox.initializer_x.y.z.jar from:"
	einfo "	http://download.eclipse.org/eclipse/equinox/"
}

# -----------------------------------------------------------------------------
#  Helper functions
# -----------------------------------------------------------------------------

patch-apply() {
	# Optimize launcher build.
	unzip -q plugins/org.eclipse.platform/launchersrc.zip library/gtk/make_linux.mak || die
	sed -i -r "s/CFLAGS = -g -s\b/CFLAGS =/;/CFLAGS =/a\\\\t${CFLAGS}\\\\" library/gtk/make_linux.mak || die
	zip -qrm plugins/org.eclipse.platform/launchersrc.zip library || die

	# Avoid doing any unnecessary copying or archiving at the end of the build.
	sed -r -i '/<exec .*\bexecutable="tar"/,/<delete /d' {assemble,package}.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die
	sed -r -i '/<delete /,/<delete .*\bdir=/d' build.xml || die
	mkdir -p tmp/eclipse || die
	ln -snf tmp/eclipse eclipse || die

	if ! use java6; then
		sed -r '/<ant .*\/org\.eclipse\.jdt\.(apt\.pluggable\.core|compiler\.(apt|tool))(\.source)?"/,/<\/ant>/d' \
			-i features/org.eclipse.jdt{,.source}/build.xml || die
		sed -r '/id="org\.eclipse\.jdt\.(apt\.pluggable\.core|compiler\.(apt|tool))"/,/<plugin /d' \
			-i features/org.eclipse.jdt/feature.xml || die
		sed -r '/id="org\.eclipse\.jdt\.(apt\.pluggable\.core|compiler\.(apt|tool))\.source"/d' \
			-i features/org.eclipse.jdt.source/feature.xml || die
		sed -r -e '/<customGather .*\/org\.eclipse\.jdt\.(apt\.pluggable\.core|compiler\.(apt|tool))(\.source)?"/d' \
			-e '/value="org\.eclipse\.jdt\.(apt\.pluggable\.core|compiler\.(apt|tool))(\.source)?_/,/eclipse\.plugins/d' \
			-i assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die
	fi

	# Miscellaneous patches.
	epatch "${PATCHDIR}/eclipse_build-libs.diff"

	# JNI.
	sed -i '/value="x86"/d' plugins/org.eclipse.update.core.linux/src/build.xml || die

	# Following adds an additional classpath when building JSPs.
	sed -i '/<path id="@dot\.classpath".*/a<pathelement path="${gentoo.classpath}" />' \
		plugins/org.eclipse.help.webapp/build{,JSPs}.xml || die

	# No warnings. Java5. Direct output to stdout.
	find -type f -name '*.xml' -exec \
		sed -r -e 's:"compilerArg" value=":\0-nowarn :g' \
		-e 's:(<property name="javac(Source|Target)" value=)".*":\1"1.5":g' \
		-e 's:output="[^"]+\.(txt|log)"::g' -i {} \; || die

	# JDK home and CFLAGS.
	sed -r -e "s:^(JAVA_HOME ?=).*:\1 $(java-config --jdk-home):" -e "s:^(OPT_FLAGS ?=).*:\0 ${CFLAGS}:" \
		-i plugins/org.eclipse.core.filesystem/natives/unix/linux/Makefile || die "sed Makefile failed"

	# Don't build plugins for other archs or GUI toolkits. Don't gather their sources either.
	sed -r -e '/<ant .*\.(aix|carbon|hpux|macosx|motif|qnx|solaris|win32)[".]/,/<\/ant>/d' \
		-e '/<ant .*\/org\.eclipse\.swt\..+(\.source)?"/,/<\/ant>/d' \
		-i features/org.eclipse.{platform,rcp}{,.source}/build.xml || die

	if ! use doc ; then
		# Don't reference the docs. Slightly evil but it works.
		sed -r '/<plugin/{:x;/id="[^"]*\.doc\./{:y;/\/>/d;N;by};/\/>/b;N;bx}' \
			-i features/*/feature.xml || die

		# Don't install the docs.
		sed -r '/<customGather .*\.doc\./d' \
			-i assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die

		# Don't build the docs.
		sed -i '/<antcall .*\btarget="build.doc.plugins"/d' build.xml || die
		sed -i '/<ant .*\/.*\.doc\./,/<\/ant>/d' features/*/build.xml || die

		# Don't reference the doc plugins in the sources. These feature.xml files
		# thankfully have their plugins on one line. Let's hope they stay that way.
		sed -r '/<plugin id="[^"]*\.doc\./d' \
			-i features/*.source/feature.xml || die
	fi

	if ! use source ; then
		# Don't reference the sources. Slightly evil but it works.
		sed -r '/<includes/{:x;/id="[^"]*\.source"/{:y;/\/>/d;N;by};/\/>/b;N;bx}' \
			-i features/org.eclipse.sdk/feature.xml || die

		# Don't install the sources.
		sed -r '/<(copy|customGather) .*\.source/d' \
			-i {assemble,package}.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die
	fi

	# In 3.4.1, bootclasspath was removed from here. Not sure why.
	sed -r '/\bname="bundleBootClasspath"/s:value=":\0${bootclasspath};:' \
		-i plugins/org.eclipse.osgi/build.xml || die
}

remove-bundled-stuff() {
	local x
	pushd plugins >/dev/null

	# Remove pre-built binaries.
	find "${S}/features/org.eclipse.equinox.executable" -type f -name eclipse -delete || die
	# ..and libraries.
	find "${S}" -type f -name '*.so' -delete || die
	# ..and JAR files.
	rm -f org.eclipse.osgi/{,supplement}/osgi/osgi*.jar \
		org.eclipse.swt/extra_jars/exceptions.jar || die
	# ..and classes.
	rm -rf org.eclipse.jdt.core/scripts/*.class \
		org.eclipse.osgi.{services,util}/org || die

	# Unpack zipped sources for removed classes. If we unpack the sources to
	# src like the other plugins, the build order seems to change and things
	# break. Very bizarre. Consequently we have to adjust build.xml to
	# install the classes and not the sources. Ugly but it works.
	for x in services util ; do
		unzip -q org.eclipse.osgi.${x}/src.zip -d org.eclipse.osgi.${x}/ || die
		x=org.eclipse.osgi.${x}/build.xml
		{ rm ${x} && awk '/<target .*name="gather\.bin\.parts"/ { inside = 1 } { if (inside) { if ($0 ~ /"org\/"/) next; \
			if ($0 ~ /<\/fileset>/) { print; print "<fileset dir=\"${basedir}/@dot/\" includes=\"org/\"/>"; inside = 0; next } } } { print }' > ${x}; } < ${x} || die
	done

	# This prebuilt class actually comes from another plugin that will be
	# built so we can just symlink to that.
	ln -snf "${S}"/plugins/org.eclipse.core.runtime/@dot/org/eclipse/core/runtime/IPluginDescriptor.class \
		org.eclipse.core.runtime.compatibility.registry/classes/org/eclipse/core/runtime/IPluginDescriptor.class || die

	# Reset the list of system packages to use when building.
	EANT_GENTOO_CLASSPATH="swt:${SLOT} cldc-api:1.1"

	unbundle-jar org.apache.commons.el commons-el
	unbundle-jar org.apache.commons.logging commons-logging
	unbundle-jar com.jcraft.jsch jsch
	unbundle-jar com.ibm.icu icu4j
	unbundle-jar javax.servlet tomcat-servlet-api:2.4
	unbundle-jar javax.servlet.jsp tomcat-servlet-api:2.4
	unbundle-jar org.apache.lucene lucene:1.9
	unbundle-jar org.apache.lucene.analysis lucene-analyzers:1.9
	unbundle-jar org.objectweb.asm asm:3
	unbundle-jar org.sat4j.core sat4j-core:2
	unbundle-jar org.sat4j.pb sat4j-pseudo:2

	# Make the junit4 case easier.
	ln -snf org.junit4 org.junit4_ || die

	unbundle-dir org.apache.ant ant-core,ant-nodeps lib
	unbundle-dir org.junit junit .
	unbundle-dir org.junit4 junit-4 .

	# Don't include sources for junit4.
	sed -i '/junitsrc/d' org.junit4/customBuildCallbacks.xml || die

	# Unbundle SWT and make @dot directory to keep build happy.
	${BUILDPARSER} -i Bundle-ClassPath "external:$(java-pkg_getjars swt-${SLOT})" org.eclipse.swt.gtk.linux.${eclipsearch}/META-INF/MANIFEST.MF || die
	mkdir -p org.eclipse.swt.gtk.linux.${eclipsearch}/@dot || die
	remove-plugin-sources org.eclipse.swt.gtk.linux.${eclipsearch}

	# Mark the SWT plugins as unpacked. More evilness that works.
	sed -r '/<plugin/{:x;/id="org\.eclipse\.swt\./{:y;/\/>/s/unpack="[^"]*"/unpack="true"/;t;N;by};/\/>/b;N;bx}' \
		-i "${S}"/features/org.eclipse.rcp/feature.xml || die

	# Prevent the SWT plugin from being JAR'd.
	sed -r '/<param .*\bvalue="org.eclipse.swt.gtk.linux.'"${eclipsearch}"'_/d' \
		-i "${S}"/assemble.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die

	popd >/dev/null
}

# Unbundle a directory plugin by removing its JAR files and replacing them
# with symlinks. We don't modify the manifest because Eclipse's antRunner
# doesn't seem to like external JARs.
unbundle-dir() {
	ebegin "Unbundling $1"
	remove-plugin-sources $1

	# Delete the bundled JARs and signing files.
	rm -f "$1"_*/$3/*.jar "$1"_*/META-INF/ECLIPSE.{RSA,SF} || die

	# Replace the bundled JARs with symlinks.
	java-pkg_jar-from --into "$1"_*/$3 $2

	eend 0
}

# Unbundle a JAR plugin by removing its class files and modifying its manifest
# so that it points to external JARs instead. The plugin must remain unpacked
# because OSGi cannot handle external JARs in packed plugins.
unbundle-jar() {
	ebegin "Unbundling $1"
	remove-plugin-sources $1

	# Find full plugin name and version.
	local plugin=`echo $1_*`
	plugin=${plugin%.jar}

	# Make directory to replace JAR.
	mkdir -p "${plugin}" || die
	cd "${plugin}" || die
	rm -rf * || die

	# Extract what we need from the existing JAR.
	`java-config -j` xf "../${plugin}.jar" META-INF/MANIFEST.MF plugin.{properties,xml} || die

	# Apply our new classpath.
	local classpath=$(java-pkg_getjars $2)
	EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH} $2"
	${BUILDPARSER} -i Bundle-ClassPath "external:${classpath//:/,external:}" META-INF/MANIFEST.MF || die

	# The javadoc options are stored in text files and so rewriting the classpath in
	# the ant build files has no effect. Instead, we replace plugins paths with the
	# paths to their external JARs. Passing gentoo.classpath is too RAM-intensive.
	sed -i -r "s:^;\.\.\/${1//./\.}[_/].*\.jar$:;${classpath//:/\:}:" ../*/*Options.txt || die

	# Delete unneeded manifest entries.
	sed -i -r "/^Name:|^SHA1-Digest:/d" META-INF/MANIFEST.MF || die

	# This plugin is now unpacked. More evilness that works.
	sed -r '/<plugin/{:x;/id="'"${1//./\.}"'"/{:y;/\/>/s/unpack="[^"]*"/unpack="true"/;t;N;by};/\/>/b;N;bx}' \
		-i "${S}"/features/*/feature.xml || die

	# Copy the whole directory instead of just a JAR.
	sed -r "/<copy .*\/${1//./\.}/{s/<copy\b/<copydir/;s/\.jar//g;s/\bfile=/src=/;s/\btofile=/dest=/}" \
		-i "${S}"/package.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die

	# Delete JAR and return to previous directory.
	rm -f "../${plugin}.jar" || die
	cd .. || die

	eend 0
}

remove-plugin-sources() {
	use source || return

	# Don't reference the sources for this plugin. These feature.xml files
	# thankfully have their plugins on one line. Let's hope they stay that way.
	sed -r '/<plugin id="'"${1//./\.}"'\.source"/d' \
		-i "${S}/features"/*.source/feature.xml || die

	# Don't try to install the sources either.
	sed -r '/<(copy|copydir|customGather) .*\/'"${1//./\.}"'\.source/d' \
		-i "${S}"/{assemble,package}.org.eclipse.sdk.linux.gtk.${eclipsearch}.xml || die
}
