#!/bin/bash

CONFIG_FILE="/home/container/DNL/Saved/Config/WindowsServer/GameUserSettings.ini"

# Stelle sicher, dass MOD_LIST übergeben wurde
if [ -z "$MOD_LIST" ]; then
    echo "WARNUNG: MOD_LIST ist leer oder nicht gesetzt."
    exit 0
fi

# Falls [ServerSettings] existiert
if grep -q "^\[ServerSettings\]" "$CONFIG_FILE"; then
    # Falls ActiveMods bereits vorhanden ist → ersetzen
    if grep -q "^ActiveMods=" "$CONFIG_FILE"; then
        sed -i "s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/" "$CONFIG_FILE"
    else
        # ActiveMods nach [ServerSettings] einfügen
        sed -i "/^\[ServerSettings\]/a ActiveMods=${MOD_LIST}" "$CONFIG_FILE"
    fi
else
    # Block fehlt? Dann anhängen
    echo -e "\n[ServerSettings]\nActiveMods=${MOD_LIST}" >> "$CONFIG_FILE"
fi
