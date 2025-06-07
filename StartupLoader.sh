#!/bin/bash

CONFIG_DIR="/home/container/DNL/Saved/Config/WindowsServer"
GAMEUSER_FILE="$CONFIG_DIR/GameUserSettings.ini"
CHEATER_FILE="/home/container/DNL/Saved/AllowedCheaterSteamIDs.txt"
FORCE_UPDATE="${FORCE_UPDATE:-false}"

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
