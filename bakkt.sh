#!/bin/bash
#
# v0.1  08/oct/2019  by castaway


HELP="SINOPSIS
	bakkt.sh [-hvV]


	Bakkt price ticker and contract volume from <https://www.bakkt.com/> 
	at the terminal. The default option is to get intraday/last weekday 
	prices. Option \"-v\" fetches information about contracts/volume.

	Market data delayed minimum of 15 minutes.

	Required software: Bash and JQ.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	
	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
	-h 	Show this help.

	-v 	Contract/volume tickers.

	-V 	Print this script version."

# Parse options
while getopts ":hVv" opt; do
	case ${opt} in
		h ) # Help
	      		echo -e "${HELP}"
	      		exit 0
	      		;;
		v ) # Volume/Contract Ticker
			VOPT=1
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

# Get volume/contract data
DATA1="$(curl -s "https://www.bakkt.com/api/bakkt/marketdata/contractslist/product/23808/hub/26066")"
# Contracts (Volumes)
volf() {
	jq -r '.|
		reverse[]|
		"",
		"Date     : \(.marketStrip)",
		"End Date : \(.endDate)",
		"Last Time: \(.lastTime)",
		"Volume   : \(.volume)",
		"Last P   : \(.lastPrice)",
		"Change   : \(.change)"' <<< "${DATA1}"
	}
if [[ -n "${VOPT}" ]]; then
	volf
	exit
fi


# Ticker
DATA0="$(curl -s "https://www.bakkt.com/api/bakkt/marketdata/chartdata/market/6137542/timespan/0")"
	printf "Bakkt Ticker\n"
	jq -r '.|"Volume   : \(.[0].volume)"' <<< "${DATA1}"
	jq -r '"Date     : \(.stripDescription)",
	"Settlem P: \(.settlementPrice)",
	"Change   : \(.change)  \(.percentChangeDirection)",
	"Last P   : \(.lastPrice)"' <<< "${DATA0}"
	jq -r '.bars[-1][]' <<< "${DATA0}" | head -n1

# Dead code
#awk 'END-1 {print}'
#jq -r '.bars[][]' | tail -n2 | head -n1 <<< "${DATA0}"

