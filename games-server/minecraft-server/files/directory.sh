
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

	if [[ -d "${gjl_pwd}/${level_name}" ]] && [[ -d "${gjl_pwd}/${level_name}_nether/DIM-1" ]]; then
		if [[ -d "${gjl_pwd}/${level_name}/DIM-1" ]] && [[ ! -L "${gjl_pwd}/${level_name}/DIM-1" ]]; then
			echo "CraftBukkit nether detected but a conflicting nether is already present! Ignoring." >&2
		else
			echo "CraftBukkit nether detected. Symlinking for the official server." >&2
			ln -snf "../${level_name}_nether/DIM-1" "${gjl_pwd}/${level_name}/DIM-1"
		fi
	fi
fi

