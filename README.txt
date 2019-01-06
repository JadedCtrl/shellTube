===============================================================================
SHELLTUBE                                    Shell scripts for easy YT-browsing
===============================================================================
shelltube will be a collection of (pretty POSIX) shell scripts to
browse YouTube quickly, and entirely without captive UIs.
Right now, there's only one script, yt-search

shelltube is written in pure shell; its only dependencies
are any modern shell (pdksh, bash, zsh) and curl/wget/ftp.
Your terminal should accept ANSI color-codes, too~

Before, shelltube was a set of scripts that culimated in a wrapper
script for browsing Youtube (like mpsyt). You could even download
videos from YT in pure shell! But, now, all videos require JS execution
to download (as far as I can tell), so it stopped working.

Now I'm refocusing a bit, ditching the wrapper script (begone, captive UIs,
ye spectre of ole!), and starting from scratch. :)



----------------------------------------
USAGE
----------------------------------------
There is one script that makes up shelltube:
	* yt-search

yt-search lists videos matching a certain search query.
	USAGE: yt-search [-csmb] query

Each option [-csmb] represents a different format-method.
	-b  	big      	TITLE \n DURATION | VIEWS | URL
	-m	medium   	TITLE | DURATION | URL
	-s	small    	TITLE | URL
	-c	compact 	TITLE | ID

Big takes up two lines, while the rest only use one.
If you're piping output, you might wanna usa -m, -s, or -c.



There is another script that comes with shelltube (which it uses
extensively:
	* gendl

gendl can download files on a system that has at least one of these:
	* ftp
	* wget
	* curl

... to stdout or to a file.

yt-search uses gendl--
so make sure they're both in the same directory (or, at least, that
gendl is in your $PATH)



----------------------------------------
BORING STUFF
----------------------------------------
License is in COPYING.txt (GNU GPLv3~! <3)
Author is Jenga Phoenix <jadedctrl@teknik.io>
Sauce is at https://git.eunichx.us/shelltube
