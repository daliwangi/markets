#!/bin/bash
#
# Binance.sh  -- Bash Crypto Converter and API Access
# v0.5.11  24/oct/2019  by mountaineerbr
# 

# Some defaults
LC_NUMERIC=en_US.UTF-8
FSTR="%.2f" 
COLORC="cat"

HELP="NAME
	\033[012;36mBinance.sh - Bash Cryptocurrency Converter\033[00m
	\033[012;36m             Binance API Access\033[00m


SYNOPSIS
	binance.sh [options] [amount] [from_crypto] [to_crypto]
	
	binance.sh [options] [market]


	This script gets rates of any cryptocurrency pair that Binance supports
	and can convert any amount of one crypto into another. It fetches data 
	from Binance public APIs.

	Take  notice  that Binance supports  specific markets, so for example, 
	there is a market for XRPBTC but not for BTCXRP. You can get a List of 
	all supported markets running the script with the option \"-l\".

	There are a few functions/modes for watching price rolling of the latest
	trades, as well as trade quantity. You can also watch book depth of any
	supported  Binance market.  Some functions use cURL to fetch data from
	REST APIs and some use Websocat to fetch data from websockets. If no
	market/currency pair is given, uses BTCUSDT by defaults.

	It is accepted to write each currency that forms a market separately,
	or together. Example: \"ZEC USDT\" or \"ZECUSDT\". Case is insensitive.
   
	Functions  that  use  cURL to fecth data from REST APIs update a little 
	slower because they depend on reconnecting repeatedly, whereas websocket
	streams leave an open connection so there is more frequent data flow.

	Default precision is unspecified for currency conversion, and defaults 
	to  two  decimal plates in price roll functions, unless otherwise speci-
	fied. A	different number of decimal plates can be supplied with the opt-
	ion \"-f\". See example (3).  This  option  also  accepts printf-like 
	formatting. If you are converting very large or very small amounts, or 
	depending  on  the  price rate  at the time, and would like to add a 
	\"thousands\" separator, too. See usage example (4).

   	This programme needs Bash, cURL, JQ , Websocat, Lolcat, Xargs and Core-
	utils to work properly.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES
		(1)     Half a Dash in Binance Coin:
			
			$ binance.sh 0.5 dash bnb 


		(2)     1000 Z-Cash in Paxos Standard:
			
			$ binance.sh 100 zecpax 


		(3)     Price of one XRP in USDC, four decimal plates.
			
			$ binance.sh -f4 xrpusdc 
			
		
		(4)     Price stream of BTCUSDT, group thousands; use only 
			one decimal plate.
			
			$ binance.sh -s -f\"%'.1f\" btcusdt


		(5) 	Order book depth view of ETHUSDT (20 levels on each side)

			$ binance.sh -e ethusdt


		(6)     Grep rates for all Bitcoin markets:

			$ binance.sh -l | grep BTC

			OBS: use \"^BTC\" to get markets that start with BTCxxx;
			     use \"BTC$\" to get markets that  end  with xxxBTC.

OPTIONS
	-c 	Price in Columns (last 250 orders); screen prices overlap in 
		each update; prices update from bottom right to top left; uses
		curl.

	-d 	Depth view of the order book; depth=10; uses websocket.
	
	-e 	Extended depth view of the order book; depth=20; uses websocket.

	-f 	Formatting of prices (printf-like); number of decimal plates; 
		for use with options \"-c\", \"-s\" and \"-w\".

	-h 	Show this Help.

	-i 	Detailed Information of the trade stream; uses websocket.
	
	-j  	For debugging; print lines that fetch Binance raw JSON data.

	-l 	List supported markets (coin pairs and rates).

	-s 	Stream of lastest trade prices; uses websocket.
	
	-t 	Rolling 24H Ticker for a currency pair/market; uses websocket.

	-u 	Together  with  options  \"-s\", \"-w\", \"-i\" or \"-u\", use cURL
		instead of Websocat.
		
	-v 	Show this script version.
	
	-w 	Colored stream of latest trade prices; uses websocket & lolcat."

## Error Check Function
errf() {
	if grep -iq -e "err" -e "code" <<< "${JSON}"; then
		echo "${JSON}"
		UNIQ="/tmp/binance_err.log${RANDOM}${RANDOM}"
		echo "${JSON}" > ${UNIQ}
		echo "Error detected in JSON. Please check." 1>&2
		echo "${UNIQ}" 1>&2
		exit 1
	fi
}

# Functions
mode1() {  # Price in columns
	while true; do
		JSON="$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=${LIMIT}")"
		errf
		PRICES="$(jq -r '.[] | .p' <<< "${JSON}")"
		awk '{ printf "\n'${FSTR}'", $1 }' <<< "${PRICES}" | column | ${COLORC}
		printf "\n"
	done
	exit 0
}
mode3() {  # Price and trade info
# Note: Only with this method you can access QuoteQty!!
	curlmode() {
	while true; do
		JSON=$(curl -s "https://api.binance.com/api/v1/trades?symbol=${2^^}${3^^}&limit=1")
		errf
		RATE="$(jq -r '.[] | .price' <<< "${JSON}")"
		QQT="$(jq -r '.[] | .quoteQty' <<< "${JSON}")"
		TS="$(jq -r '.[] | .time' <<< "${JSON}" | cut -c-10)"
		DATE="$(date -d@"${TS}" "+%T%Z")"
		printf "\n${FSTR}  %s  %'.f" "${RATE}" "${DATE}" "${QQT}"   
	done
	exit 0
	}
	# cURL Mode?
	test -n "${CURLOPT}" &&	curlmode ${*}

	# Websocat Mode
	printf "Detailed Stream of %s%s\n" "${2^^}" "${3^^}"
	printf -- "Price, Quantity and Time.\n\n"
	websocat -nt --ping-interval 20 "wss://stream.binance.com:9443/ws/${2,,}${3,,}@aggTrade" |
		jq --unbuffered -r '"P: \(.p|tonumber)  \tQ: \(.q)     \tP*Q: \((.p|tonumber)*(.q|tonumber)|round)   \t\(if .m == true then "MAKER" else "TAKER" end)\t\(.T/1000|round | strflocaltime("%H:%M:%S%Z"))"'
	exit 0
}

mode4() {  # Stream of prices
	curlmode() { 
		while true; do
			JSON="$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=1")"
	 		errf
			RATE="$(jq -r '.[] | .p' <<< "${JSON}")"
			awk '{ printf "\n'${FSTR}'", $1 }' <<< "${RATE}" | ${COLORC}
		done
		exit 0
		}
	# cURL Mode?
	test -n "${CURLOPT}" &&	curlmode ${*}

	# Websocat Mode
	printf "Stream of %s%s\n" "${2^^}" "${3^^}"
	websocat -nt --ping-interval 20 "wss://stream.binance.com:9443/ws/${2,,}${3,,}@aggTrade" |
		jq --unbuffered -r '.p' | xargs -n1 printf "\n${FSTR}" | ${COLORC}
	#stdbuf -i0 -o0 -e0 cut -c-8
	exit
}

mode6() { # Depth of order book (depth=10)
	printf "Order Book Depth\n"
	printf "Price and Quantity\n"
	websocat -nt --ping-interval 20 "wss://stream.binance.com:9443/ws/${2,,}${3,,}@depth10" |
	jq -r --arg FCUR "${2^^}" --arg TCUR "${3^^}" '
		"\nORDER BOOK DEPTH \($FCUR) \($TCUR)",
		"",
		"\t\(.asks[9]|.[0]|tonumber)    \t\(.asks[9]|.[1]|tonumber)",
		"ASKS\t\(.asks[8]|.[0]|tonumber)    \t\(.asks[8]|.[1]|tonumber)",
		"\t\(.asks[7]|.[0]|tonumber)    \t\(.asks[7]|.[1]|tonumber)",
		"\t\(.asks[6]|.[0]|tonumber)    \t\(.asks[6]|.[1]|tonumber)",
		"\t\(.asks[5]|.[0]|tonumber)    \t\(.asks[5]|.[1]|tonumber)",
		"\t\(.asks[4]|.[0]|tonumber)    \t\(.asks[4]|.[1]|tonumber)",
		"\t\(.asks[3]|.[0]|tonumber)    \t\(.asks[3]|.[1]|tonumber)",
		"\t\(.asks[2]|.[0]|tonumber)    \t\(.asks[2]|.[1]|tonumber)",
		"\t\(.asks[1]|.[0]|tonumber)    \t\(.asks[1]|.[1]|tonumber)",
		"     > \(.asks[0]|.[0]|tonumber)      \t\(.asks[0]|.[1]|tonumber)",
		"     < \(.bids[0]|.[0]|tonumber)      \t\(.bids[0]|.[1]|tonumber)",
		"\t\(.bids[1]|.[0]|tonumber)    \t\(.bids[1]|.[1]|tonumber)",
		"\t\(.bids[2]|.[0]|tonumber)    \t\(.bids[2]|.[1]|tonumber)",
		"\t\(.bids[3]|.[0]|tonumber)    \t\(.bids[3]|.[1]|tonumber)",
		"\t\(.bids[4]|.[0]|tonumber)    \t\(.bids[4]|.[1]|tonumber)",
		"\t\(.bids[5]|.[0]|tonumber)    \t\(.bids[5]|.[1]|tonumber)",
		"\t\(.bids[6]|.[0]|tonumber)    \t\(.bids[6]|.[1]|tonumber)",
		"\t\(.bids[7]|.[0]|tonumber)    \t\(.bids[7]|.[1]|tonumber)",
		"BIDS\t\(.bids[8]|.[0]|tonumber)    \t\(.bids[8]|.[1]|tonumber)",
		"\t\(.bids[9]|.[0]|tonumber)    \t\(.bids[9]|.[1]|tonumber)"'
		exit
}
mode6extra() { # Depth of order book (depth=20)
	printf "Order Book Depth\n"
	printf "Price and Quantity\n"
	websocat -nt --ping-interval 20 "wss://stream.binance.com:9443/ws/${2,,}${3,,}@depth20" |
	jq -r --arg FCUR "${2^^}" --arg TCUR "${3^^}" '
		"\nORDER BOOK DEPTH \($FCUR) \($TCUR)",
		"",
		"\t\(.asks[19]|.[0]|tonumber)    \t\(.asks[19]|.[1]|tonumber)",
		"\t\(.asks[18]|.[0]|tonumber)    \t\(.asks[18]|.[1]|tonumber)",
		"\t\(.asks[17]|.[0]|tonumber)    \t\(.asks[17]|.[1]|tonumber)",
		"\t\(.asks[16]|.[0]|tonumber)    \t\(.asks[16]|.[1]|tonumber)",
		"\t\(.asks[15]|.[0]|tonumber)    \t\(.asks[15]|.[1]|tonumber)",
		"\t\(.asks[14]|.[0]|tonumber)    \t\(.asks[14]|.[1]|tonumber)",
		"\t\(.asks[13]|.[0]|tonumber)    \t\(.asks[13]|.[1]|tonumber)",
		"\t\(.asks[12]|.[0]|tonumber)    \t\(.asks[12]|.[1]|tonumber)",
		"\t\(.asks[11]|.[0]|tonumber)    \t\(.asks[11]|.[1]|tonumber)",
		"\t\(.asks[10]|.[0]|tonumber)    \t\(.asks[10]|.[1]|tonumber)",
		"\t\(.asks[9]|.[0]|tonumber)    \t\(.asks[9]|.[1]|tonumber)",
		"ASKS\t\(.asks[8]|.[0]|tonumber)    \t\(.asks[8]|.[1]|tonumber)",
		"\t\(.asks[7]|.[0]|tonumber)    \t\(.asks[7]|.[1]|tonumber)",
		"\t\(.asks[6]|.[0]|tonumber)    \t\(.asks[6]|.[1]|tonumber)",
		"\t\(.asks[5]|.[0]|tonumber)    \t\(.asks[5]|.[1]|tonumber)",
		"\t\(.asks[4]|.[0]|tonumber)    \t\(.asks[4]|.[1]|tonumber)",
		"\t\(.asks[3]|.[0]|tonumber)    \t\(.asks[3]|.[1]|tonumber)",
		"\t\(.asks[2]|.[0]|tonumber)    \t\(.asks[2]|.[1]|tonumber)",
		"\t\(.asks[1]|.[0]|tonumber)    \t\(.asks[1]|.[1]|tonumber)",
		"     > \(.asks[0]|.[0]|tonumber)      \t\(.asks[0]|.[1]|tonumber)",
		"     < \(.bids[0]|.[0]|tonumber)      \t\(.bids[0]|.[1]|tonumber)",
		"\t\(.bids[1]|.[0]|tonumber)    \t\(.bids[1]|.[1]|tonumber)",
		"\t\(.bids[2]|.[0]|tonumber)    \t\(.bids[2]|.[1]|tonumber)",
		"\t\(.bids[3]|.[0]|tonumber)    \t\(.bids[3]|.[1]|tonumber)",
		"\t\(.bids[4]|.[0]|tonumber)    \t\(.bids[4]|.[1]|tonumber)",
		"\t\(.bids[5]|.[0]|tonumber)    \t\(.bids[5]|.[1]|tonumber)",
		"\t\(.bids[6]|.[0]|tonumber)    \t\(.bids[6]|.[1]|tonumber)",
		"\t\(.bids[7]|.[0]|tonumber)    \t\(.bids[7]|.[1]|tonumber)",
		"BIDS\t\(.bids[8]|.[0]|tonumber)    \t\(.bids[8]|.[1]|tonumber)",
		"\t\(.bids[9]|.[0]|tonumber)    \t\(.bids[9]|.[1]|tonumber)",
		"\t\(.bids[10]|.[0]|tonumber)    \t\(.bids[10]|.[1]|tonumber)",
		"\t\(.bids[11]|.[0]|tonumber)    \t\(.bids[11]|.[1]|tonumber)",
		"\t\(.bids[12]|.[0]|tonumber)    \t\(.bids[12]|.[1]|tonumber)",
		"\t\(.bids[13]|.[0]|tonumber)    \t\(.bids[13]|.[1]|tonumber)",
		"\t\(.bids[14]|.[0]|tonumber)    \t\(.bids[14]|.[1]|tonumber)",
		"\t\(.bids[15]|.[0]|tonumber)    \t\(.bids[15]|.[1]|tonumber)",
		"\t\(.bids[16]|.[0]|tonumber)    \t\(.bids[16]|.[1]|tonumber)",
		"\t\(.bids[17]|.[0]|tonumber)    \t\(.bids[17]|.[1]|tonumber)",
		"\t\(.bids[18]|.[0]|tonumber)    \t\(.bids[18]|.[1]|tonumber)",
		"\t\(.bids[19]|.[0]|tonumber)    \t\(.bids[19]|.[1]|tonumber)"'
	exit
}
mode7() { # 24-H Ticker
	websocat -nt --ping-interval 20 "wss://stream.binance.com:9443/ws/${2,,}${3,,}@ticker" |
		jq -r '"",.s,.e,(.E/1000|round | strflocaltime("%H:%M:%S%Z")),
			"Window   :  \(((.C-.O)/1000)/(60*60)) hrs",
			"",
			"Price",
			"Change   :  \(.p|tonumber)  (\(.P|tonumber) %)",
			"W Avg    :  \(.w|tonumber)",
			"Open     :  \(.o|tonumber)",
			"High     :  \(.h|tonumber)",
			"Low      :  \(.l|tonumber)",
			"",
			"Total Volume",
			"Base     :  \(.v|tonumber)",
			"Quote    :  \(.q|tonumber)",
			"",
			"Trades",
			"N of  T  :  \(.n)",
			"First ID :  \(.F)",
			"Last  ID :  \(.L)",
			"First T-1:  \(.x)",
			"Last  T  :  \(.c|tonumber)  Qty: \(.Q)",
			"Best Bid :  \(.b|tonumber)  Qty: \(.B)",
			"Best Ask :  \(.a|tonumber)  Qty: \(.A)"'
	exit
}

# Check for no arguments or options in input
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit 1
fi

# Parse options
while getopts ":def:hjlcistuwv" opt; do
	case ${opt} in
		j ) # Grab JSON
			printf "Check below script lines that fetch raw JSON data:\n"
			grep -e "curl -s" -e "websocat" <"${0}" | sed -e 's/^[ \t]*//' | sort
			exit 0
	      		;;
		l ) # List markets (coins and respective rates)
			curl -s "https://api.binance.com/api/v1/ticker/allPrices" |
		     	jq -r '.[] | "\(.symbol)=\(.price)"' |
		     	sort | column -s '=' -e -t -N 'MARKET_PAIR,RATE'
			exit
	      		;;
		c )
	      		M1OPT=1
	      		LIMIT=250
	      		;;
		d )
	      		M6OPT=1
	      		;;
		e )
	      		M6EXTRAOPT=1
	      		;;
		f )
	 	     	FCONVERTER=1
	      		if [[ "${OPTARG}" =~ ^[0-9]+ ]]; then
		   		FSTR="%.${OPTARG}f"
		   		else
		   		FSTR="${OPTARG}"
	      		fi
	      		;;
		i )
	      		M3OPT=1
	      		;;
		s )
	      		M4OPT=1
	      		;;
		w )
	      		M4OPT=1
	      		COLORC="lolcat -p 2000 -F 5"
	      		;;
		t )
	      		M7OPT=1
	      		;;
		u )
	      		CURLOPT=1
	      		;;
		h ) # Help
	      		echo -e "${HELP}"
	      		exit 0
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


## Cryptocurrency Converter

# Arrange arguments
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] ||
	[[ -z "$(bc -l <<< "${1}" 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi

# Sets btc as "from_currency" for market code formation
# Will not set when calling the script without any option
if [[ -z ${2} ]]; then
	set -- "${1}" "btc"
fi

MARKETS="$(curl -s "https://api.binance.com/api/v1/ticker/allPrices" | jq -r '.[].symbol')"
if [[ -z ${3} ]] && ! grep -qi "^${2}$" <<< "${MARKETS}"; then
	set -- ${@:1:2} "USDT"
fi

## Check if input is a supported market 
if ! grep -qi "^${2}${3}$" <<< "${MARKETS}"; then
	printf "ERR: Market not supported: %s%s\n" "${2^^}" "${3^^}" 1>&2
	printf "List markets with option \"-l\".\n" 1>&2
	exit 1
fi

# Viewing/Watching Modes opts
# Price in columns
test -n "${M1OPT}" && mode1 ${*}
# Trade info
test -n "${M3OPT}" && mode3 ${*}
# Socket Stream
test -n "${M4OPT}" && mode4 ${*}
# Book Order Depth 10
test -n "${M6OPT}" && mode6 ${*}
# Book Order Depth 20
test -n "${M6EXTRAOPT}" && mode6extra ${*}
# 24-H Ticker
test -n "${M7OPT}" && mode7 ${*}

## Currency conversion/market rate
# Get rate
BRATE=$(curl -s https://api.binance.com/api/v1/ticker/price?symbol="${2^^}""${3^^}" | jq -r ".price")
# Check for floating point specs (decimal plates) and print result
if [[ -n "${FCONVERTER}" ]]; then
	bc -l <<< "${1}*${BRATE}" | xargs printf "${FSTR}\n"
else
	bc -l <<< "${1}*${BRATE}"
fi
exit 

# Dead code:

