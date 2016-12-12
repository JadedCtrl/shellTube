####################
# Name: shelltube.sh
# Date: 2016-12-11
# Lisc: ISC
# Main: jadedctrl
# Desc: Full-shell YT client that
#       avoids the YT API.
#####################

function search() {
    output="/tmp/yt-search-$RANDOM"
    sh yt-search.sh -i "$1" $output
    selected_video=$(cat $output)
    metadata
}

function interactive() {
    get_input
}

function about() {
    echo -e "\033[0;35mShelltube v0.3"
    echo -e "\033[0;32mDesc: \033[0;34mYT client written in shell."
    echo -e "\033[0;32mMain: \033[0;34mjadedml@openmailbox.org"
    echo -e "\033[0;32mLisc: \033[0;34mISC; yt-down.sh & yt-stream.sh GPLv2\033[0m"
}

function metadata() {
    sh yt-meta.sh "$selected_video"
}

function download() {
    sh yt-down.sh "$selected_video"
}

function stream() {
    sh yt-down.sh -s "$selected_video"
}

function get_input() {
    printf "\033[0;34m$selected_video \033[0;32m>>\033[0m "
    read -r n
    if [ "$n" == "help" ] || [ "$n" == "?" ]
    then 
        help
        interactive
    elif echo "$n" | grep "^search " > /dev/null
    then
        search "$(echo "$n" | sed 's/search //')"
        interactive
    elif echo "$n" | grep "^/" > /dev/null
    then
        search "$(echo "$n" | sed 's^/^^')"
        interactive
    elif echo "$n" | grep "^/ " > /dev/null
    then
        search "$(echo "$n" | sed 's^/ ^^')"
        interactive
    elif echo "$n" | grep "^video " > /dev/null
    then
        if echo "$n" | grep "youtube.com"
        then
            selected_video="$(echo "$n" | sed 's/.*watch?v=//')"
        else
            selected_video="$(echo "$n" | sed 's/sel //')"
        fi
        metadata
        interactive
    elif echo "$n" | grep "^sel " > /dev/null
    then
        if echo "$n" | grep "youtube.com"
        then
            selected_video="$(echo "$n" | sed 's/.*watch?v=//')"
        else
            selected_video="$(echo "$n" | sed 's/sel //')"
        fi
        metadata
        interactive
    elif [ "$n" == "download" ] || [ "$n" == "dl" ]
    then
        download
        interactive
    elif [ "$n" == "metadata" ] || [ "$n" == "md" ]
    then
        metadata
        interactive
    elif [ "$n" == "stream" ] || [ "$n" == "str" ]
    then
        stream
        interactive
    elif [ "$n" == "about" ] || [ "$n" == "!" ]
    then
        about
        interactive
    elif [ "$n" == "clear" ] || [ "$n" == "cls" ]
    then
        clear
        interactive
    elif [ "$n" == "exit" ]
    then
        rm /tmp/yt-*
        exit
    else
        get_input
    fi
}

function help() {
    echo "about    | !        View the about page."
    echo "clear    | cls      Clear the screen."
    echo "download | dl       Download the selected video."
    echo "exit     | ctrl+c   Exit Shelltube."
    echo "help     | ?        Display this message."
    echo "metadata | md       Display selected video's metadata."
    echo "search   | /        Perform a search."
    echo "stream   | str      Stream the selected video."
    echo "video    | sel    Select video based on URL or ID."
    echo "Note about usage:"
    echo "Both 'video ID; download' and 'download ID' are valid."
    echo "You don't need to select a video to run commands on it,"
    echo "but if you use metadata, download, or stream on an"
    echo "unselected video you must specify the ID or URL after the"
    echo "command."
}
     
echo -e "\033[0;35mShelltube v0.3"
interactive
