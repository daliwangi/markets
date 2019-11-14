#!/bin/bash
#
# v0.1.5  08/oct/2019  by castaway


HELP="SINOPSIS
	bakkt.sh [-hV]


	Bakkt price ticker and contract volume from <https://www.bakkt.com/> 
	at the terminal. The default option is to get intraday/last weekday 
	prices and volume.

	Market data delayed minimum of 15 minutes.

	Required software: Bash, JQ and cURL or Wget.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	
	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
	-h 	Show this help.

	-V 	Print this script version."

# Parse options
while getopts ":hV" opt; do
	case ${opt} in
		h ) # Help
	      		echo -e "${HELP}"
	      		exit 0
	      		;;
		V ) # Version of Script
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

#Check for JQ
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi

# Test if cURL or Wget is available
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "Package cURL or Wget is needed.\n" 1>&2
	exit 1
fi

# Price Ticker -- Default option
DATA0="$(${YOURAPP} "https://www.bakkt.com/api/bakkt/marketdata/contractslist/product/23808/hub/26066")"

printf "Bakkt Ticker\n"
jq -r '.[]|"Market ID: \(.marketId)",
	"Last time: \(.lastTime)",
	"End date : \(.endDate)",
	"Date     : \(.marketStrip)",
	"Change(%): \(.change)",
	"Volume   : \(.volume)",
	"L price  : \(.lastPrice)"' <<< "${DATA0}"

exit

# Dead code
#awk 'END-1 {print}'
# Get volume/contract data
#DATA1="$(${YOURAPP} "https://www.bakkt.com/api/bakkt/marketdata/contractslist/product/23808/hub/26066")"
# Contracts (Volumes)
#volf() {
#	jq -r 'reverse[]|
#		"",
#		"Date     : \(.marketStrip)",
#		"End Date : \(.endDate)",
#		"Last Time: \(.lastTime)",
#		"Volume   : \(.volume)",
#		"Last P   : \(.lastPrice)",
#		"Change(%): \(.change)"' <<< "${DATA1}"
#	}
#if [[ -n "${VOPT}" ]]; then
#	volf
#	exit
#fi
#
#v ) # Volume/Contract Ticker
#	VOPT=1
#			;;
#-v 	Contract/volume tickers.

