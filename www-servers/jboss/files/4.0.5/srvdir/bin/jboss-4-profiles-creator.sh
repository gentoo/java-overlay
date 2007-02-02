#!/bin/sh
#License: GPL2
#author: kiorky kiorky@cryptelium.net
PATH="${PATH}:/usr/lib/portage/bin"
source /etc/init.d/functions.sh

debug="false"

JBOSS_VERSION="jboss-4"
jboss_path="/opt/${JBOSS_VERSION}"

action="help"

# defaults
srvdir="/srv"
default_vhost="localhost"
default_path="${srvdir}/${default_vhost}/${JBOSS_VERSION}"
default_vhost_path="${srvdir}/${default_vhost}/${JBOSS_VERSION}"
default_profile="${default_vhost_path}/gentoo"
# initialize stuff
profile="${default_profile}" 
vhost="${default_vhost}"
path="${default_path}"
vhost_path="${default_vhost_path}"
name="${default_profile}"

CONFDIR="/etc/${JBOSS_VERSION}"
TMPDIR="/var/tmp/${JBOSS_VERSION}"
CACHEDIR="/var/cache/${JBOSS_VERSION}"
RUNDIR="/var/run/${JBOSS_VERSION}"
LOGDIR="/var/log/${JBOSS_VERSION}"

forbidden_to_install_in="/ /bin /include /lib /sbin /usr/bin /usr/include /usr/lib /usr/sbin"
XARGS="/usr/bin/xargs"

# error management
# usage: do_error "theerror" ARGS
# read the code as it is enought explicit to use
# some errors can take arguments !!
do_error(){
	eerror
	case $1 in
		"profile_creation_forbidden")
			eerror "Please specify another location"
			eerror "	Creating profiles in \"$2\" is forbidden !!!"
			;;
		"profile_file_exists")
			eerror "Profile is even created  ?"
			eerror "	File \"$3\" exists in \"$2\" directory"
			;;		
		"path_invalid_path")
			eerror "Invalid path: $HILITE  $2"
			;;
		"profile_invalid_subdir")
			eerror "Invalid profile"					
			eerror "    Invalid JBOSS Servers subdir: $HILITE $2"
			;;
		"profile_invalid_full_path")
			eerror "Invalid profile"
			eerror "    Invalid full_path: $HILITE $2"
			;;
		"argument_invalid_args")
			eerror " You must specify --KEY=VALUE for your arguments"
			;;
		"profile_invalid_profile")
			eerror "Profile is invalid"
			eerror "     subdir for this profile is missing: $HILITE $2"
			;;
		"path_no_path_given")
			eerror "Please specify where you want to install your profile"
			;;
		"argument_no_arg")
			eerror "Please give Arguments"
			;;		
		"action_create_cant_create_dir")
			eerror "Can't create profile directory"
			exit -1
			;;
		"action_help")
			eerror "Help wanted ?"
			eerror;usage;exit
			;;
		"profile_file_exists")
			eerror "Profile  exists: $HILITE $2"
			;;
		"delete_no_profile")
			eerror "Invalid profile to delete: $HILITE $2"			
			;;
		"path_invalid_scope")
			error "--path argument is invalid in this scope: $HILITE $2"
			;;
		"vhost_invalid_vhost")
			eerror "Please specify a valid vhost"
			eerror "	Vhost given: $2"
			;;
		"path_not_exists")
			eerror "Please specify a valid final path"
			eerror "	Final profile path doest not exist: $HILITE $2" 
			;;
		*)
			eerror 
			usage
			exit # not error there !!!
	esac
	eerror "Please run for help:"
	eerror "	$HILITE$0 help"
	exit -1
}


# print usage 
usage(){
	einfo
	einfo "$BRACKET Usage: "
	einfo "$HILITE JBoss profile Manager"
	einfo
	einfo
	einfo "$BRACKET $0: action [ACTION_OPTIONS]"
	einfo "valid options are:"
	einfo "$HILITE	delete"
	einfo "		* Delete a profile"
	einfo "		* You can get profiles with list"
	einfo "$HILITE	list"
	einfo "		* List actual profiles"
	einfo "$HILITE 	create"
	einfo "		* Create a new profile"
	einfo "$HILITE	h"
	einfo "$HILITE	help"
	einfo "		* print this helper"
	einfo
	einfo "Valid arguments are:"
	einfo "$HILITE	--profile=serverdir_template"
	einfo "		* the name of the template to use to create the new profile with --create"
	einfo "		* the name of the profile to delete with --delete"
	einfo "		Default is 'gentoo'"
	einfo "$HILITE	--path=/path/to/profile_to_create      SCOPE:create"
	einfo "		* don't use the leading / for a subdir of ${INSTALL_DIR}/server"		  
	einfo "		* indicate the full location to other wanted location"
	einfo "$HILITE	--vhost=VHOST"
	einfo "		* Set the vhost (default is 'localhost')"
	einfo "		* Must exist a valid /srv/VHOST subdir"
	einfo 
	einfo "$BRACKET TIPS:"
	einfo "	For create and delete, you must give the profile's name"
	einfo
	einfo "$BRACKET Examples"
	einfo "	$0 create --profile=gentoo --path=/opt/newprofile"
	einfo "		A new profile will be created in /opt/newprofile using default_vhost/gentoo as a template"
	einfo "		A symlick in /srvdir/defaultvhost/jbossversion/newprofile will be done"
	einfo "	$0 create --profile=gentoo --path=newprofile"
	einfo "		A new profile will be created in default vhost using srvdir/defaultvhost/jbossversion/igentoo as a template"
	einfo "	$0 --delete  --profile=gentoo"
	einfo "		the 'gentoo' profile in default vhost will be deleted"
	einfo
}

# list actual profiles
# $1:vhost
# $2:vhost path
list_profiles() {
	vhost=$1
	vhost_path=$2
	if [[ $debug == "true" ]];then
		einfo "list_profiles: vhost: $vhost"
		einfo "list_profiles: vhost_path: $vhost_path"
	fi
	einfo "Installed profiles in ${vhost} :"
	for i in  $(ls -d ${vhost_path}/* ) ;do
		if [[ -L "$i" ]];then
			einfo "$HILITE $(echo $i|sed -re "s:$vhost_path/*::g")"
 			einfo "		Server subdir:		$i"
			einfo "		Real path: 		$(ls -dl "$i" | awk -F " " '{print $11 }')"
		else
			einfo "$HILITE $i"
		fi
	done;
}


# verify if the vhost direcotry is created
# exit and display error on failure
# $1: vhost to verify
verify_vhost(){
	if [[ -d ${srvdir}/$1 ]];then
		vhost="$1"
		vhost_path="${srvdir}/$1/${JBOSS_VERSION}"	
	else
		do_error "vhost_invalid_vhost" $1
	fi
	[[ ${debug} == "true" ]] && einfo "verify_vhost:  vhost     : $vhost"\
				 && einfo "verify_vhost:  vhost_path: $vhost_path"
}

# verify if this path (for creation) is valid
# set the  adequat variables
# exit on fails with error display
# $1: the path to verify
verify_path(){
	local value=$1
	if [[ ${action} == "create" ]];then
		local l_name
		# remove final slash if one
		value=$(echo ${value}|sed -re "s/(\/*[^\/]+)\/*$/\1/")
		# is there a profile or a full path
		if [[ ${value:0:2} == "./" ]];then				
			# if relative getting full
			value="$(pwd|sed -re "s:(.*)/*$:\1/:")$(echo ${value}|sed -re "s:\./::g")"
		fi
		if [[ ${value:0:1} == "/" ]];then
			is_subdir=0
		else				
			# if profile, verify that s the name doesnt contains any other path
			[[ $(echo ${value}|grep "/" |grep -v grep|wc -l  ) -gt 0 ]] \
				&& do_error "profile_invalid_subdir" ${value}
			value=${vhost_path}/${value}
			is_subdir=1
		fi
		for forbidden in ${forbidden_to_install_in};do
			if [[ $(echo ${value}|sed -re "s:^($forbidden):STOP:") == "STOP" ]];then
				do_error "profile_creation_forbidden" ${forbidden}
			fi
		done
		# if final directory is even created
		# we control that we do not overwrite an existing profile
		if [[ -d ${value} || -L ${value}  ]];then
			for i in conf data lib run tmp deploy;do		
				[[ -e ${value}/$i ]] && do_error "profile_file_exists" "${value}" "$i"
			done
		fi
		#if fullpath, check that the name  doesnt exists
		name="$(echo ${value}|sed -re "s:(.*/)([^/]*)($):\2:")"
		[[ -e ${default_path}/${name} ]] && do_error "profile_file_exists" ${name}
		# clean variables
		# remove final slash if one
		path="${value}"
		path=$(echo ${path}|sed -re "s/\/*$//")

	else
		do_error "path_invalid_scope" ${action}
	fi
	if [[ ${debug} == "true" ]];then
		einfo "verify_path: path: $path"
		einfo "verify_path: name: $name"
		[[ ${is_subdir} != "1" ]] && einfo "verify_path: symlick in: ${vhost_path}/${name}"
	fi
}

# verfiry a jboss profile
# $1 : profile name
# exit and print usage if profile is invalid 
# continue either
verify_profile() {
	local value=$1
	if [[ ${value:0:1} == "/" || ${value:0:2} == "./"  ]];then	
		#full or relative path is given
		if [[  -e   ${value} ]]; then
			profile="${value}"
		else
			do_error "profile_invalid_full_path" ${value}
		fi					
	# subdir given
	elif [[ -e  ${vhost_path}/${value} ]];then
		profile="${vhost_path}/$value"				
	else
		do_error "profile_invalid_subdir" ${value}
	fi
	for i in conf lib deploy;do
		if [[ ! -e ${profile}/$i ]];then
			do_error "profile_invalid_profile" $i
		fi
	done
	# clean variables
	# remove final slash if one	
	profile=$(echo ${profile}|sed -re "s/\/*$//")

	[[ ${debug} == "true" ]] && einfo "verify_profile:  profile: $profile"
}

# adds ".keep" files so that dirs aren't auto-cleaned
keepdir() {
        mkdir -p "$@"
        local x
        if [ "$1" == "-R" ] || [ "$1" == "-r" ]; then
                shift
                find "$@" -type d -printf "%p/.keep_www-server_jboss_4\n" |\
			 tr "\n" "\0" | $XARGS -0 -n100 touch ||\
			 die "Failed to recursive create .keep files"
        else
                for x in "$@"; do
                        touch "${x}/.keep_www-server_jboss_4" ||\
				die "Failed to create .keep in ${D}/${x}"
                done
        fi
}

# parse command lines arguments
parse_cmdline() {
	local arg value 
	# parse and validate arguments
        for param in  ${@};do               
		case ${param} in
			"-v"|"-verbose"|"--v")
				debug="true"
#				echo "Setting verbose to true: $debug" 
				;;
			*)
				if [[ $(echo ${param} | sed -re "s/--.*=..*/GOOD/g" ) != "GOOD" ]]; then
					do_error "argument_invalid_args"
				fi
				arg=$(echo ${param} | sed -re "s/(--)(.*)(=.*)/\2/g")
				value=$(echo ${param} | sed -re "s/(.*=)(.*)/\2/g")
				case "$arg" in			
				    "profile")
					profile=${value}
					;;
				    "path")		    	
					path=${value}
					;;           
				    "vhost")
					vhost=${value}
					;;
				esac
			;;
		esac
	done

}

# delete a profile
# $1: profile name
# $2: vhost to use
# $3: vhost path
delete_profile(){   
	profile=$1 
	vhost=$2
	vhost_path=$3
	# contructing path to delete
	path="${vhost_path}/${profile}"
	local l_profile="${vhost}/${profile}"
	if [[ $debug == "true" ]];then
		einfo "delete_profile: profile: $profile"
		einfo "delete_profile: vhost: $vhost"
		einfo "delete_profile: vhost_path: $vhost_path"
		einfo "delete_profile: path: $path"
		einfo "delete_profile: l_profile: $l_profile"
	fi
	# if symlick getting real path
	if [[ -L ${path} ]];then
		path="$(ls -dl "${path}" | awk -F " " '{print $11 }')"
	# else nothing
	elif [[ -d ${path} ]];then
		echo>>/dev/null
	# if not a symlick or a direcotry, something weird, we exit !
	else
		do_error "delete_no_profile" $profile
	fi

	ewarn "Deleting profile: $HILITE ${profile}"
	ewarn "In vhost: $HILITE ${vhost}"
	ewarn "Path: $HILITE ${path}"
	print_yes_no
	# delete if symlick
	[[ -L ${vhost_path}/${name} ]] && echo	rm -rf ${default_path}/${name}

	# delete run files
	rm -rf   ${TMPDIR}/${l_profile}\
                 ${CACHEDIR}/${l_profile}\
                 ${RUNDIR}/${l_profile}\
                 ${LOGDIR}/${l_profile}\
	         ${CONFDIR}/${l_profile}\
	 	 ${path} \
		 ${CONFDIR}/${l_profile}
}


# create the profile
# $1: vhost to install into
# $2: profile
# $3: path to install
# $4: name of this profile
# $5: subdir of jboss if 1 / full path if 0
create_profile(){   
	vhost=$1;profile=$2;path=$3;name=$4;is_subdir=$5
	local l_profile="${vhost}/${name}"

	# if default arguments are given
 	if [[ ${path} == "${default_path}" ]];then
		do_error "path_no_path_given" 
	fi

	ewarn "Creating profile in ${path}"
	ewarn "Using ${profile} profile"

	# do base direcotries
	keepdir  ${TMPDIR}/${l_profile}\
                 ${CACHEDIR}/${l_profile}\
                 ${RUNDIR}/${l_profile}\
                 ${LOGDIR}/${l_profile}\
	         ${CONFDIR}/${l_profile}

	# create directory
	mkdir -p ${path} ||  do_error "action_create_cant_create_dir"

 	# copy profile
	for i in  conf deploy lib;do
		cp -rf ${profile}/$i ${path}/ 
	done

	# do runtime files stuff
	ln -s ${LOGDIR}/${l_profile}     ${path}/logs
	ln -s ${CACHEDIR}/${l_profile}   ${path}/data
	ln -s ${TMPDIR}/${l_profile}     ${path}/tmp
	ln -s ${RUNDIR}/${l_profile}     ${path}/run

	# do /etc stuff
	ln -s ${path}/conf       ${CONFDIR}/${l_profile}/conf
	ln -s ${path}/deploy/jbossweb-tomcat55.sar/server.xml ${CONFDIR}/${l_profile}

	# if we don't create in jboss directory, link the profile in jboss servers dir
	[[ is_subdir -eq 0 ]] && ln -s ${path} ${vhost_path}/${name}

	# fix perms
	for i in ${TMPDIR}/${l_profile}   ${CACHEDIR}/${l_profile} \
		 ${RUNDIR}/${l_profile}   ${LOGDIR}/${l_profile}   \
		 ${CONFDIR}/${l_profile}  ${CONFDIR}/${l_profile}  \
		 ${path};do
		chmod -Rf 755 $i;
		chown -R jboss:jboss $i;
	done
}
        
# print collected informations
# $1: subdir of jboss if 1 / full path if 0
confirm_creation() {
	ewarn "Jboss profile manager for : $HILITE ${name}"
	if [[ $1 -eq 0 ]];then		
		WHERE="directory"
	else
		WHERE="vhost subdir"
	fi
	ewarn "Installing  in ${WHERE}:"
	ewarn "		$HILITE${path} "
	ewarn "Using profile: "
	ewarn "		$HILITE${profile} "

}

# print a yes_no like form
# exit on failure / no
# continue if yes
print_yes_no(){
	local i nb nok="nok";
	while [[ nok == "nok" ]];do
		[[ $nb -gt 12 ]] && eerror "Invalid arguments" && exit -1
		[[ $nb -gt 10 ]] && ewarn "Please Enter CTRL-C to exit "\
				 && ewarn " or \"Y\" to say YES"\
				 && ewarn " or \"N\" to say NO"
		ewarn " Is that Correct (Y/N) ???"
		read i;
		[[ $i == "Y" || $i == "y" ]] && break
		[[ $i == "N" || $i == "n" ]] && einfo "User wanted interrupt" && exit
		nb=$((nb+1))
	done
}

main(){
	local args="$2 $3 $4 $5 $6"
	action="$1"
	# if no args are given
	if [[ $# -lt 1 ]];then
		do_error "argument_no_arg"
	fi	
	case ${action} in
		create)
			parse_cmdline ${args}
			verify_vhost ${vhost}
			verify_path ${path}
			verify_profile ${profile}
			confirm_creation ${is_subdir}
			print_yes_no
			create_profile ${vhost} ${profile} ${path} ${name} ${is_subdir}
		;;
		delete)
			parse_cmdline ${args}
			verify_vhost ${vhost}
			delete_profile ${profile} ${vhost} ${vhost_path}
		;;
		list)
			parse_cmdline ${args}
			verify_vhost ${vhost}
			list_profiles ${vhost} ${vhost_path}
		;;
		--help|h|-h|help)
			do_error "action_help"
		;;		
		*)
			usage
		;;
	esac
}
main ${@}
