#!/bin/bash
#Generates a running summary of the Z-Day
#Terminate main process with SIGINT (^C) to kill both processes

# DELAY must be at least 1 to stay within the API rules.  2 is nicer.
REGION=antarctica
USER_AGENT=toneor_zday_stats
DELAY=2


WGET_ARGS="--user-agent=$USER_AGENT --no-verbose"
PREFIX='https://www.nationstates.net/cgi-bin/api.cgi'

parse_row() {
	NAME=$(sed '/id=/ !d; s/.*id="\([^"]*\)".*/\1/' < "$1")
	ZACTION=$(sed '/<ZACTION>/ !d; s/.*>\(.*\)<.*/\1/' < "$1")
	SURVIVORS=$(sed '/<SURVIVORS>/ !d; s/.*>\(.*\)<.*/\1/' < "$1")
	ZOMBIES=$(sed '/<ZOMBIES>/ !d; s/.*>\(.*\)<.*/\1/' < "$1")
	DEAD=$(sed '/<DEAD>/ !d; s/.*>\(.*\)<.*/\1/' < "$1")

	#Don't remove the space; it lets sort work
	echo "$ZOMBIES ,$NAME,$ZACTION,$SURVIVORS,$DEAD"
}

fetch_data() {
	wget $WGET_ARGS "$PREFIX?region=$REGION&q=nations+zombie" -Oregion
	nations=$(grep '<NATIONS>' < region | sed 's/<[^>]*>//g; s/:/ /g')
	for i in $nations; do
		wget $WGET_ARGS "$PREFIX?nation=$i&q=zombie" -O "nations/$i"
		sleep $DELAY
	done
}

update_display() {
	nations=$(ls nations/)

	TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S (UTC/GMT)')

cat <<ENDHEREDOC
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
		<title>Nationstates Z-Day stats</title>
		<style type="text/css">
			tr.even { background-color: #DD8888 }
			tr.odd { background-color: #EECCCC }
			td {
				text-align: right;
				border-left: solid 2px transparent;
				border-right: solid 2px transparent;
			}
			span.strike {
				text-decoration: line-through
			}
		</style>
	</head>
	<body>
		<p>Last updated $TIMESTAMP</p>
		<p>All counts are in millions of <span class='strike'>brains</span> people</p>
		<table>
			<thead><tr><td>Name</td><td>Zombies</td><td>Living</td><td>Dead</td><td>Zombies per-capita</td><td>Policy</td></tr></thead><tbody>
ENDHEREDOC

	for i in $nations; do
		parse_row nations/$i
	done | sort -nr \
	| awk '-F,' '{ printf("<tr class=%c%s%c><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%.0f%%</td><td>%s</td></tr>\n", 
			34, ((NR % 2) ? "even" : "odd"), 34, $2,$1,$4,$5,($1/($1+$4+$5)) * 100.0,$3) }'

cat <<ENDHEREDOC
			</tbody>
		</table>
	</body>
</html>
ENDHEREDOC
}

terminate() {
	kill -TERM "$child"
	exit 0
}

if [ "display" == "$1" ]; then
	while true; do
		update_display > stats.html
		cp stats.html git/misc-files/stats.html
		sleep $DELAY
	done
else
	mkdir -p nations
	./zday.sh display &
	child=$!
	trap terminate SIGINT

	while true; do
		fetch_data
	done
fi

