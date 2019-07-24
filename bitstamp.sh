#!/bin/bash
#
#   Bitstamp.sh  -- Websocket access to Bitstamp.com
#   v 0.2 	24/07/2019 	by mountainner_br

## Some defaults
LC_NUMERIC=en_US.UTF-8

HELP="
USAGE:
	Bitstamp.sh [-s|-w] [market]
	Bitstamp.sh [-h|-l]


DESCRIPTION:
	This script accesses the Bitstamp Exchange API and fetches market
	data. Currently, only the order price live stream is implemented.
	Options \"-s\" and \"-w\" shows the same data as in:
		<https://www.bitstamp.net/s/webapp/examples/live_trades_v2.html>


OPTIONS:
		-h 	Show this help.
		-l 	List available markets.
		-s 	Live stream price.
		-w 	Coloured live stream price.

NOTICE:
	This programme needs latest version of Bash, JQ, websocat and lolcat.
	This is free software and is licensed under the GPLv3 or later.
	Copyleft 	by mountaineer_br 	2019

	"

## Bitstamp Websocket for Price Rolling
streamf() {
while true; do
	if [[ -z ${LOLCATOPT} ]]; then
		(printf '{ "event": "bts:subscribe","data": { "channel": "live_trades_%s" } }' "${1,,}" |
			websocat  --no-close --ping-interval 16 wss://ws.bitstamp.net |
			jq --unbuffered -r .data.price |
			xargs -n1 printf "\n%.2f") 2>/dev/null
	else
		(printf '{ "event": "bts:subscribe","data": { "channel": "live_trades_%s" } }' "${1,,}" |
			websocat  --no-close --ping-interval 16 wss://ws.bitstamp.net |
			jq --unbuffered -r .data.price |
			xargs -n1 printf "\n%.2f" |
			lolcat -p) 2>/dev/null
	fi
	echo -e "\n\n Press Ctrl+C twice to exit\n"
	sleep 2
	N=$(( ${N} + 1 ))	
	echo -e "\nTry #${N}\n"
done
exit
}


cstreamf() {
	LOLCATOPT=1
	streamf ${*}
}

lcpf () {
	printf "Currency pairs:\n\n %s\n\n" "${CPAIRS[*]}"
	printf "Also check <https://www.bitstamp.net/websocket/v2/>\n\n"
	exit
}

CPAIRS=(btcusd btceur eurusd xrpusd xrpeur xrpbtc ltcusd ltceur
	ltcbtc ethusd etheur ethbtc bchusd bcheur bchbtc)
# From: https://www.bitstamp.net/websocket/v2/


# Parse options
# If the very first character of the option string is a colon (:)
# then getopts will not report errors and instead will provide a means of
# handling the errors yourself.
while getopts ":lhsw" opt; do
  case ${opt} in
	b )
		;;
	m ) #
		;;
  	l ) # List Currency pairs
		LCPOPT=1
		;;
	h ) # Show Help
		printf "%s" "${HELP}"
		;;
	j ) # Print JSON
		PJSON=1
		;;
	k ) #
		;;
	s ) # B&W price stream
		STREAMOPT=1
		;;
	w ) # Coloured price stream
		CSTREAMOPT=1
		;;
	\? )
		echo "Invalid Option: -$OPTARG" 1>&2
		exit 1
		;;
  esac
done
shift $((OPTIND -1))


## Check if there is any argument
## And set defaults
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	set -- btcusd
fi

## Check for valid market pair
if test -z ${LCPOPT} && ! printf "%s\n" "${CPAIRS}" | grep -qi "${*}"; then
	printf "Not a supported currency pair.\n"
	printf "Run \"-l\" to list available markets.\n"
	exit 1
fi

### Set default scale if no custom scale
#SCLDEFAULTS=16
#if [[ -z ${SCL} ]]; then
#	SCL="${SCLDEFAULTS}"
#fi
#
### Set equation arguments
#if ! [[ ${1} =~ [0-9] ]]; then
#	set -- 1 ${@:1:2}
#fi
#
#if [[ -z ${3} ]]; then
#	set -- ${@:1:2} usd
#fi

# Run Functions
test -n "${STREAMOPT}" && streamf ${*}
test -n "${CSTREAMOPT}" && cstreamf ${*}
test -n "${LCPOPT}" && lcpf


