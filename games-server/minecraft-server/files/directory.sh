
if [[ -z "$1" ]]; then
	NAME="main"
	echo "Multiverse name not specified. Defaulting to \"${NAME}\"." >&2
else
	NAME="$1"
	echo "Using multiverse name \"${NAME}\"." >&2
fi

if [[ "$(whoami)" == "@GAMES_USER_DED@" ]]; then
	gjl_pwd="/var/lib/minecraft/${NAME}"
else
	gjl_pwd="${HOME}/.minecraft/servers/${NAME}"
fi

echo "Multiverse directory is ${gjl_pwd}." >&2
mkdir -p "${gjl_pwd}"

if [[ -f "${gjl_pwd}/server.properties" ]]; then
	level_name=$(sed -n "s/^level-name=//p" "${gjl_pwd}/server.properties")

	for D in "nether -1" "the_end 1"; do
		TYPE="${D% *}"
		DIM="DIM${D#* }"

		if [[ -d "${gjl_pwd}/${level_name}" ]] && [[ -d "${gjl_pwd}/${level_name}_${TYPE}/${DIM}" ]]; then
			if [[ -d "${gjl_pwd}/${level_name}/${DIM}" ]] && [[ ! -L "${gjl_pwd}/${level_name}/${DIM}" ]]; then
				echo "CraftBukkit ${TYPE} detected but a conflicting ${TYPE} is already present! Ignoring." >&2
			else
				echo "CraftBukkit ${TYPE} detected. Symlinking for the official server." >&2
				ln -snf "../${level_name}_${TYPE}/${DIM}" "${gjl_pwd}/${level_name}/${DIM}"
			fi
		fi
	done
fi

