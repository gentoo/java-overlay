# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="NetBeans ${PV} IDE for Java"

IUSE="debug doc"
HOMEPAGE="http://www.netbeans.org"

SRC_URI="netbeans-4_0-src-ide_sources.tar.bz2"

SLOT="4.0"

#We need to add many licenses in here. 
LICENSE="GPL-2 Apache-1.1 sun-bcla-j2ee JPython SPL"
KEYWORDS="~x86"

DEPEND=">=virtual/jdk-1.4.2
		>=dev-java/ant-1.6.1
		=dev-java/xerces-2.6.2*
		dev-java/commons-logging
		dev-java/regexp
		dev-java/xalan"

RDEPEND=">=virtual/jre-1.4.2"

S=${WORKDIR}/netbeans-src
BUILDDESTINATION="${S}/nbbuild/netbeans"		
		
src_unpack () 
{
	unpack $A
	cd ${S}
	epatch ${FILESDIR}/nbbuild.patch
	
	cd ${S}/libs/external/
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.6.2.jar	
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jar-from regexp regexp.jar	regexp-1.2.jar
	java-pkg_jar-from xalan xalan-jar xalan-2.5.2.jar
	#removing tomcat
#	rm -fr tomcatint translatedfiles/src/tomcatint
}
src_compile()
{
	local antflags=""
	! use debug && antflags="${antflags} -Dno-deprecation"

    antflags="${antflags} -Dnetbeans.no.pre.unscramble=true"
    antflags="${antflags} -Dmoduleconfig=stable-without-webapps"

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY
	
	# Move into the folder where the build.xml file lives.
	cd ${S}/nbbuild
	
	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	yes yes 2>/dev/null | 	ant $antflags build-nozip || die "Compiling failed!"
}

src_install()
{	
	local DESTINATION="/usr/share/netbeans-${SLOT}"
	insinto $DESTINATION

	cd $BUILDDESTINATION

#The program itself
	dodir $DESTINATION
	cp -a * ${D}/$DESTINATION


#Remove non-x86 Linux binaries
	find $S -name "*.exe" -o -name "*.cmd" -o -name "*.dll" | xargs rm -f 
	
#removing tomcat
	rm -fr ${INSDESTREE}/nb4.0/jakarta-tomcat-*

#ant tasks
	insinto /usr/share/ant-tasks
	doins ide4/ant/nblib
	
	insinto $DESTINATION
	rm -fr ${INSDESTREE}/ide4/ant/
		
#Documentation

	#The next directory seems to be empty	
	if ! rmdir doc; then	
		use doc || rm -fr ./doc
	fi
	
	use doc || rm -fr ./nb4.0/docs


	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css
	cd ${INSDESTREE}
	rm -f nbuild_info CREDITS.html README.html netbeans.css

#The symlink to the binary
	dodir /usr/bin
	dosym ${DESTINATION}/bin/netbeans /usr/bin/netbeans-${SLOT}

#Icons and shortcuts
	echo "Symlinking icons...."

	dodir ${DESTINATION}/icons
	insinto ${DESTINATION}/icons
	doins ${S}/core/ide/release/bin/icons/*png
	
	for res in "16x16" "24x24" "32x32" "48x48" "128x128"
	do
		dodir /usr/share/icons/hicolor/${res}/apps
		dosym ${DESTINATION}/icons/nb${res}.png /usr/share/icons/hicolor/${res}/apps/netbeans.png
	done

	make_desktop_entry netbeans-${SLOT} Netbeans netbeans Development
}
