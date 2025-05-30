#!/bin/bash

CONFIG_FILE="/home/container/DNL/Saved/Config/WindowsServer/GameUserSettings.ini"
DEFAULT_FILE="/home/container/DNL/Config/DefaultGameUserSettings.ini"

# Prüfe ob MOD_LIST gesetzt ist
if [ -z "$MOD_LIST" ]; then
    echo "❌ MOD_LIST ist leer – breche ab."
    exit 1
fi

# 📁 Wenn Datei nicht existiert → kopieren aus Default
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📄 $CONFIG_FILE nicht gefunden – kopiere DefaultGameUserSettings.ini ..."
    
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp "$DEFAULT_FILE" "$CONFIG_FILE"

    if [ $? -ne 0 ]; then
        echo "❌ Fehler beim Kopieren von DefaultGameUserSettings.ini"
        exit 1
    fi
fi

# 🔧 ActiveMods setzen oder ergänzen
if grep -q "^\[ServerSettings\]" "$CONFIG_FILE"; then
    if grep -q "^ActiveMods=" "$CONFIG_FILE"; then
        sed -i "s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/" "$CONFIG_FILE"
        echo "🔁 ActiveMods ersetzt: ${MOD_LIST}"
    else
        sed -i "/^\[ServerSettings\]/a ActiveMods=${MOD_LIST}" "$CONFIG_FILE"
        echo "➕ ActiveMods eingefügt: ${MOD_LIST}"
    fi
else
    echo -e "\n[ServerSettings]\nActiveMods=${MOD_LIST}" >> "$CONFIG_FILE"
    echo "📎 Block + ActiveMods angehängt."
fi
