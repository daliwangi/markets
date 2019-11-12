#!/bin/bash
# Bitfinex.sh  -- Websocket access to Bitfinex.com
# v0.2.1  12/nov/2019  by mountainner_br

## Some defaults
LC_NUMERIC=en_US.UTF-8
COLOROPT="cat"
DECIMAL=2

# BITFINIEX API DOCS
#https://docs.bitfinex.com/reference#ws-public-ticker

HELP="
SYNOPSIS
	Bitfinex.sh [-c] [MARKET]
	
	Bitfinex.sh [-h|-l|-v]


DESCRIPTION
	This script accesses the Bitfinex Exchange public API and fetches
	market data.

	Currently, only the tve rade live stream is implemented.
	

WARRANTY
	This programme needs latest version of Bash, JQ, Websocat, Xargs and
	Lolcat.

	This is free software and is licensed under the GPLv3 or later.
	

OPTIONS
		-f [NUM] 	Set number of decimal plates; defaults=2.

		-h 		Show this help.

		-l 		List available markets.
		
		-c 		Coloured live stream price.
		
		-v 		Show this programme version."


## Bitfinex Websocket for Price Rolling -- Default opt
streamf() {
	{ websocat -nt --ping-interval 20 "wss://api-pub.bitfinex.com/ws/2 " <<< "{ \"event\": \"subscribe\",  \"channel\": \"trades\",  \"symbol\": \"t${1^^}\" }" |  jq --unbuffered -r '..|select(type == "array" and length == 4)|.[3]' | xargs -n1 printf "\n%.${DECIMAL}f" | ${COLOROPT};} 2>/dev/null
}

# Parse options
# If the very first character of the option string is a colon (:)
# then getopts will not report errors and instead will provide a means of
# handling the errors yourself.
while getopts ":f:lhcv" opt; do
  case ${opt} in
  	l ) # List Currency pairs
		printf "Currency pairs:\n"
		curl -s "https://api-pub.bitfinex.com/v2/tickers?symbols=ALL" | jq -r '.[][0]' | grep -v "^f[A-Z][A-Z][A-Z]$" | tr -d 't' | sort | column -c80
		exit
		;;
	f ) # Decimal plates
		DECIMAL="${OPTARG}"
		;;
	h ) # Show Help
		printf "%s\n" "${HELP}"
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
