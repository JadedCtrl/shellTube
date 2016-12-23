![Shelltube](https://cloud.githubusercontent.com/assets/7250745/21452795/52fcd6ea-c901-11e6-871b-bd646f2d7c49.png)

Shelltube is a collection of (pretty POSIX) shell scripts to
browse YouTube quickly, efficiently, and without the bloat
most command-line clients require.

Shelltube is written in pure shell; its only dependencies
are any modern shell (pdksh, bash, zsh), curl/wget, and
vlc/mplayer/kaffeine.

Even these dependencies, though, can easily be changed. If,
for example, you don't have vlc, you can just modify a
single line and be good-to-go using another player.

Also, Shelltube doesn't use the YouTube API at all. This
avoids the annoying red-tapey stuff that goes with it -- IDs,
registration, quotas -- but has some disadvantages. We'll
power through the downsides, though! :)


Usage
-------
Shelltube is quite simple to use; this tutorial will go over
the usage of the wrapper script, shelltube.sh.
When running the script, you'll see a prompt:

```
 >>
```

In this prompt you can type any of the following commands:

| (short) command syntax | description |
| --- | --- |
| (`!`) `about` | View the about page. |
| (`cls`) `clear` | Clear the screen. |
| (`dl`) `download [URL] ` | Download the selected/specified video. |
| `exit` | Exit Shelltube. |
| (`?`) `help` | Display this message. |
| (`md`) `metadata [URL]` | Display selected/specified video's metadata. |
| (`/`) `search TERM` | Perform a search for `TERM`. |
| (`str`) `stream [URL]` | Stream the selected/specified video. |
| (`sel`) `video URL` `video ID` | Select video based on `URL` or `ID`. |

In [brackets], optional arguments are written.

You can use Shelltube in one of two ways (or both):

1. By selecting a video and then doing something with it
2. By doing something and specifying the video

Method A entails using either the `video` or `search`
command to select a video, which will then be displayed
before the prompt like so:

```
$VIDEO-ID-HERE >>
```

When a video is selected, you use the `download`, `stream`,
or `metadata` commands without arguments to act on the
video.

Method B entails just using the `download`, `stream`, or
`metadata` commands while using a URL or video ID as an
argument.

For example:

```
 >> download $VIDEO-ID-HERE
```

You could opt to not use this interactive wrapper script and
instead just use the `yt-down`, `yt-search`, and
`yt-metadata` scripts on their own.

They are each pretty simple, and you can read their USAGE
messages at the top of each script.


Licensing
-----------
All of ST is released under the
[ISC](https://opensource.org/licenses/ISC) license.

Except for the `yt-down` script, which is released under the
[GPLv2](https://www.gnu.org/licenses/gpl-2.0.html).


Credit
--------
jadedctrl wrote most of ST, but iluaster wrote almost all of
`yt-down`
