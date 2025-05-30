#!/bin/bash

CONFIG_FILE="/home/container/DNL/Saved/Config/WindowsServer/GameUserSettings.ini"
DEFAULT_FILE="/home/container/DNL/Config/DefaultGameUserSettings.ini"

# Prüfe ob MOD_LIST gesetzt ist
if [ -z "$MOD_LIST" ]; then
    echo "❌ MOD_LIST ist leer – breche ab."
    exit 1
fi

# 📁 Wenn Datei nicht existiert → kopiere DefaultGameUserSettings.ini
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📄 $CONFIG_FILE nicht gefunden – kopiere Default ..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp "$DEFAULT_FILE" "$CONFIG_FILE"

    if [ $? -ne 0 ]; then
        echo "❌ Fehler beim Kopieren von DefaultGameUserSettings.ini"
        exit 1
    fi
fi

# 🔧 ActiveMods & weitere Einstellungen einfügen oder ersetzen
if grep -q "^\[ServerSettings\]" "$CONFIG_FILE"; then
    echo "📌 ServerSettings-Block vorhanden – passe Einträge an ..."

    # ActiveMods ersetzen oder einfügen
    if grep -q "^ActiveMods=" "$CONFIG_FILE"; then
        sed -i "s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/" "$CONFIG_FILE"
    else
        sed -i "/^\[ServerSettings\]/a ActiveMods=${MOD_LIST}" "$CONFIG_FILE"
    fi

    # Die restlichen Einstellungen einfügen, wenn sie fehlen
    declare -A settings=(
        ["NoTributeDownloads"]="False"
        ["AllowDownloadSurvivors"]="True"
        ["AllowDownloadItems"]="True"
        ["AllowDownloadDinos"]="True"
        ["AllowUploadSurvivors"]="True"
        ["AllowUploadItems"]="True"
        ["AllowUploadDinos"]="True"
    )

    for key in "${!settings[@]}"; do
        if ! grep -q "^${key}=" "$CONFIG_FILE"; then
            sed -i "/^\[ServerSettings\]/a ${key}=${settings[$key]}" "$CONFIG_FILE"
            echo "➕ ${key}=${settings[$key]} eingefügt"
        fi
    done

    echo "✅ ServerSettings angepasst."
else
    echo "⚠️  Kein [ServerSettings]-Block gefunden – füge neuen Block hinzu ..."

    {
        echo ""
        echo "[ServerSettings]"
        echo "ActiveMods=${MOD_LIST}"
        echo "NoTributeDownloads=False"
        echo "AllowDownloadSurvivors=True"
        echo "AllowDownloadItems=True"
        echo "AllowDownloadDinos=True"
        echo "AllowUploadSurvivors=True"
        echo "AllowUploadItems=True"
        echo "AllowUploadDinos=True"
    } >> "$CONFIG_FILE"

    echo "✅ ServerSettings-Block am Ende hinzugefügt."
fi
