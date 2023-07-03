#!/usr/bin/env bash
scriptVersion="1.0.1"

notfidedBy="Radarr"
arrRootFolderPath="$(dirname "$radarr_movie_path")"
arrFolderPath="$radarr_movie_path"
arrEventType="$radarr_eventtype"
movieExtrasPath="$1"

# Debugging Settings
#enableExtras=false

# auto-clean up log file to reduce space usage
if [ -f "/config/logs/PlexNotify.txt" ]; then
	find /config/logs -type f -name "PlexNotify.txt" -size +1024k -delete
fi

if [ ! -f "/config/logs/PlexNotify.txt" ]; then
    touch "/config/logs/PlexNotify.txt"
    chmod 777 "/config/logs/PlexNotify.txt"
fi
exec &> >(tee -a "/config/logs/PlexNotify.txt")

log () {
    m_time=`date "+%F %T"`
    echo $m_time" :: PlexNotify :: $scriptVersion :: "$1
}

if [ "$enableExtras" == "true" ]; then
    if [ -z "$movieExtrasPath" ]; then
		log "MovieExtras script is enabled, skipping..."
		exit
	fi

	if [ ! -z "$movieExtrasPath" ]; then
		arrFolderPath="$movieExtrasPath"
		arrRootFolderPath="$(dirname "$movieExtrasPath")"
	fi

fi

log "$notfidedBy :: arrFolderPath was '$arrFolderPath'"
log "$notfidedBy :: movieExtrasPath was '$movieExtrasPath'"
log "$notfidedBy :: arrRootFolderPath was '$arrRootFolderPath'"

arrFolderPath2="${arrFolderPath/\/data/\/storage\/620B-5E2D}"
movieExtrasPath2="${movieExtrasPath/\/data/\/storage\/620B-5E2D}"
arrRootFolderPath2="${arrRootFolderPath/\/data/\/storage\/620B-5E2D}"

log "$notfidedBy :: arrFolderPath2 is now '$arrFolderPath2'"
log "$notfidedBy :: movieExtrasPath2 is now '$movieExtrasPath2'"
log "$notfidedBy :: arrRootFolderPath2 is now '$arrRootFolderPath2'"

if [ "$arrEventType" == "Test" ]; then
	log "$notfidedBy :: Tested Successfully"
	exit 0	
fi

PlexConnectionError () {
	log "ERROR :: Cannot communicate with Plex"
	log "ERROR :: Please check your plexUrl and plexToken"
	log "ERROR :: Configured plexUrl \"$plexUrl\""
	log "ERROR :: Configured plexToken \"$plexToken\""
	log "ERROR :: Exiting..."
	exit
}

# Validate connection
if curl -s "$plexUrl/?X-Plex-Token=$plexToken" | xq . &>/dev/null; then
	plexVersion=$(curl -s "$plexUrl/?X-Plex-Token=$plexToken" | xq . | jq -r '.MediaContainer."@version"')
	if [ "$plexVersion" == "null" ]; then
		# Error out if version is null, indicates bad token
		PlexConnectionError
	else
		log "Plex Connection Established, version: $plexVersion"
	fi
else
	# Error out if error in curl | xq . command output
	PlexConnectionError
fi

plexLibraries="$(curl -s "$plexUrl/library/sections?X-Plex-Token=$plexToken")"
plexLibraryData=$(echo "$plexLibraries" | xq ".MediaContainer.Directory")
if echo "$plexLibraryData" | grep "^\[" | read; then
	plexLibraryData=$(echo "$plexLibraries" | xq ".MediaContainer.Directory[]")
	plexKeys=($(echo "$plexLibraries" | xq ".MediaContainer.Directory[]" | jq -r '."@key"'))
else
	plexKeys=($(echo "$plexLibraries" | xq ".MediaContainer.Directory" | jq -r '."@key"'))
fi

if echo "$plexLibraryData" | grep "\"@path\": \"$arrRootFolderPath2" | read; then
	sleep 0.01
else
	log "$notfidedBy :: ERROR: No Plex Library found containing path \"$arrRootFolderPath2\""
	log "$notfidedBy :: ERROR: Add \"$arrRootFolderPath2\" as a folder to a Plex Movie Library"
	exit 1
fi

for key in ${!plexKeys[@]}; do
	plexKey="${plexKeys[$key]}"
	plexKeyData="$(echo "$plexLibraryData" | jq -r "select(.\"@key\"==\"$plexKey\")")"
	if echo "$plexKeyData" | grep "\"@path\": \"$arrRootFolderPath2" | read; then
		plexFolderEncoded="$(jq -R -r @uri <<<"$arrFolderPath2")"
		curl -s "$plexUrl/library/sections/$plexKey/refresh?path=$plexFolderEncoded&X-Plex-Token=$plexToken"
		log  "$notfidedBy :: Plex Scan notification sent! ($arrFolderPath2)"
	fi
done

exit
