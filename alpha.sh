#!/bin/bash
# AlphaAvantage Stocks (Most popular Yahoo Finance API alternative)
# v0.3-under_construction  jan/2020  by mountaineer_br


# *YOUR* (free) API Private Key
#ALPHAAPIKEY=""

#some defaults
#default stock:
DEFSTOCK=TSLA

## Manual and help
## Usage: $ alpha.sh [-opts] [symbol]
HELP="NAME
 	Alpha.sh -- Stocks and Index Rates from <alphavantage.co> API


SYNOPSIS

	alpha.sh [-dmsw] [SYMBOL]

	alpha.sh [-hlv]


DESCRIPTION
	This programme fetches updated rates for stocks and indexes from
	<alphavantage.co> APIs.

	Although there are APIs for central bank and crypto currency rates from
	<alphavantage.co>, they will not be implemented in this script.
Claim your API Key
https://www.alphavantage.co/support/#api-key


API Rate Limit: (5 API requests per minute; 500 API requests per day), 
https://www.alphavantage.co/premium/

#To get raw CSV data from *some* options, uncomment next line (no promisses):

This API returns daily time series (date, daily open, daily high, daily low, daily close, daily volume) of the global equity specified, covering 20+ years of historical data.
The most recent data point is the prices and volume information of the current trading day, updated realtime. 




LIMITS


API KEY
	Please create a free API key and add it to the script source-code or 
	export it as an environment variable called 'ALPHAAPIKEY'.


WARRANTY
	This programme is licensed under the GNU Public License v3 or better
	and is distributed without support or bug corrections.

	If you found this useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES




OPTIONS
	-c 		Raw CSV data for some options (no promisses).

	-D 		Demo mode, only MSFT.

	-d [SYMBOL] 	Daily time series (historic data).
	
	-h 		Show this help.
	
	-j 		Debug, print json.

	-m [SYMBOL]	Monthly time series.

	-s [KEYWORDS] 	Search for symbols.

	-v 	  	Show this programme version.

	-w [SYMBOL]	Weekly time series."

#functions

pricef() {
	#get data
	DATA="$(${YOURAPP} "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${1^^}&apikey=${ALPHAAPIKEY}${CSVOPT}")"
	
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi

	# Check for error and try to search symbol
	if jq -r 'keys[]' <<< "${DATA}" | grep -qi err; then
		printf "Invalid symbol. Trying to search for similar symbols...\n"
		alphas "${*}"
		exit
	fi

	jq -r '."Global Quote" | "Symbol: \(."01. symbol")",
	"Price: \(."05. price")",
	"O: \(."02. open")  L: \(."04. low")  H: \(."03. high")",
	"Vol: \(."06. volume")",
	"Prev Close: \(."08. previous close")",
	"Change: \(."09. change") [\(."10. change percent")]",
	"Last Trade Day: \(."07. latest trading day")"' <<< "${DATA}"
}

#search for stock symbol
searchf() {
	#process words
	WORDS="${*// /%20}"

	#get data
	DATA="$(${YOURAPP} "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${WORDS}&apikey=${ALPHAAPIKEY}${CSVOPT}")"
	
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	
	#check for no results
	if jq -e '.bestMatches[]' <<<"${DATA}" &>/dev/null; then
		#check if stdout is open and trim column NAME
		[[ -t 1 ]] && TRIMCOL='-TNAME,REGION'
		#process data and make table
		jq -r '.bestMatches[]|
			"\(."1. symbol"),\(."2. name"),\(."3. type"),\(."4. region"),\(."5. marketOpen"),\(."6. marketClose"),\(."7. timezone"),\(."8. currency"),\(."9. matchScore")"' <<<"${DATA}" | column -et -s',' -NSYMBOL,NAME,TYPE,REGION,MOPEN,MCLOSE,TZ,CUR,SCORE ${TRIMCOL} 
	else
		printf 'No results -- %s\n' "${*}" 1>&2
		exit 1
	fi
}

tsf() {
	#time series
	#get stock/index data
	DATA="$(${YOURAPP} "https://www.alphavantage.co/query?function=TIME_SERIES_${PERIOD}&symbol=${1^^}&outputsize=full&apikey=${ALPHAAPIKEY}${CSVOPT}")"

	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${DATA}"
		exit 0
	fi
	


	#get forex data
	DATA="$(${YOURAPP} "https://www.alphavantage.co/query?function=FX_DAILY&from_symbol=${1^^}&to_symbol=${2^^}&outputsize=full&apikey=${ALPHAAPIKEY}${CSVOPT}")"


}

forexf() {
	#get currency rate
	#get data
	DATA="$(${YOURAPP} "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=${1^^}&to_currency=${2^^}&apikey=${ALPHAAPIKEY}${CSVOPT}")"
	
}

lforexf() {
	#list currencies
	
	#get data
	#physical currency  #csv file
	DATA="$(${YOURAPP} "https://www.alphavantage.co/physical_currency_list/")"

	#digital/crypto currency
	DATA2="$(${YOURAPP} "https://www.alphavantage.co/digital_currency_list/")"

}


# Parse options
while getopts ":cDdhjmsvw" opt; do
	case ${opt} in
		( c ) #CSV data
			CSVOPT='&datatype=csv'
			PJSON=1
			;;
		( D ) #demo mode
			ALPHAAPIKEY=demo
			;;
		( d ) #daily time series
			PERIOD=DAILY
			;;
		( h ) # Show Help
			printf '%s\n' "${HELP}"
			exit 0
			;;
		( j ) # Print JSON
			PJSON=1
			;;
		( m ) #montly time series
			PERIOD=MONTHLY
			;;
		( s ) #search symbols
			SOPT=1
			;;
		( v ) # Version of Script
			grep -m1 '# v' "${0}"
			exit
			;;
		( w ) #weekly time series
			PERIOD=WEEKLY
			;;
		( \? )
			printf "Invalid option: -%s\n" "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#Check for API KEY
if [[ -z "${ALPHAAPIKEY}" ]]; then
	printf "Please create a free API key and add it to the script source-code\n" 1>&2
	printf "or export it as an environment variable as per help page.\n" 1>&2
	exit 1
fi

# Test for must have packages
if ! command -v jq &>/dev/null && [[ -z "${CSVOPT}" ]]; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
if command -v curl &>/dev/null; then
	YOURAPP="curl -sL"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi

#test for any arg?
[[ -z "${1}" ]] && set -- "${DEFSTOCK}"
#demo mode
[[ "${ALPHAAPIKEY}" = 'demo' ]] && set -- MSFT

#call opt functions
if [[ -n "${SOPT}" ]]; then
	searchf "${*}"
elif [[ -n "${PERIOD}" ]]; then
	tsf "${*}"
else
	pricef "${*}"
fi

