#####################
# Name: yt-result.sh
# Date: 2016-12-10
# Lisc: ISC
# Main: jadedctrl
# Desc: Search YT videos and display
#       in easy-to-read and easy-to
#       -parse results
#####################

# Usage: yt-search.sh "$search_string"

# Bloody input...
row=0

if [ "$1" == "-i" ]
then
    interactive_mode=1
    query="$(echo "$2" | sed 's/ /+/g')"
    output="$3"
else
    query="$(echo "$arg" | sed 's/ /+/g')"
fi

function get_input() {
    printf "\033[0;32m>>>\033[0m "
    read -r n

    if [ "$n" == "exit" ]
    then
        exit
    fi

    test $n -ge 0 &> /dev/null

    if [ $? -gt 1 ] 
    then
        echo "Bad input, mate. Type in a valid number or 'exit'."
        get_input
    elif [ $n -gt 20 ]
    then
        echo "Out of range. Type in a valid number or 'exit'."
        get_input
    elif [ $n -gt 0 ] && [ $n -lt 20 ]
    then
        sed -n ${n}p $temp_file | sed 's/.*<a href="\/watch?v=//' | sed 's/".*//' > $output
    else
        echo "Bad input, mate. Type in a valid number or 'exit'."
        get_input
    fi
}

# If Google adds any extra features or changes the webpage
# layout, this script'll break immediately, haha.
# ... But at least we aren't using their API, right?

search_file="/tmp/yt-search_$RANDOM"

if type "wget" &> /dev/null
then
    wget -q https://youtube.com/results?search_query=$query -O $search_file
elif type "curl" &> /dev/null
then
    curl -s https://youtube.com/results?search_query=$query -o $search_file
fi

# Now for displaying the search results
temp_file="/tmp/yt-result_$RANDOM"
grep "<a href=\"\/watch?v=" $search_file | grep -v "<span class=\"yt-thumb-simple\"" > $temp_file
item_num=0
cat $temp_file | while IFS='' read -r CUR_LINE 
do 
    item_num=$(($item_num+1))
    # These tags trip up 'title=' and '" >' queries later on. Strip 'em.
    LINE="$(echo $CUR_LINE | sed 's/<span class=\"yt-badge \" >.*//')"
    LINE="$(echo $LINE | sed 's/views<\/li>.*//')"
    LINE="$(echo $LINE | sed 's/title="Verified"//')"

    if [ $row -eq 1 ]
    then
        color='\033[1;34m'
        color2='\033[1;34m'
        row=0
    elif [ $row -eq 0 ]
    then
        color='\033[1;31m'
        color2='\033[1;31m'
        row=1
    fi

    if echo "$LINE" | grep "View full playlist" > /dev/null
    then
        type="Playlist"
        if [ $interactive_mode -eq 1 ] 
        then
            printf "${color}$item_num. "
        fi
        title=$(echo "$LINE" | sed 's/.*title="//' | sed 's/".*//')
        items=$(echo "$LINE" | sed 's/.*View full playlist (//' | sed 's/).*//')
        echo -e "${color}$title"
        echo -e "${color2}$type | $items | $itemid"
    else
        type="Video"
        duration=$(echo "$LINE" | sed 's/.*Duration: //' | sed 's/\..*//')
        itemid=$(echo "$LINE" | sed 's/.*<a href="\/watch?v=//' | sed 's/".*//')
        title=$(echo "$LINE" | sed 's/.* title="//' | sed 's/".*//')
        if echo "$LINE" | grep /channel/ > /dev/null
        then
            # For /channel/ users
            author=$(echo "$LINE" | sed 's/.*" >//' | sed 's/<\/a>.*//')
        else
            # For /user/ users
            author=$(echo "$LINE" | sed 's/.*\/user\///' | sed 's/".*//')
        fi

        if [ $interactive_mode -eq 1 ] 
        then 
            if [ $item_num -lt 10 ]
            then
                printf "${color}$item_num.  "
            else
                printf "${color}$item_num. "
        fi
        echo -e "${color}$title${color2}"
        printf "    "
        fi
        i=0
        while [ $i -lt 16 ]
        do
            i=$((i+1))
            char=$(echo $author | cut -c$i)
            if [ -z $char ]
            then
                printf " "
            else
                printf "$char"
            fi
        done
        printf " | "
        i=0
        while [ $i -lt 5 ]
        do
            i=$((i+1))
            char=$(echo $duration | cut -c$i)
            if [ -z $char ]
            then
                printf " "
            else
                printf "$char"
            fi
        done
        printf " | $itemid\n"
    fi
done

if [ $interactive_mode -eq 1 ]
then
    get_input
fi


rm $temp_file
