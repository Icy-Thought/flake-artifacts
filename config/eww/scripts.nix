{ config, lib, pkgs, ... }:

let
  imagesDir = "${config.xdg.configHome}/eww/images";
  privateKey = "/run/secrets/OpenWeatherMap/privateKey";

  eww-mails = pkgs.writers.writePython3 "eww-eww-mails" {
    libraries = with pkgs.python3Packages; [ imaplib2 ];
  } ''
    import imaplib
    obj = imaplib.IMAP4_SSL('imap.gmail.com', 993)
    obj.login('YOU@EMAIL.COM', 'PASSWORD')  # write your email and password
    obj.select()
    print(len(obj.search(None, 'UnSeen')[1][0].split()))
  '';

  eww-music-info = pkgs.writers.writeBash "eww-music-info" ''
    mpc="${pkgs.mpc_cli}/bin/mpc"
    ffmpeg="${pkgs.ffmpeg}/bin/ffmpeg"

    ## Get data
    STATUS="$($mpc status)"
    COVER="/tmp/.music_cover.jpg"
    MUSIC_DIR="${config.home.homeDirectory}/Music"

    ## Get status
    get_status() {
      if [[ $STATUS == *"[playing]"* ]]; then
        echo ""
      else
        echo "喇"
      fi
    }

    ## Get song
    get_song() {
      song=`$mpc -f %title% current`
      if [[ -z "$song" ]]; then
        echo "Offline"
      else
        echo "$song"
      fi
    }

    ## Get artist
    get_artist() {
      artist=`$mpc -f %artist% current`
      if [[ -z "$artist" ]]; then
        echo "Offline"
      else
        echo "$artist"
      fi
    }

    ## Get time
    get_time() {
      time=`$mpc status | grep "%)" | awk '{print $4}' | tr -d '(%)'`
      if [[ -z "$time" ]]; then
        echo "0"
      else
        echo "$time"
      fi
    }
    get_ctime() {
      ctime=`$mpc status | grep "#" | awk '{print $3}' | sed 's|/.*||g'`
      if [[ -z "$ctime" ]]; then
        echo "0:00"
      else
        echo "$ctime"
      fi
    }
    get_ttime() {
      ttime=`$mpc -f %time% current`
      if [[ -z "$ttime" ]]; then
        echo "0:00"
      else
        echo "$ttime"
      fi
    }

    ## Get cover
    get_cover() {
      $ffmpeg -i "''${MUSIC_DIR}/$($mpc current -f %file%)" "''${COVER}" -y &> /dev/null
      STATUS=$?

      # Check if the file has a embbeded album art
      if [ "$STATUS" -eq 0 ];then
        echo "$COVER"
      else
        echo "${imagesDir}/music.png"
      fi
    }

    ## Execute accordingly
    if [[ "$1" == "--song" ]]; then
      get_song
    elif [[ "$1" == "--artist" ]]; then
      get_artist
    elif [[ "$1" == "--status" ]]; then
      get_status
    elif [[ "$1" == "--time" ]]; then
      get_time
    elif [[ "$1" == "--ctime" ]]; then
      get_ctime
    elif [[ "$1" == "--ttime" ]]; then
      get_ttime
    elif [[ "$1" == "--cover" ]]; then
      get_cover
    elif [[ "$1" == "--toggle" ]]; then
      $mpc -q toggle
    elif [[ "$1" == "--next" ]]; then
      { $mpc -q next; get_cover; }
    elif [[ "$1" == "--prev" ]]; then
      { $mpc -q prev; get_cover; }
    fi
  '';

  eww-open-apps = pkgs.writers.writeBash "eww-eww-open-apps" ''
    ## Open Applications
    FILE="${config.xdg.cacheHome}/eww_launch.xyz"
    EWW="${config.home.homeDirectory}/.bin/eww"

    if [[ "$1" == "--ff" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && firefox &

    elif [[ "$1" == "--tg" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && discord &

    elif [[ "$1" == "--dc" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && element-desktop &

    elif [[ "$1" == "--tr" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && kitty --directory ~ &

    elif [[ "$1" == "--fm" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~ &

    elif [[ "$1" == "--ge" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && emacsclient -c &

    elif [[ "$1" == "--cd" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && gimp &

    elif [[ "$1" == "--gp" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && inkscape &

    elif [[ "$1" == "--vb" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && virtualbox &

    fi
  '';

  eww-open-folders = pkgs.writers.writeBash "eww-eww-open-folders" ''
    ## Open folders in nautilus
    FILE="${config.xdg.cacheHome}/eww_launch.xyz"
    EWW="${config.home.homeDirectory}/.bin/eww"

    if [[ "$1" == "--dl" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/Downloads &

    elif [[ "$1" == "--docs" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/Documents &

    elif [[ "$1" == "--music" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/Music &

    elif [[ "$1" == "--pics" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/Pictures &

    elif [[ "$1" == "--cfg" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/.config &

    elif [[ "$1" == "--local" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && nautilus ~/.local/share &

    fi
  '';

  eww-open-links = pkgs.writers.writeBash "eww-eww-open-links" ''
    ## Open links in firefox
    FILE="${config.xdg.cacheHome}/eww_launch.xyz"
    EWW="${config.home.homeDirectory}/.bin/eww"
    cmd="firefox-devedition --new-tab"

    if [[ "$1" == "--mail" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && ''${cmd} "https://mail.google.com"

    elif [[ "$1" == "--gh" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && ''${cmd} "https://github.com"

    elif [[ "$1" == "--rd" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && ''${cmd} "https://reddit.com"

    elif [[ "$1" == "--tw" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && ''${cmd} "https://twitter.com"

    elif [[ "$1" == "--yt" ]]; then
      ''${EWW} close-all && rm -rf "$FILE" && ''${cmd} "https://youtube.com"

    fi
  '';

  eww-sys-info = pkgs.writers.writeBash "eww-eww-sys-info" ''
    ## Files and Data
    PREV_TOTAL=0
    PREV_IDLE=0
    cpuFile="/tmp/.cpu_usage"

    ## Get CPU usage
    get_cpu() {
      if [[ -f "''${cpuFile}" ]]; then
        fileCont=$(cat "''${cpuFile}")
        PREV_TOTAL=$(echo "''${fileCont}" | head -n 1)
        PREV_IDLE=$(echo "''${fileCont}" | tail -n 1)
      fi

      CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
      unset CPU[0]                          # Discard the "cpu" prefix.
      IDLE=''${CPU[4]}                        # Get the idle CPU time.

      # Calculate the total CPU time.
      TOTAL=0

      for VALUE in "''${CPU[@]:0:4}"; do
        let "TOTAL=$TOTAL+$VALUE"
      done

      if [[ "''${PREV_TOTAL}" != "" ]] && [[ "''${PREV_IDLE}" != "" ]]; then
        # Calculate the CPU usage since we last checked.
        let "DIFF_IDLE=$IDLE-$PREV_IDLE"
        let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
        let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
        echo "''${DIFF_USAGE}"
      else
        echo "?"
      fi

      # Remember the total and idle CPU times for the next check.
      echo "''${TOTAL}" > "''${cpuFile}"
      echo "''${IDLE}" >> "''${cpuFile}"
    }

    ## Get Used memory
    get_mem() {
      printf "%.0f\n" $(free -m | grep Mem | awk '{print ($3/$2)*100}')
    }

    ## Get Brightness
    get_blight() {
      CARD=`ls /sys/class/backlight | head -n 1`

      if [[ "$CARD" == *"intel_"* ]]; then
        BNESS=`xbacklight -get`
        LIGHT=''${BNESS%.*}
      else
        BNESS=`blight -d $CARD get brightness`
        PERC="$(($BNESS*100/255))"
        LIGHT=''${PERC%.*}
      fi

      echo "$LIGHT"
    }

    ## Get Battery
    get_battery() {
      BAT=`ls /sys/class/power_supply | grep BAT | head -n 1`
      cat /sys/class/power_supply/''${BAT}/capacity
    }

    ## Execute accordingly
    if [[ "$1" == "--cpu" ]]; then
      get_cpu
    elif [[ "$1" == "--mem" ]]; then
      get_mem
    elif [[ "$1" == "--blight" ]]; then
      get_blight
    elif [[ "$1" == "--bat" ]]; then
      get_battery
    fi
  '';

  eww-weather-info = pkgs.writers.writeBash "eww-eww-weather-info" ''
    ## Collect data
    cache_dir="${config.xdg.cacheHome}/eww/weather"
    cache_weather_stat=''${cache_dir}/weather-stat
    cache_weather_degree=''${cache_dir}/weather-degree
    cache_weather_quote=''${cache_dir}/weather-quote
    cache_weather_hex=''${cache_dir}/weather-hex
    cache_weather_icon=''${cache_dir}/weather-icon

    ## Weather data
    KEY="${privateKey}"
    ID="1795565"
    UNIT="metric"

    ## Make cache dir
    if [[ ! -d "$cache_dir" ]]; then
      mkdir -p ''${cache_dir}
    fi

    ## Get data
    get_weather_data() {
      weather=`curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID="$KEY"&id="$ID"&units="$UNIT""`
      echo ''${weather}

      if [ ! -z "$weather" ]; then
        weather_temp=`echo "$weather" | jq ".main.temp" | cut -d "." -f 1`
        weather_icon_code=`echo "$weather" | jq -r ".weather[].icon" | head -1`
        weather_description=`echo "$weather" | jq -r ".weather[].description" | head -1 | sed -e "s/\b\(.\)/\u\1/g"`

        #Big long if statement of doom
        if [ "$weather_icon_code" == "50d"  ]; then
          weather_icon=" "
          weather_quote="Forecast says it's misty \nMake sure you don't get lost on your way..."
          weather_hex="#84afdb"
        elif [ "$weather_icon_code" == "50n"  ]; then
          weather_icon=" "
          weather_quote="Forecast says it's a misty night \nDon't go anywhere tonight or you might get lost..."
          weather_hex="#84afdb"
        elif [ "$weather_icon_code" == "01d"  ]; then
          weather_icon=" "
          weather_quote="It's a sunny day, gonna be fun! \nDon't go wandering all by yourself though..."
          weather_hex="#ffd86b"
        elif [ "$weather_icon_code" == "01n"  ]; then
          weather_icon=" "
          weather_quote="It's a clear night \nYou might want to take a evening stroll to relax..."
          weather_hex="#fcdcf6"
        elif [ "$weather_icon_code" == "02d"  ]; then
          weather_icon=" "
          weather_quote="It's  cloudy, sort of gloomy \nYou'd better get a book to read..."
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "02n"  ]; then
          weather_icon=" "
          weather_quote="It's a cloudy night \nHow about some hot chocolate and a warm bed?"
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "03d"  ]; then
          weather_icon=" "
          weather_quote="It's  cloudy, sort of gloomy \nYou'd better get a book to read..."
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "03n"  ]; then
          weather_icon=" "
          weather_quote="It's a cloudy night \nHow about some hot chocolate and a warm bed?"
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "04d"  ]; then
          weather_icon=" "
          weather_quote="It's  cloudy, sort of gloomy \nYou'd better get a book to read..."
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "04n"  ]; then
          weather_icon=" "
          weather_quote="It's a cloudy night \nHow about some hot chocolate and a warm bed?"
          weather_hex="#adadff"
        elif [ "$weather_icon_code" == "09d"  ]; then
          weather_icon=" "
          weather_quote="It's rainy, it's a great day! \nGet some ramen and watch as the rain falls..."
          weather_hex="#6b95ff"
        elif [ "$weather_icon_code" == "09n"  ]; then
          weather_icon=" "
          weather_quote=" It's gonna rain tonight it seems \nMake sure your clothes aren't still outside..."
          weather_hex="#6b95ff"
        elif [ "$weather_icon_code" == "10d"  ]; then
          weather_icon=" "
          weather_quote="It's rainy, it's a great day! \nGet some ramen and watch as the rain falls..."
          weather_hex="#6b95ff"
        elif [ "$weather_icon_code" == "10n"  ]; then
          weather_icon=" "
          weather_quote=" It's gonna rain tonight it seems \nMake sure your clothes aren't still outside..."
          weather_hex="#6b95ff"
        elif [ "$weather_icon_code" == "11d"  ]; then
          weather_icon=""
          weather_quote="There's storm for forecast today \nMake sure you don't get blown away..."
          weather_hex="#ffeb57"
        elif [ "$weather_icon_code" == "11n"  ]; then
          weather_icon=""
          weather_quote="There's gonna be storms tonight \nMake sure you're warm in bed and the windows are shut..."
          weather_hex="#ffeb57"
        elif [ "$weather_icon_code" == "13d"  ]; then
          weather_icon=" "
          weather_quote="It's gonna snow today \nYou'd better wear thick clothes and make a snowman as well!"
          weather_hex="#e3e6fc"
        elif [ "$weather_icon_code" == "13n"  ]; then
          weather_icon=" "
          weather_quote="It's gonna snow tonight \nMake sure you get up early tomorrow to see the sights..."
          weather_hex="#e3e6fc"
        elif [ "$weather_icon_code" == "40d"  ]; then
          weather_icon=" "
          weather_quote="Forecast says it's misty \nMake sure you don't get lost on your way..."
          weather_hex="#84afdb"
        elif [ "$weather_icon_code" == "40n"  ]; then
          weather_icon=" "
          weather_quote="Forecast says it's a misty night \nDon't go anywhere tonight or you might get lost..."
          weather_hex="#84afdb"
        else
          weather_icon=" "
          weather_quote="Sort of odd, I don't know what to forecast \nMake sure you have a good time!"
          weather_hex="#adadff"
        fi
        echo "$weather_icon" >  ''${cache_weather_icon}
        echo "$weather_description" > ''${cache_weather_stat}
        echo "$weather_temp""°C" > ''${cache_weather_degree}
        echo -e "$weather_quote" > ''${cache_weather_quote}
        echo "$weather_hex" > ''${cache_weather_hex}
      else
        echo "Weather Unavailable" > ''${cache_weather_stat}
        echo " " > ''${cache_weather_icon}
        echo -e "Ah well, no weather huh? \nEven if there's no weather, it's gonna be a great day!" > ''${cache_weather_quote}
        echo "-" > ''${cache_weather_degree}
        echo "#adadff" > ''${tcache_weather_hex}
      fi
    }

    ## Execute
    if [[ "$1" == "--getdata" ]]; then
      get_weather_data
    elif [[ "$1" == "--icon" ]]; then
      cat ''${cache_weather_icon}
    elif [[ "$1" == "--temp" ]]; then
      cat ''${cache_weather_degree}
    elif [[ "$1" == "--hex" ]]; then
      cat ''${cache_weather_hex}
    elif [[ "$1" == "--stat" ]]; then
      cat ''${cache_weather_stat}
    elif [[ "$1" == "--quote" ]]; then
      cat ''${cache_weather_quote} | head -n1
    elif [[ "$1" == "--quote2" ]]; then
      cat ''${cache_weather_quote} | tail -n1
    fi
  '';

in [
  eww-open-apps
  eww-open-folders
  eww-open-links
  eww-sys-info
  eww-mails
  eww-weather-info
  eww-music-info
]
