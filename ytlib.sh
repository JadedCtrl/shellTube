#/bin/sh
########################################
# name: ytlib.sh
# desc: library for shelltube (`yt`)
# main: jadedctrl <jadedctrl@teknik.io>
# code: git.eunichx.us/shelltube.git
########################################

# --------------------------------------
# generic functions

# STRING --> STRING
# Return the first 'word' (space-delimiter) of a string.
function car {
	local string="$1"

	echo "$string" \
	| awk '{print $1}'
}

# STRING --> STRING
# Return all words after the first word of a string.
function cdr {
	local string="$1"

	echo "$string" \
	| awk '{$1=""; print}' \
	| sed 's/^ //'
}

# NUMBER NUMBER --> NUMBER
# Well, subtraction. Y'know...
function subtract {
	local operated=$1
	local operatee=$2
	echo "${1}-${2}" \
	| bc
}

# STRING --> NUMBER
# Count how many words are in a string.
function length {
	local string="$1"

	echo "$string" \
	| wc -w
}

# STRING --> NUMBER
# Count how many lines are in a string.
function line_length {
	local string="$1"

	echo "$string" \
	| wc -l
}

# STRING --> NUMBER
# Return the length of a string in chars.
function char_length {
	local string="$1"

	subtract $(echo "$string" | wc -c) 1
}

# STRING NUMBER [STRING] --> STRING
# pad string $1 out to the minimum length $2 with padding $3 (default: "0")
function min_string_length {
	local length="$2"
	local string="$1"

	if test -z "$3"; then
		local padding="0"
	else
		local padding="$3"
	fi
	local new="$string"
	if test "$length" -le "$(char_length "$string")"; then
		echo "$string"
	else
		while test "$(char_length "$new")" -lt "$length"; do
			new="${new}${padding}"
		done
		echo "$new"
	fi
}

# STRING NUMBER --> STRING
# get the first $2 characters in string $1
function char_get {
	local number="$1"
	local string="$2"

	string="$(min_string_length "$string" $number " ")"
	echo "$string" \
	| grep -o "^$(min_string_length "." $number ".")"
}



# --------------------------------------
# ansi colors and such

# NIL --> STRING
# Print an ANSI "unbold" escape string.
function unbold {
	printf "$(tput sgr0)"
}

# STRING --> STRING
# Print an ANSI "bold" escape string.
function bold {
	printf "$(tput bold)"
}

# STRING --> STRING
# Format a URL appropriately.
function format_url {
	local url="$1"

	# playlist/playlist video
	if echo "$url" | grep -q "playlist?"; then
		echo "$url" \
		| sed 's%.*list=%%'
	# video
	else
		echo "$url"
	fi
}



# --------------------------------------
# result parsing
# (playlist items, search -items)

# STRING --> STRING
# Pass the raw search HTML, get raw video result-lines
function result_lines {
	local search_html="$1"
	echo "$search_html" \
	| grep "<a href=\"\/watch?v=" \
	| grep -v "<span class=\"yt-thumb-simple\"" \
	| sed 's/|//g'
	#| grep -v "<a href=\"/playlist" \
}

# STRING --> STRING 
# Return the video ID of a result_line.
function result_id {
	local result_line="$1"

	if echo "$result_line" | grep -q "playlist-item"; then
		echo "$result_line" \
		| sed 's%.*?list=%%' \
		| sed 's%".*%%'
	elif echo "$result_line" | grep -q "data-title"; then
		echo "$result_line" \
		| sed 's%.* data-video-id="%%' \
		| sed 's%"><td class=".*%%' \
		| sed 's%".*%%'
	else
		echo "$result_line" \
		| sed 's%.*<a href="/watch?v=%%' \
		| sed 's%".*%%'
	fi
}

# STRING --> STRING
# Return the URL of a result-line.
function result_url {
	local result_line="$1"
	local id="$(result_id "$result_line")"

	# playlist ID
	if echo "$id" | grep -q "^PL"; then
		echo "https://youtube.com/playlist?list=${id}"
	# video ID
	else	# search result
		echo "https://youtube.com/watch?v=${id}"
	fi
}

# STRING --> STRING
# Return the title of a result-line.
function result_title {
	local result_line="$1"


	# playlist video
	if echo "$result_line" | grep -q "data-title"; then
		echo "$result_line" \
		| sed 's%.*data-title="%%' \
		| sed 's%" data-video-id.*%%' \
		| sed 's%".*%%'
	# video
	else
		echo "$result_line" \
		| sed 's%.*"  title="%%' \
		| sed 's%".*%%'
	fi
}

# STRING --> STRING
# Return the duration of a result-line.
function result_duration {
	local result_line="$1"

	# playlist
	if echo "$result_line" | grep -q "playlist-item"; then
		echo "$result_line" \
		| sed 's%.*View full playlist (%%' \
		| sed 's% videos.*%%' \
		| sed 's%$%v%'
	# playlist video
	elif echo "$result_line" | grep -q "data-title"; then
		echo "00:00"
	# video
	else	
		echo "$result_line" \
		| sed 's%.*> - Duration: %%' \
		| sed 's%\..*%%'
	fi
}

# STRING --> STRING
# Return the channel of a result-line.
function result_channel {
	local result_line="$1"

	# playlist
	if echo "$result_line" | grep -q "playlist-item"; then
		# playlist with /user/
		if echo "$result_line" | grep -q "/user/"; then
			echo "$result_line" \
			| sed 's%.*/user/%%' \
			| sed 's%</a>.*%%' \
			| sed 's%.*>%%'
		# playlist with /channel/
		else
			echo "$result_line" \
			| sed 's%.*/channel/%%' \
			| sed 's%</a>.*%%' \
			| sed 's%.*>%%'
		fi
	# playlist video
	elif echo "$result_line" | grep -q "data-title"; then
		echo "Someone, bby <3"
	# video	
	else
		# video with /channel/
		if echo "$result_line" | grep -q "/channel/"; then
			echo "$result_line" \
			| sed 's%.*href="/channel/%%' \
			| sed 's%</a>.*%%' \
			| sed 's%.*" >%%'
		# video with /user/	
		elif echo "$result_line" | grep -q "/user/"; then
			echo "$result_line" \
			| sed 's%.*href="/user/%%' \
			| sed 's%".*%%'
		fi
	fi
}

# STRING --> STRING
# Return the .yt-lockup-meta-info <ul> of a result-line
function result_meta_ul {
	local result_line="$1"

	echo "$result_line" \
	| sed 's%.*<ul class="yt-lockup-meta-info">%%' \
	| sed 's%</ul>.*%%'
}

# STRING --> STRING
# Return the "Uploaded..." string of a result-line
function result_uploaded {
	local result_line="$1"

	local result_meta_ul="$(result_meta_ul "$result_line")"

	# playlist
	if echo "$result_line" | grep -q "playlist-item"; then
		echo "Sometime"
	# playlist video	
	elif echo "$result_line" | grep -q "data-title"; then
		echo "Sometime"
	# video
	else
		echo "$result_meta_ul" \
		| sed 's%<li>%%' \
		| sed 's% ago</li>.*%%'
	fi
}

# STRING --> NUMBER
# Return the view-count of a result-line
function result_views {
	local result_line="$1"
	local result_meta_ul="$(result_meta_ul "$result_line")"

	echo "$result_meta_ul" \
	| sed 's%.*<li>%%g' \
	| sed 's% views</li>.*%%' \
	| sed 's%,%%g'
}

# STRING --> STRING
# Return a result's formatted URL
function result_formatted_url {
	local result_line="$1"

	format_url "$(result_url "$result_line")"
}




# --------------------------------------

# STRING --> STRING
# Format a result-line into a mediumly-pretty, one-line string~
function result_format_compact {
	local result_line="$1"
	local title="$(result_title "$result_line")"

	local format_title="$(bold)$(char_get 40 "$title")$(unbold)"
	local id="$(result_id "$result_line")"

	echo "$format_title | $id"
}

# STRING --> STRING
# Format a result-line into a mediumly-pretty, one-line string~
function result_format_small {
	local result_line="$1"
	local title="$(result_title "$result_line")"
	local url="$(result_formatted_url "$result_line")"

	local format_title="$(bold)$(char_get 40 "$title")$(unbold)"

	echo "$format_title | $url"
}

# STRING --> STRING
# Format a result-line into a mediumly-pretty, one-line string~
function result_format_medium {
	local result_line="$1"
	local title="$(result_title "$result_line")"
	local duration="$(result_duration "$result_line")"
	local url="$(result_formatted_url "$result_line")"

	local format_title="$(bold)$(char_get 40 "$title")$(unbold)"
	local format_duration="$(char_get 5 "$duration")"

	echo "$format_title | $format_duration | $url"
}

# STRING --> STRING
# Format a result-line into a pretty string~
function result_format_big {
	local result_line="$1"
	local title="$(result_title "$result_line")"
	local duration="$(result_duration "$result_line")"
	local uploaded="$(result_uploaded "$result_line")"
	local channel="$(result_channel "$result_line")"
	local url="$(result_formatted_url "$result_line")"

	local format_title="$(bold)$(char_get 79 "$title")$(unbold)"
	local format_duration="$(char_get 7 "$duration")"
	local format_uploaded="$(char_get 8 "$uploaded")"
	local format_channel="$(char_get 15 "$channel")"

	echo "$format_title"
	echo "$format_duration |  $format_uploaded |  $format_channel  |  $url"
}




# --------------------------------------
# playlsit metadata

# STRING --> STRING
# Get the title of a playlist, from HTML.
function playlist_title {
	local html="$1"

	video_title "$html"
}

# STRING --> STRING
# Get the video-count of a playlist, from HTML.
function playlist_duration {
	local html="$1"

	playlist_header_details "$html" \
	| sed 's%.*</a></li>%%' \
	| sed 's%</li>.*%%' \
	| sed 's%<li>%%'
}

# STRING --> STRING
# Get the view-count of a playlist, from HTML.
function playlist_views {
	local html="$1"

	playlist_header_details "$html" \
	| sed 's%.*</a></li>%%' \
	| sed 's%</li><li>Last.*%%' \
	| sed 's%.*</li><li>%%' \
	| sed 's% views%%' \
	| sed 's%,%%'
}

# STRING --> STRING
# Get the uploaded date of a playlist, from HTML.
function playlist_uploaded {
	local html="$1"

	playlist_header_details "$html" \
	| sed 's%.*</a></li>%%' \
	| sed 's%.*</li><li>%%' \
	| sed 's%Last updated on %%' \
	| sed 's%</li>.*%%'
}

# STRING --> STRING
# Get the author name of a playlist, from HTML.
function playlist_author_name {
	local html="$1"

	playlist_header_details "$html" \
	| sed 's%</li><li>.*%%' \
	| sed 's%.* >%%' \
	| sed 's%</.*%%'
}

# STRING --> STRING
# Get the author URL of a playlist, from HTML.
function playlist_author_url {
	local html="$1"

	local author_name="$(playlist_author_name "$html")"

	playlist_header_details "$html" \
	| sed 's%'"$author_name"'.*%%' \
	| sed 's%.*href="%%' \
	| sed 's%".*%%' \
	| sed 's%^%https://youtube.com%'
}

# STRING --> STRING
# Return the metadata header for playlist HTML
function playlist_header_details {
	local html="$1"

	echo "$html" \
	| grep "pl-header-details"
}

# --------------------------------------
# video metadata

# STRING --> STRING
# Get the description of a YT video, from HTML.
function video_desc {
	local html="$1"

	echo "$html" \
	| grep "action-panel-details" \
	| sed 's/.*<p .*class="" >//' \
	| sed 's%</p>.*%%' \
	| lynx -stdin -dump \
	| sed 's/^   //'
}

# STRING --> STRING
# Get the views of a YT video, from HTML.
function video_views {
	local html="$1"

	echo "$html" \
	| grep "watch-view-count" \
	| sed 's/.*"watch-view-count">//' \
	| sed 's/ views.*//' \
	| sed 's/,//g'
}

# STRING --> STRING
# Get the uploader's name of a YT video, from HTML.
function video_author_name {
	local html="$1"

	echo "$html" \
	| grep "\"name\": " \
	| sed 's/.*"name": "//' \
	| sed 's/".*//'
}

# STRING --> STRING
# Get the URL to a video uploader's channel, from HTML
function video_author_url {
	local html="$1"

	local author_name="$(video_author_name "$html")"
	local relative_url="$(echo "$html" \
				| grep "$author_name" \
				| grep "channel" \
				| grep "href" \
				| sed 's%.*="/%/%' \
				| sed 's/".*//')"
	echo "https://youtube.com${relative_url}"
}

# STRING --> STRING
# Get the title of a video, from HTML.
function video_title {
	local html="$1"

	echo "$html" \
	| grep "meta name=\"title\"" \
	| sed 's/.*content="//' \
	| sed 's/".*//' \
	| sed 's/ - Youtube//'
}



# --------------------------------------

# STRING STRING --> STRING
# Display results from a string of result_lines and a format-option
function results_display {
	local result_lines="$1"
	local format="$2"

	IFS='
'

	for result in $result_lines; do
		case "$format" in
			"compact") result_format_compact "$result" ;;
			"small") result_format_small "$result" ;;
			"medium") result_format_medium "$result" ;;
			"big") result_format_big "$result" ;;
		esac
	done
}



# --------------------------------------
# playlist usage

# Print playlist usage.
function playlist_list_usage {
	echo "usage: yt playlist --list [-csmb] url/id"
	exit 2
}

# Print playlist usage.
function playlist_search_usage {
	echo "usage: yt playlist --search [-csmb] search_query"
	exit 2
}

# Print playlist usage.
function playlist_views_usage {
	echo "usage: yt playlist --views url/id"
	exit 2
}

# Print playlist usage.
function playlist_author_usage {
	echo "usage: yt playlist --author [-un] url/id"
	exit 2
}

# Print playlist usage.
function playlist_date_usage {
	echo "usage: yt playlist --date url/id"
	exit 2
}

# Print playlist usage.
function playlist_title_usage {
	echo "usage: yt playlist --title url/id"
	exit 2
}



# --------------------------------------
# playlist invocation

# Invoke the playlist --list command
function playlist_list_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then playlist_list_usage; fi

	if test -n "$2"; then
		local url="$2"
		case "$1" in
			"-c") local format="compact" ;;
			"-s") local format="small" ;;
			"-m") local format="medium" ;;
			"-b") local format="big" ;;
		esac
	else
		local url="$1"
		local format="big"
	fi

	if echo "$url" | grep -qv "youtube.com"; then
		url="https://www.youtube.com/playlist?list=${url}"
	fi

	playlist_html="$(gendl "$url")"
	result_lines="$(result_lines "$playlist_html")" 

	results_display "$result_lines" "$format"
}

# Invoke the playlist --search command
function playlist_search_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then playlist_search_usage; fi

	if test -n "$2"; then
		local query="$2"
		case "$1" in
			"-c") local format="compact" ;;
			"-s") local format="small" ;;
			"-m") local format="medium" ;;
			"-b") local format="big" ;;
		esac
	else
		local query="$1"
		local format="big"
	fi

	query="$(echo "$query" | sed 's/ /+/g')"

	local search_url="https://youtube.com/results?search_query=${query}"
	search_url="${search_url}&sp=EgIQAw%253D%253D"

	local search_html="$(gendl "$search_url")"
	local result_lines="$(result_lines "$search_html")" 

	results_display "$result_lines" "$format"
}

# Invoke playlist --title
function playlist_title_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then playlist_title_usage; fi
	
	local url="$1"

	playlist_title "$(gendl "$url")"
}

# Invoke playlist --desc
function playlist_desc_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then playlist_desc_usage; fi

	if echo "$1" | grep "youtube" > /dev/null; then URL="$1"
	else
		URL="https://www.youtube.com/playlist?list=${1}"
	fi

	playlist_desc "$(gendl "$URL")"
}

# Invoke playlist --views
function playlist_views_invocation {
	case "$1" in
		"-h")	playlist_views_usage ;;
		"--help")
			playlist_views_usage ;;
		*youtube*)
			local url="$1" ;;
		*)	local url="https://www.youtube.com/playlist?list=${1}" ;;
	esac

	playlist_views "$(gendl "$url")"
}

# Invoke playlist --date
function playlist_uploaded_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then playlist_date_usage; fi

	if echo "$1" | grep "youtube" > /dev/null; then URL="$1"
	else
		URL="https://www.youtube.com/playlist?list=${1}"
	fi

	playlist_uploaded "$(gendl "$URL")"
}

# Invoke playlist --author
function playlist_author_invocation {
	case "$1" in
		"--help")
			playlist_author_usage ;;
		"-h")	playlist_author_usage ;;
		"-u")	view="url"
			url="$2"
			;;
		"-n")	view="name"
			url="$2"
			;;
		*)	view="both"
			url="$1"
			;;
	esac

	if echo "$url" | grep -qv "youtube"; then
		url="https://www.youtube.com/playlist?list=${1}"
	fi

	html="$(gendl "$url")"

	case "$view" in
		"url")	playlist_author_url "$html" ;;
		"name") playlist_author_name "$html" ;;
		"both") echo "$(playlist_author_name "$html")"
			echo "$(playlist_author_url "$html")"
			;;
	esac	
}

# --------------------------------------
# video usage

# Print video --search usage
function video_search_usage {
	echo "usage: yt video --search [-csmb] query"
	exit 2
}

# Print video --desc usage
function video_desc_usage {
	echo "usage: yt video --desc url/id"
	exit 2
}

# Print video --views usage
function video_views_usage {
	echo "usage: yt video --views url/id"
	exit 2
}

# Print video --author usage
function video_author_usage {
	echo "usage: yt video --author [-un] url/id"
	exit 2
}



# --------------------------------------
# video invocation

# Invoke video --search
function video_search_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then video_search_usage; fi

	if test -n "$2"; then
		local query="$2"
		case "$1" in
			"-c") local format="compact" ;;
			"-s") local format="small" ;;
			"-m") local format="medium" ;;
			"-b") local format="big" ;;
		esac
	else
		local query="$1"
		local format="big"
	fi

	query="$(echo "$query" | sed 's/ /+/g')"

	local search_url="https://youtube.com/results?search_query=${query}"
	search_url="${search_url}&sp=EgIQAQ%253D%253D"

	local search_html="$(gendl "$search_url")"
	local result_lines="$(result_lines "$search_html")" 

	results_display "$result_lines" "$format"
}

# Invoke video --title
function video_title_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then video_title_usage; fi
	
	local url="$1"

	video_title "$(gendl "$url")"
}

# Invoke video --desc
function video_desc_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then video_desc_usage; fi

	if echo "$1" | grep "youtube" > /dev/null; then URL="$1"
	else
		URL="https://www.youtube.com/watch?v=${1}"
	fi

	video_desc "$(gendl "$URL")"
}

# Invoke video --date
function video_uploaded_invocation {
	if test "$1" = "-h" -o "$1" = "--help"; then video_date_usage; fi

	if echo "$1" | grep "youtube" > /dev/null; then URL="$1"
	else
		URL="https://www.youtube.com/watch?v=${1}"
	fi

	video_uploaded "$(gendl "$URL")"
}

# Invoke video --views
function video_views_invocation {
	case "$1" in
		"-h")	video_views_usage ;;
		"--help")
			video_views_usage ;;
		*youtube*)
			local url="$1" ;;
		*)	local url="https://www.youtube.com/watch?v=${1}" ;;
	esac

	video_views "$(gendl "$url")"
}

# Invoke video --author
function video_author_invocation {
	case "$1" in
		"--help")
			video_author_usage ;;
		"-h")	video_author_usage ;;
		"-u")	view="url"
			url="$2"
			;;
		"-n")	view="name"
			url="$2"
			;;
		*)	view="both"
			url="$1"
			;;
	esac

	if echo "$url" | grep -qv "youtube"; then
		url="https://www.youtube.com/watch?v=${1}"
	fi

	html="$(gendl "$url")"

	case "$view" in
		"url")	video_author_url "$html" ;;
		"name") video_author_name "$html" ;;
		"both") echo "$(video_author_name "$html")"
			echo "$(video_author_url "$html")"
			;;
	esac	
}
