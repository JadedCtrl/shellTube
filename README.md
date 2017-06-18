OK, I'm re-writing shelltube.
It worked, but it was inflexible and total shit.
Yes, the dream is still POSIX. :)
Here is a general plan:

./shelltube	Wrapper script for everything else. Slim and simple
./lib/yts	Searches YT, outputs a comp-friendly list of results
./lib/ytc	Lists videos on a YT channel/user-page
./lib/ytd	Downloads/streams a YT video
./lib/stc	Helps configure shelltube
./lib/stic	Helps with cli arguments
./lib/sti	Helps with trapped user input

Planned inputs & details:
./shelltube
	shelltube [command(s) to run after startup]
./lib/yts
	$ yts query [-o $outfile]
	* Prints the results in the following format:
		artist \t name \t length (?) \t ID
./lib/ytc
	$ ytc query [-o $outfile]
	* Prints the results in the following format:
		name \t length (?) \t ID
./lib/ytd
	$ ytd URL||ID [-o $outfile||-s]
./lib/stc
	$ stc [-h||--home $homedir]
	* Just creates/edits $HOME/.config/shelltube
./lib/stic
	$ stic "$@" "[[syntax]] shortargf longargf argf
	* Outputs commandline args to the specified files
	  for easier parsing
	* dargf contains args like -c, -o, --config, etc.
	* argf contains everything else, like 'filename' etc.
	* [[syntax]] consists of something like this:
	  "[[(1|1|c|config)(1|0|v|verbose)(0|1|infile)(0|2|outfile)]]"
	* Does it look terrible painful? Let me show you the anatomy of
	  one of those listed potential arugments:
	* In a dashed arg (--config or -c), the syntax is this:
	  (1|0=no subsequent arg 1=subs. arg|short form|long form)
	  The "subsequent arg" means like 'file' in "--config file"
	* In a non-dashed arg (infile or outfile), the syntax is this:
	  (0|position in input|name)
	  "Position in input" refers to the position it has in relation
	  to other non-dashed args.
	  The "name"
	

I'm working on stic riggt now. I think it'll really make shelltube (and
probably any other shell script I'll ever write!) a lot better and more
usable.
