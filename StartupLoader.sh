#!/bin/bash

CONFIG_DIR="/home/container/DNL/Saved/Config/WindowsServer"
GAMEUSER_FILE="$CONFIG_DIR/GameUserSettings.ini"
CHEATER_FILE="/home/container/DNL/Saved/AllowedCheaterSteamIDs.txt"
HANDSHAKE_FILE="${CLUSTER_DIR_OVERRIDE}/connectiontest.txt"

# Check cluster directory
echo "📁 Checking cluster directory: ${CLUSTER_DIR_OVERRIDE}"

# Write test
echo "cluster_write_test" > "${CLUSTER_DIR_OVERRIDE}/.write_test" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "\033[0;31m❌ [StartupLoader] No write permissions in cluster directory: ${CLUSTER_DIR_OVERRIDE}\033[0m"

    echo "📋 Diagnostic information:"
    echo -n "📎 Container user: " && id
    echo -n "📎 Cluster directory permissions: " && ls -ld "${CLUSTER_DIR_OVERRIDE}"

    CONTAINER_UID=$(id -u)
    CONTAINER_GID=$(id -g)

    echo -e "\n🛠 \033[1;33mSOLUTION (please run this on the host system):\033[0m"
    echo "👉 This will grant the container user write access to the cluster directory:"
    echo -e "\n\033[1;32msudo chown -R ${CONTAINER_UID}:${CONTAINER_GID} /path/to/cluster\033[0m"
    echo -e "\033[1;32msudo chmod -R 775 /path/to/cluster\033[0m"
    echo -e "\n📎 Replace \033[1;36m/path/to/cluster\033[0m with the actual host directory path (e.g. /mnt/dnl_cluster)."

    echo -e "\n❓ If you're unsure, copy this output and ask your host admin or support team."
else
    echo -e "\033[0;32m✅ [StartupLoader] Cluster directory is writable: ${CLUSTER_DIR_OVERRIDE}\033[0m"
    rm -f "${CLUSTER_DIR_OVERRIDE}/.write_test"

    # Handshake file logic


    if [ -f "$HANDSHAKE_FILE" ]; then
        echo -e "\033[0;36m🔗 [StartupLoader] Transfer link detected: handshake file already exists.\033[0m"
        echo -e "\033[0;36m🧹 [StartupLoader] Cleaning up handshake file...\033[0m"
        rm -f "$HANDSHAKE_FILE"
    else
        echo -e "\033[0;33m🆕 [StartupLoader] No handshake file found – creating new transfer test.\033[0m"
        echo "Connection check by server at $(date)" > "$HANDSHAKE_FILE"
    fi
fi

echo "🎮 Starting Pre-Startup Process ..."

# Write or update GameUserSettings.ini
echo "✏️  Updating GameUserSettings.ini with environment values ..."
sed -i "/^\[SessionSettings\]/,/^\[/{s/^SessionName=.*/SessionName=${SESSION_NAME}/;s/^Port=.*/Port=${SERVER_PORT}/;s/^QueryPort=.*/QueryPort=${QUERY_PORT}/}" "$GAMEUSER_FILE"
sed -i "/^\[ServerSettings\]/,/^\[/{s/^ServerPassword=.*/ServerPassword=${DNL_PASSWORD}/;s/^ServerAdminPassword=.*/ServerAdminPassword=${DNL_ADMIN_PASSWORD}/;s/^RCONEnabled=.*/RCONEnabled=${RCON_ENABLED}/;s/^RCONPort=.*/RCONPort=${RCON_PORT}/;s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/}" "$GAMEUSER_FILE"
sed -i "/^\[\/Script\/Engine.GameSession\]/,/^\[/{s/^MaxPlayers=.*/MaxPlayers=${MAX_PLAYERS}/}" "$GAMEUSER_FILE"
sed -i "/^\[MessageOfTheDay\]/,/^\[/{s/^Message=.*/Message=\"${MESSAGE_OF_THE_DAY}\"/}" "$GAMEUSER_FILE"



# Remove old file if it exists
rm -f "$CHEATER_FILE"

# Check if ADMIN_IDS is set
if [ -n "$ADMIN_IDS" ]; then
    IFS=',' read -ra ADMIN_ID_ARRAY <<< "$ADMIN_IDS"
    for id in "${ADMIN_ID_ARRAY[@]}"; do
        echo "$id" >> "$CHEATER_FILE"
    done
    echo "✅ AllowedCheaterSteamIDs.txt created with ${#ADMIN_ID_ARRAY[@]} admin ID(s)."
else
    echo "⚠️  No ADMIN_IDS provided – file will remain empty."
fi


echo "✅ Pre-Startup Process completed successfully."
