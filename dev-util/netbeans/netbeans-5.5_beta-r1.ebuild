# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="NetBeans IDE for Java"
HOMEPAGE="http://www.netbeans.org"

# ant-mis is stuff we never use put instead of pactching we let the build process use this file
# so adding the license just to be sure
# The list of files in here is not complete but just some I listed.
# Apache-1.1: webserver.jar
# Apache-2.0: ant-misc-1.6.2.zip
# as-is: docbook-xsl-1.65.1.zip, pmd-netbeans35-bin-0.91.zip

# There are many other scrambled files in Netbeans but the
# default module configuration doesn't use all of them.
#
# Check the experimental tree for useful stuff.
# https://gentooexperimental.org/svn/java/gentoo-java-experimental/dev-util/netbeans/files
#
# This command should be run after ebuild <pkg> unpack in the source root
# 'ebuild netbeans-${PVR}.ebuild compile | grep Unscrambling | grep "\.jar"'
# Check which jars are actually being used to compile Netbeans
#
# This command should be run after ebuild <pkg> install in the image root
# 'find . -name "*.jar" -type f | less'
# Check the list to see that no packed jars get copied to the image
#
# Remove the unset DISPLAY line from src_compile to get graphical license dialogs and pause before
# unscramble

MY_PV=${PV/_/-}
MY_PV=${MY_PV/./_}

BASELOCATION="http://us1.mirror.netbeans.org/download/${MY_PV/-//}/200605090801"
MAINTARBALL="netbeans-${MY_PV}-ide_sources.tar.bz2"
JAVADOCTARBALL="netbeans-${MY_PV}-javadoc.tar.bz2"

SRC_URI="${BASELOCATION}/${MAINTARBALL}
	 doc? ( ${BASELOCATION}/${JAVADOCTARBALL} )"

LICENSE="Apache-1.1 Apache-2.0 SPL W3C sun-bcla-j2eeeditor sun-bcla-javac sun-javac as-is docbook sun-resolver"
SLOT="5.5"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc"

# dev-java/xml-commons-resolver for future versions
#		  dev-java/saxpath
#		 =dev-java/jakarta-regexp-1.3*
#		  dev-java/javamake-bin
#		 =dev-java/jaxen-1.1*
#		  dev-java/jtidy

# NB 5.5 requires javahelp 2.0_03 not yet released :(
RDEPEND="=virtual/jre-1.5*
		  =dev-java/commons-logging-1.0*
		   dev-java/commons-el
		   dev-java/sun-jmx
		  =dev-java/junit-3.8*
		  =dev-java/servletapi-2.2*
		  =dev-java/servletapi-2.3*
		  =dev-java/servletapi-2.4*
		   dev-java/sac
		   dev-java/flute
		 >=dev-java/jmi-interface-1.0-r1
		 >=dev-java/javahelp-bin-2.0.02-r1
		  =www-servers/tomcat-5.5*
		   dev-java/sun-j2ee-deployment-bin
		   dev-java/xml-commons
		   dev-java/jakarta-jstl
		 >=dev-java/xerces-2.8.0
		   "
DEPEND="${RDEPEND}
		=virtual/jdk-1.5*
		>=dev-java/ant-1.6.2
		  dev-util/pmd
		  dev-libs/libxslt
		 =dev-java/xalan-2*
"

TOMCATSLOT="5.5"

# Replacement JARs for Netbeans
COMMONS_LOGGING="commons-logging commons-logging.jar commons-logging-1.0.4.jar"
#JASPERCOMPILER="tomcat-${TOMCATSLOT} jasper-compiler.jar jasper-compiler-5.5.9.jar"
#JASPERRUNTIME="tomcat-${TOMCATSLOT} jasper-runtime.jar jasper-runtime-5.5.9.jar"
JH="javahelp-bin jh.jar jh-2.0_02.jar"
JHALL="javahelp-bin jhall.jar jhall-2.0_02.jar"
JMI="jmi-interface jmi.jar jmi.jar"
JSPAPI="servletapi-2.4 jsp-api.jar jsp-api-2.0.jar"
JSR="sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar"
JSTL="jakarta-jstl jstl.jar	jstl-1.1.2.jar"
JUNIT="junit junit.jar junit-3.8.1.jar"
MOF="jmi-interface mof.jar mof.jar"
PMD="pmd pmd.jar pmd-1.3.jar"
SERVLET22="servletapi-2.2 servlet.jar servlet-2.2.jar"
SERVLET23="servletapi-2.3 servlet.jar servlet-2.3.jar"
SERVLET24="servletapi-2.4 servlet-api.jar servlet-api-2.4.jar"
STANDARD="jakarta-jstl standard.jar standard-1.1.2.jar"
XERCES="xerces-2 xercesImpl.jar xerces-2.8.0.jar"
XMLCOMMONS="xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar"

#REGEXP="jakarta-regexp-1.3 jakarta-regexp.jar regexp-1.2.jar"

S=${WORKDIR}/netbeans-src
BUILDDESTINATION="${S}/nbbuild/netbeans"
ENTERPRISE="3"
IDE_VERSION="7"
PLATFORM="6"
MY_FDIR="${FILESDIR}/${SLOT}"
DESTINATION="${ROOT}usr/share/netbeans-${SLOT}"

antflags=""

set_env() {

	antflags=""

	if use debug; then
		antflags="${antflags} -Dbuild.compiler.debug=true"
		antflags="${antflags} -Dbuild.compiler.deprecation=true"
	else
		antflags="${antflags} -Dbuild.compiler.deprecation=false"
	fi

	antflags="${antflags} -Dstop.when.broken.modules=true"

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY

	# -Xmx1g: Increase Java maximum heap size, otherwise ant will die with
	#         an OutOfMemoryError while building.
	# -Djava.awt.headless=true: Sun JDK doesnt like that very much, so
	#                           lets pleasure them too ;-)
	#
	# We use the ANT_OPTS environment variable because other ways seem to
	# fail.
	#
	export ANT_OPTS="${ANT_OPTS} -Xmx1g -Djava.awt.headless=true"

}

src_unpack () {
	unpack ${MAINTARBALL}

	if use doc; then
		mkdir javadoc && cd javadoc
		unpack ${JAVADOCTARBALL} || die "Unable to extract javadoc"
		rm -f *.zip
	fi

        cd ${S}
        epatch ${FILESDIR}/${SLOT}/files-layout-txt.patch
        epatch ${FILESDIR}/${SLOT}/public-packages-txt.patch

	cd ${S}/nbbuild
	# Disable the bundled Tomcat in favor of Portage installed version
#	sed -i -e "s%tomcatint/tomcat5/bundled,%%g" *.properties

	set_env
	place_symlinks
}

src_compile() {

	set_env

	# The location of the main build.xml file
	cd ${S}/nbbuild

	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	eant ${antflags}

	# Remove non-x86 Linux binaries
	find ${BUILDDESTINATION} -type f \
		-name "*.exe" -o \
		-name "*.cmd" -o \
		-name "*.bat" -o \
		-name "*.dll"	  \
		| xargs rm -f

	# Removing external stuff. They are api docs from external libs.
	cd ${BUILDDESTINATION}/ide${IDE_VERSION}/docs
	rm -f *.zip

	# The next directory seems to be empty
	if ! rmdir doc 2> /dev/null; then
		use doc || rm -fr ./doc
	fi

	# Use the system ant
	cd ${BUILDDESTINATION}/ide${IDE_VERSION}/ant

	rm -fr ./lib
	rm -fr ./bin

	# Set a initial default jdk
	echo "netbeans_jdkhome=\"/etc/java-config-2/current-system-vm/\"" \
		>> ${BUILDDESTINATION}/etc/netbeans.conf
}

src_install() {
	insinto $DESTINATION

	einfo "Installing the program..."
	cd ${BUILDDESTINATION}
	doins -r *

	symlink_extjars ${D}/${DESTINATION}

	fperms 755 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform${PLATFORM}/lib/nbexec

	# The wrapper wrapper :)
	newbin ${MY_FDIR}/startscript.sh netbeans-${SLOT}

	# Ant installation
	local ANTDIR="${DESTINATION}/ide${IDE_VERSION}/ant"
	cd ${D}/${ANTDIR}

	dodir /usr/share/ant-core/lib
	dosym /usr/share/ant-core/lib ${ANTDIR}/lib

	dodir /usr/share/ant-core/bin
	dosym /usr/share/ant-core/bin  ${ANTDIR}/bin

	# Documentation
	einfo "Installing Documentation..."

	cd ${D}/${DESTINATION}

	use doc && java-pkg_dohtml -r ${WORKDIR}/javadoc/*

	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css

	rm -f build_info CREDITS.html README.html netbeans.css

	# Icons and shortcuts
	einfo "Installing icons..."

	dodir ${DESTINATION}/icons
	insinto ${DESTINATION}/icons
	doins ${S}/ide/branding/release/*png

	for res in "16x16" "24x24" "32x32" "48x48" "128x128" ; do
		dodir /usr/share/icons/hicolor/${res}/apps
		dosym ${DESTINATION}/icons/netbeans.png /usr/share/icons/hicolor/${res}/apps/netbeans.png
	done

	make_desktop_entry netbeans-${SLOT} "Netbeans ${SLOT}" netbeans Development
}

pkg_postinst () {
	einfo "Your tomcat directory might not have the right permissions."
	einfo "Please make sure that normal users can read the directory: "
	einfo "${ROOT}usr/share/tomcat-${TOMCATSLOT}                      "
	einfo "                                                           "
	einfo "The integrated Tomcat is not installed, but you can easily "
	einfo "use the system Tomcat. See Netbeans documentation if you   "
	einfo "don't know how to do that. The relevant settings are in the"
	einfo "runtime window.                                            "
}

pkg_postrm() {
#	einfo "Removing symlinks to jars from"
#	einfo "${DESTINATION}"
#	find ${DESTINATION} -type l | xargs rm -fr

	if ! test -e /usr/bin/netbeans-${SLOT}; then
		einfo "Because of the way Portage works at the moment"
		einfo "symlinks to the system jars are left to:"
		einfo "${DESTINATION}"
		einfo "If you are uninstalling Netbeans you can safely"
		einfo "remove everything in this directory"
	fi
}

# Supporting functions for this ebuild

function fix_manifest() {
	sed -i "s%ext/${1}%$(java-pkg_getjar ${2} ${3})%" ${4}
}

function place_symlinks() {
	einfo "Symlinking scrambled jars to system jars"

# Commented out till 2.0_03 is released
#	cd ${S}/core/external
#	hide jh*.jar || die 
#	java-pkg_jar-from ${JHALL}

	cd ${S}/mdr/external/
	hide jmi.jar mof.jar || die
	java-pkg_jar-from ${JMI} || die
	java-pkg_jar-from ${MOF} || die

# Commented out till 2.0_03 is released
#	cd ${S}/nbbuild/external
#	hide jhall*.jar || die
#	java-pkg_jar-from ${JHALL} || die

	cd ${S}/libs/external/
	hide xerces*.jar commons-logging*.jar xml-commons*.jar pmd*.jar  || die
	java-pkg_jar-from ${XERCES} || die
	java-pkg_jar-from ${COMMONS_LOGGING} || die
	java-pkg_jar-from ${XMLCOMMONS} || die
	java-pkg_jar-from ${PMD} || die

	cd ${S}/httpserver/external/
	hide servlet*.jar || die
	java-pkg_jar-from ${SERVLET22} || die

	cd ${S}/j2eeserver/external
	hide jsr*.jar || die
	java-pkg_jar-from ${JSR} || die

	cd ${S}/junit/external/
	hide junit*.jar || die
	java-pkg_jar-from ${JUNIT} || die

	cd ${S}/web/external
#	hide servlet-*.jar jasper*.jar jsp*.jar jstl*.jar standard*.jar commons-el*.jar || die
	hide servlet-*.jar  jsp*.jar jstl*.jar standard*.jar commons-el*.jar || die
	java-pkg_jar-from ${SERVLET23} || die
	java-pkg_jar-from ${SERVLET24} || die 
#	java-pkg_jar-from ${JASPERCOMPILER} || die
#	java-pkg_jar-from ${JASPERRUNTIME} || die
	java-pkg_jar-from ${JSPAPI} || die
	java-pkg_jar-from ${JSTL} || die
	java-pkg_jar-from ${STANDARD} || die
	java-pkg_jar-from commons-el || die

	cd ${S}/xml/external/
	hide flute*.jar sac*.jar || die
	java-pkg_jar-from sac || die
	java-pkg_jar-from flute || die
}

function symlink_extjars() {
	einfo "Added symlinks to system jars inside"
	einfo "${DESTINATION}"

	cd ${1}/ide${IDE_VERSION}/modules/ext
	java-pkg_jar-from ${COMMONS_LOGGING}
	java-pkg_jar-from flute
	java-pkg_jar-from sac
	java-pkg_jar-from ${JMI}
	java-pkg_jar-from ${MOF}
	java-pkg_jar-from ${JUNIT}

	cd ${1}/ide${IDE_VERSION}/modules/ext
	java-pkg_jar-from ${SERVLET22}
	java-pkg_jar-from ${XERCES}
	java-pkg_jar-from ${XMLCOMMONS}

	cd ${1}/enterprise${ENTERPRISE}/modules/ext
	java-pkg_jar-from commons-el
	java-pkg_jar-from ${SERVLET23}
	java-pkg_jar-from ${SERVLET24}
	java-pkg_jar-from ${JSR}
#	java-pkg_jar-from ${JASPERCOMPILER}
#	java-pkg_jar-from ${JASPERRUNTIME}
	java-pkg_jar-from ${JSPAPI}
	java-pkg_jar-from jakarta-jstl jstl.jar
	java-pkg_jar-from jakarta-jstl standard.jar

# Commented out till 2.0_03 is released
#	cd ${1}/platform${IDE_VERSION}/modules/ext
#	java-pkg_jar-from ${JHALL}
}

function hide() {
	for x in $@ ; do
		mv $x _$x
	done
}

function unscramble_and_empty() {
	echo $(pwd)
	yes yes 2> /dev/null | ant ${antflags} unscramble > /dev/null || die "Failed to unscramble"
	remove_unscrambling
}

function remove_unscrambling() {
	local file=${1}

	[ -z ${file} ] && file="build.xml"

	xsltproc -o ${T}/out.xml ${FILESDIR}/emptyunscramble.xsl ${file} \
		|| die "Failed to remove unscrambling from one of the build.xml files"
	mv ${T}/out.xml ${file}
}
