
# We have patched Minecraft to not download or install its JAR
# libraries but doing the same for the native libraries doesn't seem
# so easy. Instead we create symlinks and make the natives directory
# read-only, which seems to fool it sufficiently.

NATIVES="${HOME}/.minecraft/bin/natives"
mkdir -p "${NATIVES}"
chmod +w "${NATIVES}"

ln -snf /usr/lib/libopenal.so "${NATIVES}"/libopenal.so
ln -snf /usr/lib/jinput/libjinput-linux*.so "${NATIVES}"/libjinput-linux.so
ln -snf /usr/lib/lwjgl-2.7/liblwjgl*.so "${NATIVES}"/liblwjgl.so

ln -snf libopenal.so "${NATIVES}"/libopenal64.so
ln -snf libjinput-linux.so "${NATIVES}"/libjinput-linux64.so
ln -snf liblwjgl.so "${NATIVES}"/liblwjgl64.so

chmod a-w "${NATIVES}"

# Create a dummy lwjgl.jar to fool MCPatcher.
touch "${HOME}/.minecraft/bin/lwjgl.jar"

# Work around the common "invalid server key" bug.
MC_JAR="${HOME}/.minecraft/bin/minecraft.jar"

if [[ -f "${MC_JAR}" ]] && [[ $(md5sum "${MC_JAR}" | head -c32) == "3820d222b95d0b8c520d9596a756a6e6" ]]; then
	echo 'Broken minecraft.jar detected. Working around "invalid server key" bug.' >&2
	jar uMf "${MC_JAR}" -C /usr/share/minecraft abp.class
fi

