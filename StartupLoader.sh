#!/bin/bash

MODS_DIR="/home/container/DNL/Content/Mods"
STEAMCMD_PATH="/home/container/steamcmd/steamcmd.sh"
WORKSHOP_DIR="/home/container/.steam/steam/steamapps/workshop/content/529180"
CONFIG_DIR="/home/container/DNL/Saved/Config/WindowsServer"
GAMEUSER_FILE="$CONFIG_DIR/GameUserSettings.ini"
CHEATER_FILE="/home/container/DNL/Saved/AllowedCheaterSteamIDs.txt"
FORCE_UPDATE="${FORCE_UPDATE:-false}"

echo "🎮 Starting Pre-Startup Process ..."

# Download and install mods if MOD_LIST is set
if [ -z "$MOD_LIST" ]; then
    echo "⚠️  No MOD_LIST provided – skipping mod downloads."
else
    mkdir -p "$MODS_DIR"
    IFS=',' read -ra MOD_IDS <<< "$MOD_LIST"
    for mod_id in "${MOD_IDS[@]}"; do
        DEST="$MODS_DIR/$mod_id"
        echo "🔍 Checking Mod $mod_id ..."
        if [ "$FORCE_UPDATE" != "true" ] && [ -d "$DEST" ]; then
            echo "⏭️  Mod $mod_id already exists – skipping."
            continue
        fi
        echo "⬇️  Downloading Mod $mod_id via SteamCMD ..."
        $STEAMCMD_PATH +login anonymous +workshop_download_item 529180 "$mod_id" +quit

        if [ -d "$WORKSHOP_DIR/$mod_id" ]; then
            echo "📦 Moving Mod $mod_id to $DEST ..."
            rm -rf "$DEST"
            cp -r "$WORKSHOP_DIR/$mod_id" "$DEST"
        else
            echo "❌ Failed to download Mod $mod_id – anonymous access might be restricted."
        fi
    done

    if [ -d "$WORKSHOP_DIR" ]; then
        echo "🧹 Cleaning up temporary workshop files ..."
        rm -rf "$WORKSHOP_DIR"
    fi
fi

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
