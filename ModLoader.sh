#!/bin/bash

MODS_DIR="/home/container/DNL/Content/Mods"
STEAMCMD_PATH="/home/container/steamcmd/steamcmd.sh"
WORKSHOP_DIR="/home/container/.steam/steam/steamapps/workshop/content/529180"
FORCE_UPDATE="${FORCE_UPDATE:-false}"  # Standard: false, kann durch Umgebungsvariable aktiviert werden

echo "🎮 Starte ModLoader ..."

# Prüfe MOD_LIST
if [ -z "$MOD_LIST" ]; then
    echo "⚠️  Keine MOD_LIST gesetzt – ModLoader wird beendet."
    exit 0
fi

# Zielverzeichnis vorbereiten
mkdir -p "$MODS_DIR"

# Mod-IDs aufsplitten
IFS=',' read -ra MOD_IDS <<< "$MOD_LIST"

# Durchlaufe alle Mod-IDs
for mod_id in "${MOD_IDS[@]}"; do
    DEST="$MODS_DIR/$mod_id"
    echo "🔍 Prüfe Mod $mod_id ..."

    # Wenn nicht FORCE_UPDATE und Mod bereits im Ziel → überspringen
    if [ "$FORCE_UPDATE" != "true" ] && [ -d "$DEST" ]; then
        echo "⏭️  Mod $mod_id bereits vorhanden – überspringe."
        continue
    fi

    echo "⬇️  Lade Mod $mod_id mit SteamCMD ..."
    $STEAMCMD_PATH +login anonymous \
        +workshop_download_item 529180 "$mod_id" \
        +quit

    # Prüfe ob Download erfolgreich war
    if [ -d "$WORKSHOP_DIR/$mod_id" ]; then
        echo "📦 Übertrage Mod $mod_id nach $DEST ..."
        rm -rf "$DEST"
        cp -r "$WORKSHOP_DIR/$mod_id" "$DEST"
    else
        echo "❌ Fehler beim Download von Mod $mod_id – möglicherweise kein anonymer Zugriff möglich."
    fi
done

# Workshop-Cache löschen
if [ -d "$WORKSHOP_DIR" ]; then
    echo "🧹 Entferne temporäre Workshop-Daten ..."
    rm -rf "$WORKSHOP_DIR"
fi

echo "✅ ModLoader abgeschlossen."
