#!/bin/bash
# AlphaAvantage Stocks (Most popular Yahoo Finance API alternative)
# v0.2.2  29/oct/2019  by mountaineer_br


# *YOUR* (free) API Private Key
#ALPHAAPIKEY=""


##API Rate Limit: (5 API requests per minute; 500 API requests per day), 
# Teste se há input
test -z "${1}" && set -- "VALE"
# Test for Help
if [[ "${1}" = "-h" ]]; then
	printf "Usage\n"
	printf "  Get Rate:      alpha.sh [stock_symbol]\n"
	printf "  Search Symbol: alpha.sh -s [name]\n"
	exit 0
fi

#Check for API KEY
if [[ -z "${ALPHAAPIKEY}" ]]; then
	printf "Please create a free API key and add it to the script source-code.\n" 1>&2
	exit 1
fi

# Search for Stock Quote Function
alphas() {
	# Get JSON & Print Results
	curl -s "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${1^^}&apikey=${ALPHAAPIKEY}" |
		jq -r '.bestMatches[]| "\(."1. symbol")\t\"\(."2. name")\"\tCurrency: \(."8. currency")"'
}
## Test for search symbol function
if [[ "${1}" = "-s" ]]; then
	alphas "${*}"
	exit
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

