#!/bin/bash

CONFIG_FILE="/home/container/DNL/Saved/Config/WindowsServer/GameUserSettings.ini"
DEFAULT_FILE="/home/container/DNL/Config/DefaultGameUserSettings.ini"

# Abhängige Einstellungen
declare -A settings_to_check=(
    ["NoTributeDownloads"]="False"
    ["AllowDownloadSurvivors"]="True"
    ["AllowDownloadItems"]="True"
    ["AllowDownloadDinos"]="True"
    ["AllowUploadSurvivors"]="True"
    ["AllowUploadItems"]="True"
    ["AllowUploadDinos"]="True"
)

# 1. Prüfe MOD_LIST
if [ -z "$MOD_LIST" ]; then
    echo "❌ MOD_LIST ist leer – Skript wird abgebrochen."
    exit 1
fi

# 2. Wenn .ini nicht existiert → kopiere Default-Datei
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📄 $CONFIG_FILE nicht vorhanden – kopiere Default ..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cp "$DEFAULT_FILE" "$CONFIG_FILE" || {
        echo "❌ Fehler beim Kopieren der DefaultGameUserSettings.ini"
        exit 1
    }
fi

# 3. Stelle sicher, dass [ServerSettings] vorhanden ist
if ! grep -q "^\[ServerSettings\]" "$CONFIG_FILE"; then
    echo "⚠️  Kein [ServerSettings]-Block gefunden – anhängen ..."
    echo -e "\n[ServerSettings]" >> "$CONFIG_FILE"
fi

# 4. Alle Einträge prüfen und ggf. setzen/ersetzen
all_settings_correct=true

for key in "${!settings_to_check[@]}"; do
    expected_value="${settings_to_check[$key]}"

    if grep -q "^${key}=" "$CONFIG_FILE"; then
        current_value=$(grep "^${key}=" "$CONFIG_FILE" | head -n 1 | cut -d= -f2)

        if [ "$current_value" != "$expected_value" ]; then
            echo "🔁 Setze ${key}=${expected_value} (war: $current_value)"
            sed -i "s/^${key}=.*/${key}=${expected_value}/" "$CONFIG_FILE"
        else
            echo "✅ ${key}=${expected_value} bereits korrekt"
        fi
    else
        echo "➕ Füge ${key}=${expected_value} in [ServerSettings] ein"
        sed -i "/^\[ServerSettings\]/a ${key}=${expected_value}" "$CONFIG_FILE"
    fi
done

# 5. ActiveMods setzen oder aktualisieren
if grep -q "^ActiveMods=" "$CONFIG_FILE"; then
    sed -i "s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/" "$CONFIG_FILE"
    echo "🔁 ActiveMods ersetzt: ${MOD_LIST}"
else
    sed -i "/^\[ServerSettings\]/a ActiveMods=${MOD_LIST}" "$CONFIG_FILE"
    echo "➕ ActiveMods eingefügt: ${MOD_LIST}"
fi

echo "✅ Konfigurationsanpassung abgeschlossen."
