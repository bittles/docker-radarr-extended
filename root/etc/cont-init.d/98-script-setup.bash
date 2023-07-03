#!/usr/bin/with-contenv bash

# create extended directory if missing
if [ ! -d "/config/extended" ]; then
	mkdir -p "/config/extended"
fi

# create scripts directory if missing
if [ ! -d "/config/extended/scripts" ]; then
	mkdir -p "/config/extended/scripts"
#else # if not missing, remove all files in directory
#	echo "Removing previous scripts..."
#	rm -rf /config/extended/scripts/*
fi

# update any scripts in scripts dir, if missing
if [ -d "/config/extended/scripts" ]; then
	echo "Importing any missing extended scripts..."
  currentScript="AutoConfig.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="AutoExtras.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="MovieExtras.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="QueueCleaner.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="PlexNotify.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="Recyclarr.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="SMA.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
  currentScript="UnmappedFolderCleaner.bash"
  if [ ! -f "/config/extended/scripts/$currentScript" ]; then
    echo "Downloading and setting up $currentScript"
    curl "https://raw.githubusercontent.com/RandomNinjaAtk/docker-radarr-extended/main/root/scripts/$currentScript" -o "/config/extended/scripts/$currentScript"
    chmod 777 "/config/extended/scripts/$currentScript"
  fi
fi

# create cache directory if missing
if [ ! -d "/config/extended/cache" ]; then
	mkdir -p "/config/extended/cache"
fi

# create logs directory if missing
if [ ! -d "/config/extended/logs" ]; then
	mkdir -p "/config/extended/logs"
fi

# create configs directory if missing
if [ ! -d "/config/extended/configs" ]; then
	mkdir -p "/config/extended/configs"
fi

if [ ! -f "/config/extended/configs/sma.ini" ]; then
	cp /sma.ini "/config/extended/configs/sma.ini"
fi

#echo "Setting up scripts..."
#if [  -f "/config/extended/scripts/QueueCleaner.bash" ]; then
#	echo "Removing old script, QueueCleaner.bash"
#	rm "/config/extended/scripts/QueueCleaner.bash"
#fi
#echo "Downloading and setting up QueueCleaner.bash"
#curl "https://raw.githubusercontent.com/RandomNinjaAtk/arr-scripts/main/QueueCleaner.bash" -o "/config/extended/scripts/QueueCleaner.bash"
#chmod 777 "/config/extended/scripts/QueueCleaner.bash"

# set permissions
chmod 777 -R /usr/local/sma
find /config/extended -type d -exec chmod 777 {} \;
find /config/extended -type f -exec chmod 666 {} \;
chmod -R 777 /config/extended/scripts
echo "Complete..."
exit
