#!/usr/bin/bash
# AlphaAvantage Stocks (Most popular Yahoo Finance API alternative)
# v0.2  18//set/2019  by mountaineer_br


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

# API Private Key
APIKEY=E3E2JUNRAY3879MM

# Search for Stock Quote Function
alphas() {
	# Get JSON & Print Results
	curl -s "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${1^^}&apikey=${APIKEY}" |
		jq -r '.bestMatches[]| "\(."1. symbol")\t\"\(."2. name")\"\tCurrency: \(."8. currency")"'
}
## Test for search symbol function
if [[ "${1}" = "-s" ]]; then
	alphas "${*}"
	exit
fi

# Get Stock Price
# Get JSON
JSON="$(curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${1^^}&apikey=${APIKEY}")"
# Check for error and try to search symbol
if printf "%s\n" "${JSON}" | jq -r 'keys[]' | grep -qi err; then
	printf "Invalid symbol. Trying to search for similar symbols...\n"
	alphas "${*}"
	exit
fi
printf "%s\n" "${JSON}" |
	jq -r '."Global Quote" | "Symbol: \(."01. symbol")",
	"Price: \(."05. price")",
	"O: \(."02. open")  L: \(."04. low")  H: \(."03. high")",
	"Vol: \(."06. volume")",
	"Prev Close: \(."08. previous close")",
	"Change: \(."09. change") [\(."10. change percent")]",
	"Last Trade Day: \(."07. latest trading day")"'

