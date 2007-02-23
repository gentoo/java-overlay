# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2

MY_P="jboss-${PV}"
MY_P="${MY_P}.GA"
MY_EJB3="jboss-EJB-3.0_RC9_Patch_1"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
SRC_URI="mirror://sourceforge/jboss/${MY_P}.zip
		 ejb3? ( mirror://sourceforge/jboss/${MY_EJB3}.zip )"
RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="doc ejb3 srvdir"
SLOT="4"
KEYWORDS="~amd64 x86"
RDEPEND="ejb3? ( >=virtual/jdk-1.5 )
		!ejb3? ( >=virtual/jdk-1.4 )"

DEPEND="${RDEPEND} app-arch/unzip dev-java/ant dev-java/ant-contrib"

S=${WORKDIR}/${MY_P}
INSTALL_DIR="/opt/${PN}-${SLOT}"
DEFAULT_VHOST="localhost"
CACHE_INSTALL_DIR="/var/cache/${PN}-${SLOT}"
LOG_INSTALL_DIR="/var/log/${PN}-${SLOT}"
RUN_INSTALL_DIR="/var/run/${PN}-${SLOT}"
TMP_INSTALL_DIR="/var/tmp/${PN}-${SLOT}"
CONF_INSTALL_DIR="/etc/${PN}-${SLOT}"
FILESDIR_CONF_DIR=""

#switching configuration files directory
if use "srvdir" ; then
	SERVICES_DIR="/srv/${DEFAULT_VHOST}/${PN}-${SLOT}"
	FILESDIR_CONF_DIR="${FILESDIR}/${PV}/srvdir"
else
	SERVICES_BASE_DIR="/var/lib/${PN}-${SLOT}"
	SERVICES_DIR="${SERVICES_BASE_DIR}/${DEFAULT_VHOST}"
	FILESDIR_CONF_DIR="${FILESDIR}/${PV}/normal"
fi


# NOTE: When you are updating CONFIG_PROTECT env.d file, you can use this script on your current install
# run from /var/lib/jboss-${SLOT} to get list of files that should be config protected. We protect *.xml,
# *.properties and *.tld files.
# SLOT="4" TEST=`find /var/lib/jboss-${SLOT}/ -type f | grep -E -e "\.(xml|properties|tld)$"`; echo $TEST
# by kiorky better:
# echo "CONFIG_PROTECT=\"$(find /srv/localhost/jboss-bin-4/ -name "*xml" -or -name \
#          "*properties" -or -name "*tld" |xargs echo -n)\"">>env.d/50jboss-bin-4

# NOTE: using now GLEP20 as default

pkg_setup() {
	# create jboss user/group
	enewgroup jboss || die "Unable to create jboss group"
	enewuser jboss -1 /bin/sh ${SERVICES_DIR}  jboss \
		|| die	"Unable to create jboss user"
}


src_install() {
	# jboss core stuff
	# create the directory structure and copy the files
	diropts -m755
	dodir "${INSTALL_DIR}"        \
		  "${INSTALL_DIR}/bin"    \
		  "${INSTALL_DIR}/client" \
	      "${INSTALL_DIR}/lib"    \
		  "${SERVICES_DIR}/${DEFAULT_VHOST}" \
		  "${CACHE_INSTALL_DIR}/${DEFAULT_VHOST}"  \
		  "${CONF_INSTALL_DIR}/${DEFAULT_VHOST}"   \
		  "${LOG_INSTALL_DIR}/${DEFAULT_VHOST}"    \
		  "${RUN_INSTALL_DIR}/${DEFAULT_VHOST}"    \
		  "${TMP_INSTALL_DIR}/${DEFAULT_VHOST}"
	insopts -m645
	diropts -m755
	insinto "${INSTALL_DIR}/bin"
	doins -r bin/*.conf bin/*.jar
	exeinto "${INSTALL_DIR}/bin"
	doexe bin/*.sh
	insinto "${INSTALL_DIR}"
	doins -r client lib

	# copy startup stuff
	doinitd  "${FILESDIR_CONF_DIR}/init.d/${PN}-${SLOT}"
	# add multi instances support (here:localhost)
	dosym "/etc/init.d/${PN}-${SLOT}" \
			"/etc/init.d/${PN}-${SLOT}.${DEFAULT_VHOST}"
	newconfd "${FILESDIR_CONF_DIR}/conf.d/${PN}-${SLOT}" \
			"${PN}-${SLOT}"
	# add multi instances support (here:localhost)
	newconfd "${FILESDIR_CONF_DIR}/conf.d/${PN}-${SLOT}" \
			"${PN}-${SLOT}.${DEFAULT_VHOST}"
	gunzip  -c "${FILESDIR_CONF_DIR}/env.d/50${PN}-${SLOT}.gz">50${PN}-${SLOT}
	doenvd  "50${PN}-${SLOT}"
	# jboss profiles creator binary
	exeinto  /usr/bin
	doexe	 "${FILESDIR_CONF_DIR}/bin/jboss-bin-4-profiles-creator.sh"
	# implement GLEP20: srvdir
	addpredict "${SERVICES_DIR}"
	# make a "gentoo" profile with "default" one as a template
	cp -rf server/default    server/gentoo
	# add optionnal jboss EJB 3.0 implementation
	if use ejb3;then
		einfo "EJB 3.0 support  Activation"
		cd "../$MY_EJB3" || die "cd failed"
		cp -rf "${FILESDIR}/${PV}/ejb3/install.xml" . || die "cp failed"
		JBOSS_HOME="../${MY_P}" ant -f install.xml || die "EJB3 Patch failed"
		einfo "EJB3 installed"
		cd "../${MY_P}" || die "cd failed"
		local backported_jars="jgroups.jar jboss-cache.jar"
		for jar in ${backported_jars};do
			cp -rf "server/all/lib/${jar}"    server/gentoo/lib || die "cp failed"
		done
		local backported_apps="jbossws.sar"
		for app in ${backported_apps};do
			cp -rf "server/all/deploy/${app}"    server/gentoo/deploy || die "cp failed"
		done
	fi
	# our nice little welcome app
	cp -rf "${FILESDIR}/${PV}/tomcat/webapp/gentoo" . || die "cp failed"
	cd gentoo || die "cd failed"
	#for /gentoo-doc context
	jar cf ../gentoo.war * || die "jar failed"
	# for root context
	rm -f WEB-INF/jboss-web.xml || die "rm failed"
	jar cf ../ROOT.war * || die "jar failed"
	cd .. || die "cd failed"
	# installing the tomcat configuration and the webapp
	for PROFILE in all default gentoo ; do
		rm -rf "server/${PROFILE}/deploy/jbossweb-tomcat55.sar/ROOT.war" || die "rm failed"
		cp -rf gentoo.war "server/${PROFILE}/deploy/" || die "cp failed"
		cp -rf ROOT.war    "server/${PROFILE}/deploy/jbossweb-tomcat55.sar/" || die "cp failed"
		# our tomcat configuration to point to our helper
		cp -rf "${FILESDIR}/${PV}/tomcat/server.xml" \
			"server/${PROFILE}/deploy/jbossweb-tomcat55.sar/server.xml"\
			|| die "cp failed"
	done
	rm -f gentoo.war ROOT.war || die "rm failed"
		# installing profiles
	for PROFILE in all default gentoo minimal; do
		# create directory
		diropts -m775
		dodir "${SERVICES_DIR}/${PROFILE}/conf"   \
		      "${SERVICES_DIR}/${PROFILE}/deploy" \
			  "${SERVICES_DIR}/${PROFILE}/lib"
		# keep stuff
		keepdir     "${CACHE_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}" \
					"${CONF_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"  \
					"${LOG_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"	 \
					"${TMP_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"   \
					"${RUN_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"
		if [[ ${PROFILE} != "minimal" ]]; then
			insopts -m665
			diropts -m775
			insinto  "${SERVICES_DIR}/${PROFILE}/deploy"
			doins -r server/${PROFILE}/deploy/*
		else
			dodir  "${SERVICES_DIR}/${DEFAULT_VHOST}/${PROFILE}/deploy"
		fi
		# singleton is just on "all" profile
		local clustering="false"
		[[ ${PROFILE} == "all" ]] && clustering="true"
		# deploy clustering stuff for ejb3
		use "ejb3" && [[ ${PROFILE} == "gentoo" ]] && clustering="true"
		if [[ $clustering == "true" ]];then
			ewarn "Activating clustering support for profile: ${PROFILE}"
			insopts -m665
			diropts -m775
			dodir    "${SERVICES_DIR}/${PROFILE}/deploy-hasingleton"
			insinto  "${SERVICES_DIR}/${PROFILE}/deploy-hasingleton"
			doins -r server/all/deploy-hasingleton
			dodir    "${SERVICES_DIR}/${PROFILE}/farm"
			insinto  "${SERVICES_DIR}/${PROFILE}/farm"
			doins -r server/all/farm
		fi
		# copy files
		insopts -m664
		diropts -m772
		insinto  "${SERVICES_DIR}/${PROFILE}/conf"
		doins -r server/${PROFILE}/conf/*
		insopts -m644
		diropts -m755
		insinto  "${SERVICES_DIR}/${PROFILE}/lib"
		doins -r server/${PROFILE}/lib/*
		# do symlink
		dosym "${CACHE_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}" \
				"${SERVICES_DIR}/${PROFILE}/data"
		dosym  "${LOG_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"  \
				"${SERVICES_DIR}/${PROFILE}/log"
		dosym  "${TMP_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"  \
				"${SERVICES_DIR}/${PROFILE}/tmp"
		dosym  "${RUN_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"  \
				"${SERVICES_DIR}/${PROFILE}/work"
		# for conf file, doing the contrary is trickier
		# keeping the conf file with the whole installation but
		# putting a symlink to /etc/ for easy configuration
		dosym "${SERVICES_DIR}/${PROFILE}/conf"\
				"${CONF_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}/conf"
		# symlink the tomcat server.xml configuration file
		dosym "${SERVICES_DIR}/${PROFILE}/deploy/jbossweb-tomcat55.sar/server.xml" \
				"${CONF_INSTALL_DIR}/${DEFAULT_VHOST}/${PROFILE}"
	done

	# set some cp
	if use ejb3;then
		java-pkg_regjar "${D}/${INSTALL_DIR}/client/activation.jar"
		java-pkg_regjar "${D}/${SERVICES_DIR}/all/lib/jboss-cache.jar"
		java-pkg_regjar "${D}/${SERVICES_DIR}/all/lib/jgroups.jar"
	fi
	# register runners
	java-pkg_regjar	${D}/${INSTALL_DIR}/bin/*.jar
	#do launch helper scripts which set the good VM to use
	java-pkg_dolauncher jboss-start.sh  --java_args  '${JAVA_OPTIONS}'\
		--main org.jboss.Main      -into "${INSTALL_DIR}"
	java-pkg_dolauncher jboss-stop.sh   --java_args  '${JAVA_OPTIONS}'\
		--main org.jboss.Shutdown  -into "${INSTALL_DIR}"

	# documentation stuff
	insopts -m645
	diropts -m755
	insinto	"/usr/share/doc/${PF}/${DOCDESTTREE}"
	doins copyright.txt
	doins -r docs/*
	# write access is set for jboss group so user can use netbeans to start jboss
	}



pkg_postinst() {
	# fix permissions
	local DIR="" srvdir=""
	use srvdir 	&& srvdir="${SERVICES_DIR}" \
				|| srvdir="${SERVICES_BASE_DIR}"
	# NOTE: installing in "PN-SL/localhos"t , .. mean set for "PN-SL/"
	DIR="/${INSTALL_DIR} /${LOG_INSTALL_DIR} /${TMP_INSTALL_DIR}"
	DIR="${DIR} /${CACHE_INSTALL_DIR} /${RUN_INSTALL_DIR}"
	DIR="${DIR} /${CONF_INSTALL_DIR} /${srvdir}"
	chmod -R 755 "/usr/share/${PN}-${SLOT}" || die chmod failed
	chmod -R 765 ${DIR} || die "chmod  failed"
	chown -R jboss:jboss ${DIR} || die "chown failed"

	elog
	elog "Multi Instance Usage"
	elog " If you want to run multiple instances of JBoss, you can do that this way:"
	elog " 1) Symlink init script:"
	elog "    ln -s /etc/init.d/${PN}-${SLOT} /etc/init.d/${PN}-${SLOT}.foo"
	elog " 2) Copy original config file:"
	elog "    cp /etc/conf.d/${PN}-${SLOT} /etc/conf.d/${PN}-${SLOT}.foo"
	elog " 3) Edit the new config file as it will use another JBOSS_SERVER_NAME."
	elog "		Set what do you want to run your new profile/vhost"
	elog "		You have to either:"
	elog "			Bind new JBoss instance to another IP address or change"
	elog "			Change the  used ports in tiomcat configuration so they do not be in conflict)"
	elog " 4) Run the new JBoss instance:"
	elog "		/etc/init.d/${PN}-${SLOT}.vhost start (eg vhost=localhost"
	elog "		-> ${PN}-${SLOT}.localhost"
	elog
	elog "Profile manager:"
	elog "We provide now a tool to manage your multiple JBoss profiles"
	elog "	see jboss-profiles-creator.sh --help for usage"
	elog
	elog "Jboss usage:"
	elog "We profile a jboss documentation available for all vhosts"
	elog "	you can access it with"
	elog "	/etc/init.d/${PN}-${SLOT}.localhost start"
	elog "	and now point your browser to http://YOURIP:8080/gentoo-doc"
	elog "	TIPS: "
	elog "		* If you have not redefine the root context, You can even reach it to http://YOURIP:8080/"
	elog
	elog "To redifine the root context: (the thing you reach with http://vhost/)"
	elog "	* Just deploy your one as PROFILE_PATH/deploy/ROOT.war"
	elog "	* To make a war go to the basedir of your application and do "
	elog "			jar cvf ROOT.war *"
	elog "	* Another thing: you can eITher deploy it in a ear or in a war"
}
