#!/bin/bash
#
# Binance.sh  -- Binance crypto converter and API interface for Bash
# v0.2.8 	16/ago/2019   by mountaineer_br
# 

LICENSE_WARRANTY_NOTICE="
      \033[012;36mBinance.sh - Binance cryptocurrency converter
                   and API interface for Bash\033[00m
      \033[012;31mCopyright  2019  mountaineer_br\033[00m
  
      This program is free software: you can redistribute it and/or
      modify it under the terms of the GNU General Public License as
      published by the Free Software Foundation, either version 3 of
      the License, or any later version.
  
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
      
      To grep a copy of the full GNU General Public License, see
      <https://www.gnu.org/licenses/>.

      A tip would be such great surprise: 1KV3ksx5vZgdCvQzf4jGZ9Faerz4N6mDpx
	"
# Some defaults
LC_NUMERIC=en_US.UTF-8
FSTR="%.2f" 

#N=0

## Error Check Function
errf() {
	if printf "%s\n" "${JSON}" | grep -iq -e "err" -e "code"; then
		echo "Error detected in JSON. Please check."
		echo "${JSON}"
		UNIQ="/tmp/binance_err.log${RANDOM}${RANDOM}"
		echo "${JSON}" > ${UNIQ}
		echo "${UNIQ}"
		exit 1
	fi
}

mode1() {  #Price in columns
while true;
  do
	#echo ${1}-${2}-${3}-${4}
	JSON=$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=250")
	errf
	ARRAY1=$(printf "%s\n" "${JSON}" | jq -r '.[] | .p')
	for i in ${ARRAY1[@]}; do
		ARRAY2=$(printf "%s\n%s\n" "${ARRAY2}" "$i")
	done
	printf "%s\n" "${ARRAY2[@]}" | xargs -n1 printf "\n${FSTR}" | column
	printf "\n"
	ARRAY2=
	#sleep 0.4
	#echo $SECONDS
	#(( N++ ))
	#echo $N
done
}

mode2() {  # Colored price in columns
while true; 
do
	JSON=$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=200")
	errf
	
	ARRAY1=$(printf "%s\n" "${JSON}" | jq -r '.[] | .p')
	for i in ${ARRAY1[@]}; do
		ARRAY2=$(printf "%s\n%s\n" "${ARRAY2}" "$i")
	done
	printf "%s\n" "${ARRAY2[@]}" | xargs -n1 printf "\n${FSTR}" | column | lolcat
	printf "\n"
	ARRAY2=
done
}


mode3() {  # Price and trade info
# Note: Only with this method you can access QuoteQty!!

curlmode() {
while true;
  do
	JSON=$(curl -s "https://api.binance.com/api/v1/trades?symbol=${2^^}${3^^}&limit=1")
	errf

	RATE=$(printf "%s\n" "${JSON}" | jq -r '.[] | .price')
	QQT=$(printf "%s\n" "${JSON}" | jq -r '.[] | .quoteQty')
	TS=$(printf "%s\n" "${JSON}" | jq -r '.[] | .time' | cut -c-10)
	DATE=$(date -d@"${TS}" "+%T%Z")
	
	printf "\n%.2f\t%s\t%'.f" "${RATE}" "${DATE}" "${QQT}"   
done
}
if [[ -n "${CURLOPT}" ]]; then
	curlmode ${*}
	exit
fi

printf "\nDetailed Stream of %s\n" "${2^^} ${3^^}"
printf -- "Price, Quantity and Time.\n\n"

websocat -nt autoreconnect:- --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@aggTrade |
	jq --unbuffered -r '"P: \(.p|tonumber)  \tQ: \(.q)     \tP*Q: \((.p|tonumber)*(.q|tonumber)|round)   \t\(if .m == true then "MAKER" else "TAKER" end)\t\(.T/1000|round | strflocaltime("%H:%M:%S(%Z)"))"'

}

mode4() {  # Stream of prices ( Black & White )
curlmode() {
	while true;
  do
	JSON=$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=1")
 	errf

	RATE=$(printf "%s\n" "${JSON}" | jq -r '.[] | .p')
	printf "\n%.2f" "${RATE}"   

	#(( N++ ))
	#echo $N
done
}
if [[ -n "${CURLOPT}" ]]; then
	curlmode ${*}
	exit
fi

	printf "Stream of\n%s\n\n" "${2^^} ${3^^}"

	websocat -nt autoreconnect:- --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@aggTrade |
		jq --unbuffered -r .p | xargs -n1 printf "\n${FSTR}"

	#stdbuf -i0 -o0 -e0 cut -c-8
	#websocat -E --ping-interval 480 --text wss://stream.binance.com:9443/ws/btcusdt@aggTrade | jq -r .p # --no-close
	exit



}

mode5() {  # Colored stream of prices
curlmode() {
while true;
  do
	JSON=$(curl -s "https://api.binance.com/api/v1/aggTrades?symbol=${2^^}${3^^}&limit=1")
 	errf

	RATE=$(printf "%s\n" "${JSON}" | jq -r '.[] | .p')
	
	printf "\n%.2f" "${RATE}" | lolcat -p 200 -a -d 6 -s 10 
					   #secs = d/s = 15/30 = 0.5
	#(( N++ ))
	#echo $N
done
}
if [[ -n "${CURLOPT}" ]]; then
	curlmode ${*}
	exit
fi

	printf "Stream of\n%s\n\n" "${2^^} ${3^^}"
	
 	websocat  -nt autoreconnect:- --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@aggTrade |
		jq -r --unbuffered '.p'  | xargs -n1 printf "\n${FSTR}" | lolcat -p 2000 -F 5
	#stdbuf -i0 -o0 -e0 cut -c-8 | 
	exit
}

mode6() { # Depth of order book (depth=10)
	printf "Order Book Depth\nPrice and Quantity\n\n" 1>&2
	websocat -nt --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@depth10 |
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
	printf "Order Book Depth\nPrice and Quantity\n\n" 1>&2
	websocat -nt --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@depth20 |
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
websocat -nt --ping-interval 20 wss://stream.binance.com:9443/ws/${2,,}${3,,}@ticker |
	jq -r --arg FCUR "${2^^}" --arg TCUR "${3^^}" '"\n",.s,.e,(.E/1000|round | strflocaltime("%H:%M:%S(%Z)")),
	"Roll window:\t\(((.C-.O)/1000)/(60*60)) hrs",
	"\nChange:\t\t\(.p|tonumber) \($TCUR)","Change:\t\t\(.P|tonumber) %",
	"Trade sum:\t\(.n) trades",
	"Traded vol:\t\(.v|tonumber) \($FCUR)",
	"Traded vol:\t\(.q|tonumber) \($TCUR)",
	"\nOpen:\t\t\(.o|tonumber)",
	"High:\t\t\(.h|tonumber)",
	"Low:\t\t\(.l|tonumber)",
	"\nWeighted avg:\tP: \(.w|tonumber)",
	"Last trade:\tP: \(.c|tonumber)\tQ: \(.Q)",
	"Best bid:\tP: \(.b|tonumber)\tQ: \(.B)",
	"Best ask:\tP: \(.a|tonumber)\tQ: \(.A)"'

#jq -r --arg FCUR "${2}" --arg TCUR "${3}" '"\n",.s,.e,(.E/1000|round | strflocaltime("%H:%M:%S(%Z)")),"\nP. change:\t\t\(.p|tonumber)","P. change:\t\t\(.P|tonumber) %","T trade number:\t\t\(.n) trades","T. traded vol(base):\t\(.v|tonumber)","T. traded vol(quote):\t\(.q|tonumber)","\nOpen:\t\t\t\(.o|tonumber)","High:\t\t\t\(.h|tonumber)","Low:\t\t\t\(.l|tonumber)","\nWeighted avg. p.:\tP: \(.w|tonumber|round)","Last trade:\t\tP: \(.c|tonumber)\tQ: \(.Q)","Best bid:\t\tP: \(.b|tonumber)\tQ: \(.B)","Best ask:\t\tP: \(.a|tonumber)\tQ: \(.A)","Stats timeframe:\t\(((.C-.O)/1000)/(24*60*60)) day"'
exit
}

# Check for no arguments or options in input
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi

# Parse options
while getopts ":def:hjlckistuw" opt; do
  case ${opt} in
    j ) # Grab JSON
     curl -s "https://api.binance.com/api/v1/ticker/allPrices"
     exit
     ;;
     l ) # List markets (coins and respective rates)
     curl -s "https://api.binance.com/api/v1/ticker/allPrices" |
	     jq -r '.[] | "\(.symbol) = \(.price)"' |
	     column -s '=' -c10 -T 1 -e -t -N '-----MARKETS-----,-----RATE-----'
     # Make JSON with CODE and ID
     # curl -H "X-CMC_PRO_API_KEY: 29f3d386-d47d-4b54-9790-278e1faa7cdc" -H "Accept: application/json" -d "limit=5000" -G https://pro-api.coinmarketcap.com/v1/cryptocurrency/map ^C.data[] | { key: .symbol, value: .id } ] | from_entries'
     exit
     ;;
    c )
      M1OPT=1
      ;;
    d )
      M6OPT=1
      ;;
    e )
      M6EXTRAOPT=1
      ;;
    f )
      if [[ "${OPTARG}" =~ ^[0-9]+ ]]; then
	   FSTR="%.${OPTARG}f"
	   else
	   FSTR="${OPTARG}"
      fi
      ;;
    k )
      M2OPT=1
      ;;
    i )
      M3OPT=1
      ;;
    s )
      M4OPT=1
      ;;
    t )
      M7OPT=1
      ;;
    u )
      CURLOPT=1
      ;;
    w )
      M5OPT=1
      ;;
    h ) # Help
      echo ""
      echo -e "${LICENSE_WARRANTY_NOTICE}"
      echo ""
      echo "Usage:"
      echo "   binance.sh [amount] [from_crypto] [to_crypto]"
      echo "   binance.sh [options|mode] [from_crypto] [to_crypto]"
      echo ""
      echo "Options:"
      echo "  -f 	Number of decimal plates; for use with -c, -k, -s and -w only;"
      echo "      	Also accepts printf-style formatting; defaults: 2 (\"%.2f\");"
      echo "      		e.g.: -f6 ; -f\"%'.4f\""
      echo "  -h 	Show this help."
      echo "  -j 	Fetch and print JSON (for debugging, only for some opts)."
      echo "  -l 	List all markets (coin pairs and rates)."
      echo ""
      echo " View/Watch Modes"
      echo " Modes below accept currency pair (a Binance market) as argument, otherwise"
      echo " they will default to \"btc usdt\"."
      echo "  -c 	Price in columns; trade prices may overlap as screen"
      echo "     	updates if the number of orders between updates is"
      echo "      	smaller than 250 orders; prices should be updated from"
      echo "       	bottom right to top left; uses curl API."
      echo "  -k 	Colored price in columns, shows 200 orders; uses curl API."
      echo "  -d 	Order Book Depth view; depth is 10; uses websocket."
      echo "  -e	Extended Order Book Depth view; depth is 20; uses websocket."
      echo "  -i 	Detailed Information for the trade stream; uses websocket."
      echo "  -s 	Stream of trade prices; uses websocket."
      echo "  -w 	Colored stream of trade prices; uses websocket."
      echo "  -t 	24-H Ticker for a single currency pair; uses websocket."
      echo "  -u  	Uses the Curl mode of -s, -w and -i options (updates a little slower)"
      echo ""
      echo "   OBS:"
      echo "   Choose supported Binance markets!"
      echo "   You may write the code of a market instead of entering from_currency"
      echo "   and to_currency; if there is any problems, try entering each"
      echo "   currency separately."
      echo ""
      echo "   Curl API functions update a little slower, because they depend"
      echo "   on reconecting to the server repeatedly to fetch newest info,"
      echo "        whereas websocket streams updates with only one connection."
      echo ""
      echo "   This programme needs Curl, JQ , Websocat, Xargs and Lolcat to"
      echo "   work properly."
      echo "   I noticed that using the book depth functions with XTerm will cause"
      echo "   horrible memory leak after running straight for a couple of days."
      echo "   Using other terminals, for example xfce4-terminal, avoids that."
      echo ""
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))


# Arrange arguments
# If first argument does not have numbers OR isn't a  valid expression
if ! [[ "${1}" =~ [0-9] ]] ||
	[[ -z "$(printf "%s\n" "${1}" | bc -l 2>/dev/null)" ]]; then
	set -- 1 "${@:1:2}"
fi

# Sets btc as "from_currency" for market code formation
# Will not set when calling the script without any option
if [[ -z ${2} ]]; then
	set -- ${1} "btc"
fi

MARKETS="$(curl -s https://api.binance.com/api/v1/exchangeInfo | jq -r '.symbols[] | .symbol')"
if [[ -z ${3} ]] &&
	! printf "%s\n" "${MARKETS}" | grep -qi "^${2}$"; then
	set -- ${@:1:2} "USDT"
fi

## Check if input is a supported market 
if ! printf "%s\n" "${MARKETS}" | grep -qi "^${2}${3}$"; then
	printf "Not a supported market at Binance: %s%s\n" "${2}" "${3}" 1>&2
	printf "Check available markets with the \"-l\" option.\n" 1>&2
	exit 1
fi

# Viewing/Watching Modes opts
# Price in columns
if test -n "${M1OPT}"; then
	mode1 ${*}
	exit
fi
# Colored price in columns
if test -n "${M2OPT}"; then
	mode2 ${*}
	exit
fi
# Trade info
if test -n "${M3OPT}"; then
	mode3 ${*}
	exit
fi
# B&W Socket Stream
if test -n "${M4OPT}"; then
	mode4 ${*}
	exit
fi
# Colored Socket Stream
if test -n "${M5OPT}"; then
	mode5 ${*}
	exit
fi
# Book Order Depth 10
if test -n "${M6OPT}"; then
	mode6 ${*}
	exit
fi
# Book Order Depth 20
if test -n "${M6EXTRAOPT}"; then
	mode6extra ${*}
	exit
fi
# 24-H Ticker
if test -n "${M7OPT}"; then
	mode7 ${*}
	exit
fi

## Currency conversion/market rate
BRATE=$(curl -s https://api.binance.com/api/v1/ticker/price?symbol="${2^^}""${3^^}" | jq -r ".price")

printf "%s*%s\n" "${1}" "${BRATE}" | bc -l


# Dead code:
# [[ ${#2} -le 5 ]] checks the number of chars in field 2
## Make an ARRAY
#AA=$(curl -s "https://api.binance.com/api/v1/ticker/allPrices")
#AR=($(echo "$AA" | json_pp | grep symbol | sed -e 's/symbol//g' -e 's/"//g' -e 's/://g' -e 's/ //g' -e 's/,//g'))
#echo ${AR[@]}

#https://api.binance.com/api/v1/ticker/price?symbol=LTCBTC
#https://www.reddit.com/r/binance/comments/7e5vsn/how_can_i_get_a_specific_ticker_binance_api/
#$ set -- "${@:1:2}" "new" "${@:4}" -- https://stackoverflow.com/questions/4827690/how-to-change-a-command-line-argument-in-bash

