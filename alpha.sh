#!/bin/bash
# AlphaAvantage Stocks (Most popular Yahoo Finance API alternative)
# v0.3-under_construction  jan/2020  by mountaineer_br


# *YOUR* (free) API Private Key
#ALPHAAPIKEY=""

##API Rate Limit: (5 API requests per minute; 500 API requests per day), 


## Manual and help
## Usage: $ alpha.sh [-opts] [symbol]
HELP_LINES="NAME
 	Alpha.sh -- Stocks and Index Rates from <alphavantage.co> API


SYNOPSIS

	alpha.sh [-dmsw] [SYMBOL]

	alpha.sh [-hlv]


DESCRIPTION
	This programme fetches updated rates for stocks and indexes from
	<alphavantage.co> APIs.

	Although there are APIs for central bank and crypto currency rates from
	<alphavantage.co>, they will not be implemented in this script.


LIMITS


API KEY
	Please create a free API key and add it to the script source-code or 
	export it as an environment variable as 'ALPHAAPIKEY'.


WARRANTY
	This programme is licensed under the GNU Public License v3 or better
	and is distributed without support or bug corrections.

	If you found this useful, consider giving me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES




OPTIONS
	-d [SYMBOL] 	Daily historical prices.
	
	-m [SYMBOL]	Monthly historical prices.

	-h 		Show this help.
	
	-j 		Debug, print json.

	-l 	  	List supported symbols.

	-s [KEYWORDS] 	Search for symbols.

	-v 	  	Show this programme version.

	-w [SYMBOL]	Weekly historical prices."




# Parse options
while getopts ":1234567890lghjs:tv" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( l ) ## List available currencies
			LIST="$(curl -s "https://currencylayer.com/site_downloads/cl-currencies-table.txt" | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' -e '/^$/d'| sed -e '$!N;s/\n/ /')"
			printf "%s\n" "${LIST}"
			printf "Currencies: %s\n" "$(($(wc -l <<<"${LIST}")-1))" 
			exit 0
			;;
		( g ) # Gram opt
			GRAMOPT=1
			;;
		( h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( j ) # Print JSON
			PJSON=1
			;;
		( s ) # Decimal plates
			SCL=${OPTARG}
			;;
		( t ) # Print Timestamp with result
			TIMEST=1
			;;
		( v ) # Version of Script
			grep -m1 '# v' "${0}"
			exit
			;;
		( \? )
			printf "Invalid option: -%s\n" "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

# Check if there is any argument
if [[ -z "${*}" ]]; then
	printf "Run with -h for help.\n" 1>&2
	exit 1
fi
# Teste se há input
test -z "${1}" && set -- "VALE"

#Check for API KEY
if [[ -z "${ALPHAAPIKEY}" ]]; then
	printf "Please create a free API key and add it to the script source-code or set it as an environment variable.\n" 1>&2
	exit 1
fi

# Search for Stock Quote Function
searchf() {
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CLJSON}"
		exit 0
	fi



	# Get JSON & Print Results
	curl -s "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${1^^}&apikey=${ALPHAAPIKEY}" |
		jq -r '.bestMatches[]| "\(."1. symbol")\t\"\(."2. name")\"\tCurrency: \(."8. currency")"'
}

pricef() {
	# Print JSON?
	if [[ -n ${PJSON} ]]; then
		printf "%s\n" "${CLJSON}"
		exit 0
	fi





	# Get Stock Price
	# Get JSON
	JSON="$(curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${1^^}&apikey=${ALPHAAPIKEY}")"
	# Check for error and try to search symbol
	if jq -r 'keys[]' <<< "${JSON}" | grep -qi err; then
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
	"Last Trade Day: \(."07. latest trading day")"' <<< "${JSON}"
}


