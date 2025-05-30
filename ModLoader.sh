#!/bin/bash

MODS_DIR="/home/container/DNL/Content/Mods"
WORKSHOP_DIR="/home/container/workshop/content/630230"
STEAMCMD_PATH="/home/container/steamcmd/steamcmd.sh"

echo "🎮 Starte ModLoader ..."

# Prüfe MOD_LIST
if [ -z "$MOD_LIST" ]; then
    echo "⚠️  Keine MOD_LIST gesetzt – ModLoader wird übersprungen."
    exit 0
fi

# Zielverzeichnis erstellen
mkdir -p "$MODS_DIR"

# Mod-IDs extrahieren
IFS=',' read -ra MOD_IDS <<< "$MOD_LIST"

for mod_id in "${MOD_IDS[@]}"; do
    echo "⬇️  Lade Mod $mod_id herunter ..."

    $STEAMCMD_PATH +login anonymous \
        +workshop_download_item 630230 "$mod_id" \
        +quit

    # Prüfe, ob Mod erfolgreich geladen wurde
    if [ -d "$WORKSHOP_DIR/$mod_id" ]; then
        echo "📦 Mod $mod_id gefunden – kopiere nach $MODS_DIR ..."
        cp -r "$WORKSHOP_DIR/$mod_id" "$MODS_DIR/$mod_id"
    else
        echo "❌ Mod $mod_id nicht gefunden – wurde evtl. nicht korrekt geladen."
    fi
done

echo "✅ Alle Mods verarbeitet."
