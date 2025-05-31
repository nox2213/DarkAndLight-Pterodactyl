#!/bin/bash

MODS_DIR="/home/container/DNL/Content/Mods"
STEAMCMD_PATH="/home/container/steamcmd/steamcmd.sh"
WORKSHOP_DIR="/home/container/.steam/steam/steamapps/workshop/content/529180"
CONFIG_DIR="/home/container/DNL/Saved/Config/WindowsServer"
GAMEUSER_FILE="$CONFIG_DIR/GameUserSettings.ini"
GAME_FILE="$CONFIG_DIR/Game.ini"
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
mkdir -p "$CONFIG_DIR"
if [ ! -f "$GAMEUSER_FILE" ]; then
    echo "📄 Creating new GameUserSettings.ini ..."
    cat > "$GAMEUSER_FILE" <<EOF
[SessionSettings]
SessionName="${SESSION_NAME}"
Port=${SERVER_PORT}
QueryPort=${QUERY_PORT}
MultiHome=${MULTI_HOME_ADRESS}

[ServerSettings]
ServerPassword=${DNL_PASSWORD}
ServerAdminPassword=${DNL_ADMIN_PASSWORD}
RCONEnabled=${RCON_ENABLED}
RCONPort=${RCON_PORT}
RCONServerGameLogBuffer=600
AdminLogging=False
ActiveMods=${MOD_LIST}
AutoSavePeriodMinutes=15.000000
TribeLogDestroyedEnemyStructures=False
ServerHardcore=False
ServerPVE=True
AllowCaveBuildingPvE=True
EnableExtraStructurePreventionVolumes=False
DifficultyOffset=1.000000
NoTributeDownloads=False
PreventUploadSurvivors=False
PreventUploadItems=False
PreventUploadDinos=False
PreventOfflinePvP=False
PreventTribeAlliances=False
PreventDiseases=False
NonPermanentDiseases=False
PreventSpawnAnimations=False
OxygenSwimSpeedStatMultiplier=1.000000
globalVoiceChat=False
proximityChat=False
alwaysNotifyPlayerLeft=False
alwaysNotifyPlayerJoined=False
ServerCrosshair=True
ServerForceNoHud=False
AllowThirdPersonPlayer=True
ShowMapPlayerLocation=True
EnablePVPGamma=True
DisablePvEGamma=False
ShowFloatingDamageText=True
AllowHitMarkers=True
AllowFlyerCarryPVE=True
XPMultiplier=1.000000
PlayerDamageMultiplier=1.000000
PlayerResistanceMultiplier=1.000000
PlayerCharacterWaterDrainMultiplier=1.000000
PlayerCharacterFoodDrainMultiplier=1.000000
PlayerCharacterStaminaDrainMultiplier=1.000000
PlayerCharacterHealthRecoveryMultiplier=1.000000
DinoDamageMultiplier=1.000000
TamedDinoDamageMultiplier=1.000000
DinoResistanceMultiplier=1.000000
TamedDinoResistanceMultiplier=1.000000
MaxTamedDinos=5000
DinoCharacterFoodDrainMultiplier=1.000000
DinoCharacterStaminaDrainMultiplier=1.000000
DinoCharacterHealthRecoveryMultiplier=1.000000
DinoCountMultiplier=1.000000
AllowRaidDinoFeeding=False
RaidDinoCharacterFoodDrainMultiplier=1.000000
DisableDinoDecayPvE=True
PvPDinoDecay=False
AutoDestroyDecayedDinos=False
PvEDinoDecayPeriodMultiplier=1.000000
MaxPersonalTamedDinos=500.000000
DisableImprintDinoBuff=False
AllowAnyoneBabyImprintCuddle=False
TamingSpeedMultiplier=1.000000
HarvestAmountMultiplier=1.000000
ResourcesRespawnPeriodMultiplier=1.000000
HarvestHealthMultiplier=1.000000
DayCycleSpeedScale=1.000000
DayTimeSpeedScale=1.000000
NightTimeSpeedScale=1.000000
StructureResistanceMultiplier=1.000000
StructureDamageMultiplier=1.000000
PvPStructureDecay=False
TheMaxStructuresInRange=10500.000000
PerPlatformMaxStructuresMultiplier=1.000000
MaxPlatformSaddleStructureLimit=50
OverrideStructurePlatformPrevention=True
PvEAllowStructuresAtSupplyDrops=True
DisableStructureDecayPVE=True
PvEStructureDecayDestructionPeriod=0.000000
PvEStructureDecayPeriodMultiplier=1.000000
AutoDestroyOldStructuresMultiplier=0.000000
ForceAllStructureLocking=False
OnlyAutoDestroyCoreStructures=False
OnlyDecayUnsnappedCoreStructures=False
FastDecayUnsnappedCoreStructures=False
DestroyUnconnectedWaterPipes=False
PreventDownloadSurvivors=False
PreventDownloadItems=False
PreventDownloadDinos=False
AllowFlyingStaminaRecovery=True
AllowMultipleAttachedC4=True

[MultiHome]
MultiHome=${MULTI_HOME}

[/Script/Engine.GameSession]
MaxPlayers=${MAX_PLAYERS}

[MessageOfTheDay]
Message="${MESSAGE_OF_THE_DAY}"
Duration=20
EOF
else
    echo "✏️  Updating GameUserSettings.ini with environment values ..."
    sed -i "/^\[SessionSettings\]/,/^\[/{s/^SessionName=.*/SessionName=${SESSION_NAME}/;s/^Port=.*/Port=${SERVER_PORT}/;s/^QueryPort=.*/QueryPort=${QUERY_PORT}/;s/^MultiHome=.*/MultiHome=${MULTI_HOME_ADRESS}/}" "$GAMEUSER_FILE"
    sed -i "/^\[ServerSettings\]/,/^\[/{s/^ServerPassword=.*/ServerPassword=${DNL_PASSWORD}/;s/^ServerAdminPassword=.*/ServerAdminPassword=${DNL_ADMIN_PASSWORD}/;s/^RCONEnabled=.*/RCONEnabled=${RCON_ENABLED}/;s/^RCONPort=.*/RCONPort=${RCON_PORT}/;s/^ActiveMods=.*/ActiveMods=${MOD_LIST}/}" "$GAMEUSER_FILE"
    sed -i "/^\[MultiHome\]/,/^\[/{s/^MultiHome=.*/MultiHome=${MULTI_HOME}/}" "$GAMEUSER_FILE"
    sed -i "/^\[\/Script\/Engine.GameSession\]/,/^\[/{s/^MaxPlayers=.*/MaxPlayers=${MAX_PLAYERS}/}" "$GAMEUSER_FILE"
    sed -i "/^\[MessageOfTheDay\]/,/^\[/{s/^Message=.*/Message=\"${MESSAGE_OF_THE_DAY}\"/}" "$GAMEUSER_FILE"
fi

# Create Game.ini if it doesn't exist
if [ ! -f "$GAME_FILE" ]; then
    echo "📄 Creating new Game.ini ..."
    cat > "$GAME_FILE" <<EOF
[/script/dnl.shootergamemode]
MaxTribeLogs=100
bDisableFriendlyFire=False
bPvEDisableFriendlyFire=False
bDisableLootCrates=False
MaxNumberOfPlayersInTribe=0
bIncreasePvPRespawnInterval=False
bAutoPvETimer=False
bPvEAllowTribeWar=True
bPvEAllowTribeWarCancel=False
bAllowCustomRecipes=True
CustomRecipeEffectivenessMultiplier=1.000000
CustomRecipeSkillMultiplier=1.000000
bUseCorpseLocator=True
bAllowUnlimitedRespecs=true
bAllowPlatformSaddleMultiFloors=True
SupplyCrateLootQualityMultiplier=1.000000
FishingLootQualityMultiplier=1.000000
OverrideMaxExperiencePointsPlayer=1
PlayerHarvestingDamageMultiplier=1.000000
CraftingSkillBonusMultiplier=1.000000
OverrideMaxExperiencePointsDino=1
DinoHarvestingDamageMultiplier=3.000000
DinoTurretDamageMultiplier=1.000000
MatingIntervalMultiplier=1.000000
EggHatchSpeedMultiplier=1.000000
BabyMatureSpeedMultiplier=1.000000
BabyFoodConsumptionSpeedMultiplier=1.000000
BabyImprintingStatScaleMultiplier=1.000000
BabyCuddleIntervalMultiplier=1.000000
BabyCuddleGracePeriodMultiplier=1.000000
BabyCuddleLoseImprintQualitySpeedMultiplier=1.000000
ResourceNoReplenishRadiusPlayers=1.000000
ResourceNoReplenishRadiusStructures=1.000000
GlobalSpoilingTimeMultiplier=1.000000
GlobalItemDecompositionTimeMultiplier=1.000000
GlobalCorpseDecompositionTimeMultiplier=1.000000
CropDecaySpeedMultiplier=1.000000
CropGrowthSpeedMultiplier=1.000000
LayEggIntervalMultiplier=1.000000
PoopIntervalMultiplier=1.000000
HairGrowthSpeedMultiplier=1.000000
CraftXPMultiplier=1.000000
GenericXPMultiplier=1.000000
HarvestXPMultiplier=1.000000
KillXPMultiplier=1.000000
SpecialXPMultiplier=1.000000
StructureDamageRepairCooldown=180
PvPZoneStructureDamageMultiplier=6.000000
bFlyerPlatformAllowUnalignedDinoBasing=True
bPassiveDefensesDamageRiderlessDinos=False
bDisableStructurePlacementCollision=True
EOF
fi

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
