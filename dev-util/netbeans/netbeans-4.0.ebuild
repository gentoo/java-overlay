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
		=dev-java/commons-logging-1.0*
		dev-java/regexp
		=dev-java/xalan-2*
		=dev-java/junit-3.8*"

RDEPEND="
		>=virtual/jre-1.4.2
		 dev-java/commons-el
		 =dev-java/servletapi-2.4*
		 dev-java/sac
		"

S=${WORKDIR}/netbeans-src
		
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

	#Remove non-x86 Linux binaries
	find $S -name "*.exe" -o -name "*.cmd" -o -name "*.dll" | xargs rm -f 	
}

src_install()
{	
	local DESTINATION="/usr/share/netbeans-${SLOT}"
	insinto $DESTINATION
#	local D_DESTINATION="${D}/${DESTINATION}"

	BUILDDESTINATION="${S}/nbbuild/netbeans"
	cd $BUILDDESTINATION

#The program itself
	doins -r * 

	fperms 655 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform4/lib/nbexec
	
	#The symlink to the binary
	dodir /usr/bin
	dosym ${DESTINATION}/bin/netbeans /usr/bin/netbeans-${SLOT}

#ant stuff
	local ANTDIR="${DESTINATION}/ide4/ant"
	cd ${D}/${ANTDIR}

	rm -fr ./lib
	dodir /usr/share/ant-core/lib
	dosym /usr/share/ant-core/lib ${ANTDIR}/lib

	rm -fr ./bin
	dodir /usr/share/ant-core/bin
	dosym /usr/share/ant-core/bin  ${ANTDIR}/bin

#NOTICE THIS. We first installed everything here 
#and now we will remove some stuff from here and
#install it somewhere else instead.
 
	cd ${D}/${DESTINATION}
		
#Documentation

	#The next directory seems to be empty	
	if ! rmdir doc 2> /dev/null; then	
		use doc || rm -fr ./doc
	fi
	
	use doc || rm -fr ./nb4.0/docs

	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css
	
	rm -f build_info CREDITS.html README.html netbeans.css

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
