#!/usr/bin/env bash
scriptVersion="1.0.7"

if [ -z "$arrUrl" ] || [ -z "$arrApiKey" ]; then
  arrUrlBase="$(cat /config/config.xml | xq | jq -r .Config.UrlBase)"
  if [ "$arrUrlBase" == "null" ]; then
    arrUrlBase=""
  else
    arrUrlBase="/$(echo "$arrUrlBase" | sed "s/\///g")"
  fi
  arrApiKey="$(cat /config/config.xml | xq | jq -r .Config.ApiKey)"
  arrPort="$(cat /config/config.xml | xq | jq -r .Config.Port)"
  arrUrl="http://127.0.0.1:${arrPort}${arrUrlBase}"
fi

# auto-clean up log file to reduce space usage
if [ -f "/config/logs/AutoConfig.txt" ]; then
	find /config/logs -type f -name "AutoConfig.txt" -size +1024k -delete
fi

if [ ! -f "/config/logs/AutoConfig.txt" ]; then
    touch "/config/logs/AutoConfig.txt"
    chmod 777 "/config/logs/AutoConfig.txt"
fi
exec &> >(tee -a "/config/logs/AutoConfig.txt")

log () {
  m_time=`date "+%F %T"`
  echo $m_time" :: AutoConfig :: $scriptVersion :: "$1
}

if [ -f /config/extended/logs/autoconfig ]; then
	log "Radarr previously configured with optimal settings, skipping..."
	log "To re-configure Radarr, delete the following file:"
	log "/config/extended/logs/autoconfig" 
	exit
fi

if [ -f /config/extended/configs/naming.json ]; then
	log "Using custom Naming (/config/extended/configs/naming.json)..."
	namingJson=$(cat /config/extended/configs/naming.json)
else
	log "Getting Trash Guide Recommended Naming..."
	namingJson=$(curl -s "https://raw.githubusercontent.com/TRaSH-/Guides/master/docs/json/radarr/naming/radarr-naming.json")
fi

trashStandardMovieFormat=$(echo "$namingJson" | jq -r '.file.default')
trashMovieFolderFormat=$(echo "$namingJson" | jq -r '.folder.default')

log "Updating Radarr Moving Naming..."
updateArr=$(curl -s "$arrUrl/api/v3/config/naming" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw "{
    \"renameMovies\":true,
    \"replaceIllegalCharacters\":true,
    \"colonReplacementFormat\":\"delete\",
    \"standardMovieFormat\":\"$trashStandardMovieFormat\",
    \"movieFolderFormat\":\"$trashMovieFolderFormat\",
    \"includeQuality\":false,
    \"replaceSpaces\":false,
    \"id\":1
    }")
    
log "Complete"

log "Updating Radarr Media Management..."
updateArr=$(curl -s "$arrUrl/api/v3/config/mediamanagement" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw '{
  "autoUnmonitorPreviouslyDownloadedMovies":false,
  "recycleBin":"",
  "recycleBinCleanupDays":7,
  "downloadPropersAndRepacks":"doNotPrefer",
  "createEmptyMovieFolders":false,
  "deleteEmptyFolders":true,
  "fileDate":"none",
  "rescanAfterRefresh":"always",
  "autoRenameFolders":false,
  "pathsDefaultStatic":false,
  "setPermissionsLinux":false,
  "chmodFolder":"777",
  "chownGroup":"",
  "skipFreeSpaceCheckWhenImporting":false,
  "minimumFreeSpaceWhenImporting":100,
  "copyUsingHardlinks":true,
  "importExtraFiles":true,
  "extraFileExtensions":"srt",
  "enableMediaInfo":true,
  "id":1
  }')
log "Complete"

log "Updating Radarr Medata Settings..."
updateArr=$(curl -s "$arrUrl/api/v3/metadata/1?" -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $arrApiKey" --data-raw '{
  "enable":true,"name":"Kodi (XBMC) / Emby","fields":[{"name":"movieMetadata","value":true},{"name":"movieMetadataURL","value":false},{"name":"movieMetadataLanguage","value":1},{"name":"movieImages","value":true},{"name":"useMovieNfo","value":true}],"implementationName":"Kodi (XBMC) / Emby","implementation":"XbmcMetadata","configContract":"XbmcMetadataSettings","infoLink":"https://wiki.servarr.com/radarr/supported#xbmcmetadata","tags":[],"id":1}')
log "Complete"

log "Configuring Radarr Custom Scripts"
if curl -s "$arrUrl/api/v3/notification" -H "X-Api-Key: ${arrApiKey}" | jq -r .[].name | grep "PlexNotify.bash" | read; then
	log "PlexNotify.bash already added to Radarr custom scripts"
else
	log "Adding PlexNotify.bash to Radarr custom scripts"
	updateArr=$(curl -s "$arrUrl/api/v3/filesystem?path=%2Fconfig%2Fextended%2Fscripts%2FPlexNotify.bash&allowFoldersWithoutTrailingSlashes=true&includeFiles=true" -H "X-Api-Key: ${arrApiKey}")
  updateArr=$(curl -s "$arrUrl/api/v3/notification?" -X POST -H "Content-Type: application/json" -H "X-Api-Key: ${arrApiKey}" --data-raw '{"onGrab":false,"onDownload":true,"onUpgrade":true,"onRename":true,"onMovieAdded":false,"onMovieDelete":false,"onMovieFileDelete":true,"onMovieFileDeleteForUpgrade":true,"onHealthIssue":false,"onApplicationUpdate":false,"supportsOnGrab":true,"supportsOnDownload":true,"supportsOnUpgrade":true,"supportsOnRename":true,"supportsOnMovieAdded":true,"supportsOnMovieDelete":true,"supportsOnMovieFileDelete":true,"supportsOnMovieFileDeleteForUpgrade":true,"supportsOnHealthIssue":true,"supportsOnApplicationUpdate":true,"includeHealthWarnings":false,"name":"PlexNotify.bash","fields":[{"name":"path","value":"/config/extended/scripts/PlexNotify.bash"},{"name":"arguments"}],"implementationName":"Custom Script","implementation":"CustomScript","configContract":"CustomScriptSettings","infoLink":"https://wiki.servarr.com/radarr/supported#customscript","message":{"message":"Testing will execute the script with the EventType set to Test, ensure your script handles this correctly","type":"warning"},"tags":[]}')
  log "Complete"
fi

if curl -s "$arrUrl/api/v3/notification" -H "X-Api-Key: ${arrApiKey}" | jq -r .[].name | grep "MovieExtras.bash" | read; then
	log "MovieExtras.bash already added to Radarr custom scripts"
else
	log "Adding MovieExtras.bash to Radarr custom scripts"
	updateArr=$(curl -s "$arrUrl/api/v3/filesystem?path=%2Fconfig%2Fextended%2Fscripts%2FMovieExtras.bash&allowFoldersWithoutTrailingSlashes=true&includeFiles=true" -H "X-Api-Key: ${arrApiKey}")
  updateArr=$(curl -s "$arrUrl/api/v3/notification?" -X POST -H "Content-Type: application/json" -H "X-Api-Key: ${arrApiKey}" --data-raw '{"onGrab":false,"onDownload":true,"onUpgrade":true,"onRename":true,"onMovieAdded":false,"onMovieDelete":false,"onMovieFileDelete":false,"onMovieFileDeleteForUpgrade":false,"onHealthIssue":false,"onApplicationUpdate":false,"supportsOnGrab":true,"supportsOnDownload":true,"supportsOnUpgrade":true,"supportsOnRename":true,"supportsOnMovieAdded":true,"supportsOnMovieDelete":true,"supportsOnMovieFileDelete":true,"supportsOnMovieFileDeleteForUpgrade":true,"supportsOnHealthIssue":true,"supportsOnApplicationUpdate":true,"includeHealthWarnings":false,"name":"MovieExtras.bash","fields":[{"name":"path","value":"/config/extended/scripts/MovieExtras.bash"},{"name":"arguments"}],"implementationName":"Custom Script","implementation":"CustomScript","configContract":"CustomScriptSettings","infoLink":"https://wiki.servarr.com/radarr/supported#customscript","message":{"message":"Testing will execute the script with the EventType set to Test, ensure your script handles this correctly","type":"warning"},"tags":[]}')
  log "Complete"
fi

touch /config/extended/logs/autoconfig
chmod 666 /config/extended/logs/autoconfig
exit
