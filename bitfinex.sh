#!/bin/bash
#
# Bitfinix.sh  -- Websocket access to Bitfinex.com
# v0.1.1  11/nov/2019  by mountainner_br

## Some defaults
LC_NUMERIC=en_US.UTF-8
COLOROPT="cat"

# BITFINIEX API DOCS
#https://docs.bitfinex.com/reference#ws-public-ticker

HELP="
SYNOPSIS
	Bitfinex.sh [-c] [MARKET]
	
	Bitfinex.sh [-h|-l|-v]


DESCRIPTION
	This script accesses the Bitfinex Exchange public API and fetches
	market data.

	Currently, only the order price live stream is implemented. Floating 
	numbers are printed as received from the server.
	

WARRANTY
	This programme needs latest version of Bash, JQ, xargs, websocat and
	lolcat.

	This is free software and is licensed under the GPLv3 or later.
	

OPTIONS
		-h 	Show this help.

		-l 	List available markets.
		
		-c 	Coloured live stream price.
		
		-v 	Show this programme version.
		"


## Bitstamp Websocket for Price Rolling -- Default opt
streamf() {
		websocat -nt --ping-interval 20 "wss://api-pub.bitfinex.com/ws/2 " <<< "{ \"event\": \"subscribe\",  \"channel\": \"trades\",  \"symbol\": \"tBTCUSD\" }" |  jq --unbuffered -r '..[3]? // empty' | ${COLOROPT}
}

# Parse options
# If the very first character of the option string is a colon (:)
# then getopts will not report errors and instead will provide a means of
# handling the errors yourself.
while getopts ":lhcv" opt; do
  case ${opt} in
  	l ) # List Currency pairs
		printf "Currency pairs:\n"
		curl -s "https://api-pub.bitfinex.com/v2/tickers?symbols=ALL" | jq -r '.[][0]' | grep -v "^f[A-Z][A-Z][A-Z]$" | tr -d 't' | column -c80
		exit
		;;
	h ) # Show Help
		printf "%s" "${HELP}"
		exit 0
		;;
	s ) # Price stream -- Default opt
		STREAMOPT=1
		;;
	c ) # Coloured price stream
		COLOROPT="lolcat -p 2000 -F 5"
		;;
	v ) # Version of Script
		head "${0}" | grep -e '# v'
		exit 0
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
if [[ "${#1}" -le 3 ]] || ! grep -qi -e "t${1}$" <<< "$(curl -s "https://api-pub.bitfinex.com/v2/tickers?symbols=ALL" | jq -r '.[][0]')"; then
	printf "Not a supported currency pair.\n" 1>&2
	printf "List available markets with \"-l\".\n" 1>&2
	exit 1
fi

# Use default option -- Get last trade price
streamf "${@}"

