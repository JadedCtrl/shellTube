===============================================================================
SHELLTUBE                                              Browse YT with a hood on
===============================================================================
shelltube is a simples shell-script that lets you browse Youtube--
searching for playlists, videos, channels, showing their metadata
(including items on playlists and channels, etc), with no weird dependencies.

It searches YouTube quickly, entirely without a captive UI.

shelltube is written in pure shell; its only dependencies are any
modern shell (pdksh, bash, zsh), lynx, and curl/wget/ftp.

Your terminal should accept ANSI color-codes, and be ≥79chars wide,
for best experience.

shelltube isn't for downloading videos-- it's for *browsing* for them.
Use youtube-dl or something for that. That's not my job! :P

2024 note: This is quite old, and is almost certain not to work!

----------------------------------------
INSTALLATION
----------------------------------------
Just place "ytlib.sh" in either the CWD, ./lib/ytlib.sh, /usr/lib/, or
/usr/local/lib/

Then put `gendl` and `yt` in your $PATH. /usr/local/bin/ is nice (IMO),
or ~/bin/, or /usr/bin. Whatever floats your boat, lad.

Profit!


----------------------------------------
EXAMPLES
----------------------------------------
	yt video search "wixoss op 1"
	yt v s "wixoss op 1"

	yt playlist search "my hero academia ops"
	yt p s "my hero academia ops"

	yt playlist title "PLY4D6ucZdLWC_yM3R_A1Hj9fAXZO_rSeK"
	yt p t "PLY4D6ucZdLWC_yM3R_A1Hj9fAXZO_rSeK"

	yt playlist list "PLY4D6ucZdLWC_yM3R_A1Hj9fAXZO_rSeK"
	yt p l "PLY4D6ucZdLWC_yM3R_A1Hj9fAXZO_rSeK"

	yt video author "https://youtube.com/watch?v=yu0HjPzFYnY"
	yt v a "https://youtube.com/watch?v=yu0HjPzFYnY"

	yt video desc "https://youtube.com/watch?v=yu0HjPzFYnY"
	yt v d "https://youtube.com/watch?v=yu0HjPzFYnY"

	yt video date "https://youtube.com/watch?v=yu0HjPzFYnY"
	yt v D "https://youtube.com/watch?v=yu0HjPzFYnY"


----------------------------------------
USAGE
----------------------------------------

YT
--------------------
`yt` is the shelltube script-- it's executed with a subcommand [arguments]
system, like `apt` or `git`.

	USAGE: yt subcommand action [arguments]

The subcommands are:
	* (v)ideo
	* (p)laylist

They refer to actions related to videos and playlists, respectively.

Every subcommand and action thereof supports "-h" and "--help".



YT VIDEO
--------------------
`yt video` is for anything related to videos-- here it is:

	USAGE: yt (v)ideo [action]

Here are the actions:

	SHORT	LONG      	ARGUMENTS
	----------------------------------------------
	s	search  	[-UIcsmb] search_query
	t	title    	url/id
	d	desc    	url/id
	v	views    	url/id
	a	author   	[-nU] url/id
	D	date    	url/id

The only actions with weird arguments are --search and --author:
	* normally, author returns the channel URL and name on one line
	* "author -n" returns only the name
	* "author -U" returns only the URL

	* normally, `search` prints results in the "big" format (title on
	  one line, other metadata on second line)
	* "search -c" for "compact" format, etc.
	* "-c", "-s", "-m", "-b", for "compact", "small", "medium", and "big",
	  respectively
	* "-U" and "-I" are special-- they print the URL and the ID *only*,
	  respectively. Good for making playlist files.


YT PLAYLIST
--------------------
`yt playlist` is for anything related to playlists-- here it is:

	USAGE: yt (p)laylist [action]

Here are the actions:

	SHORT	LONG      	ARGUMENTS
	----------------------------------------------
	s	search  	[-csmb] search_query
	l	list    	[-csmb] url/id
	t	title    	url/id
	v	views    	url/id
	a	author    	[-nu] url/id
	D	date    	url/id

The only actions with weird arguments are search, list and author:
	* author acts just like "video author"
	* search acts just like "video search"
	* list acts just like search, with [-UIcsmb]



GENDL
--------------------
There is another script that comes with shelltube (which it uses
extensively: gendl.

gendl can download files on a system that has at least one of these:
	* ftp
	* wget
	* curl

... to stdout or to a file.

Both yt and ytlib.sh require gendl-- so make sure they're both in the same
directory (or, at least, that gendl is in your $PATH)



----------------------------------------
BORING STUFF
----------------------------------------
License is in COPYING.txt (GNU GPLv3~! <3)
Author is Jenga Phoenix <jadedctrl@posteo.at>
Sauce is at https://hak.xwx.moe/jadedctrl/shelltube
