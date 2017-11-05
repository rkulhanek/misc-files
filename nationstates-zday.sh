#!/bin/bash
#Generates a running summary of the Z-Day
#Terminate main process with SIGINT (^C) to kill both processes

# DELAY must be at least 1 to stay within the API rules, but ideally it should be set well above that to avoid straining the server.
# Since this needs to make separate queries for each nation in the region each epoch, ideally only one nation in a region should
# run it and upload the results, so as to not stress the server.
# These values are tuned for antarctica; if your region is larger, you may want to adjust these values, but be sure you stay within
# the rate limits specified at https://www.nationstates.net/pages/api.html#ratelimits
REGION=antarctica
USER_AGENT=toneor_zday_stats
DELAY=9 # Should be at least 3 to both stay within rate limits and not risk stressing the server on a busy day
UPLOAD_PERIOD=15 # will do a full update once every $UPLOAD_PERIOD minutes

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

update_display() {
	nations=$(cat nations.txt)

	TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S (UTC/GMT)')

cat <<ENDHEREDOC
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
		<meta http-equiv="cache-control" content="max-age=0" />
		<meta http-equiv="cache-control" content="no-cache" />
		<meta http-equiv="expires" content="0" />
		<meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
		<meta http-equiv="pragma" content="no-cache" />
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
		<p>All counts are in millions of brains</p>
		<table>
			<thead><tr><td>Name</td><td>Zombies</td><td>Living</td><td>Dead</td><td>Zombies per-capita</td><td>Policy</td></tr></thead><tbody>
ENDHEREDOC

	for i in $nations; do
		parse_row nations/$i
	done | sort -nr \
	| awk '-F,' '{ printf("<tr class=%c%s%c><td><a href=%chttp://www.nationstates.net/nation=%s%c>%s</a></td><td>%s</td><td>%s</td><td>%s</td><td>%.0f%%</td><td>%s</td></tr>\n", 
			34, ((NR % 2) ? "even" : "odd"), 34, 34, $2, 34, $2,$1,$4,$5,($1/($1+$4+$5)) * 100.0,$3) }'

cat <<ENDHEREDOC
			</tbody>
		</table>
	</body>
</html>
ENDHEREDOC
}

fetch_data() {
	wget $WGET_ARGS "$PREFIX?region=$REGION&q=nations+zombie" -Oregion
	nations=$(grep '<NATIONS>' < region | sed 's/<[^>]*>//g; s/:/ /g')
	echo $nations > nations.txt

	for i in $nations; do
		wget $WGET_ARGS "$PREFIX?nation=$i&q=zombie" -O "nations/$i"
		sleep $DELAY
		update_display > stats.html
	done
}

mkdir -p nations
mkdir -p logs

while true; do
	#upload every epoch
	date
	echo "--------------------------------------------"
	fetch_data
	num_nations=$(wc -w nations.txt | awk '{print $1}')
	echo "$num_nations nations"
	cat nations/* | tr -d '\n' | sed 's|</NATION>|</NATION>\n|g' > $(date '+logs/%Y-%m-%d_%H:%M:%S')
	TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M:%S (UTC/GMT)')
	echo "================ $TIMESTAMP: Completed Epoch ================="
	#./upload-stats.sh

	sleep $(echo "$UPLOAD_PERIOD * 60 - $DELAY * $num_nations" | bc)
done

