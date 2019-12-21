#!/bin/bash
# openx.sh - bash (crypto)currency converter
# v0.2.22  2019/dec  by mountaineerbr

## Defaults
# Scale (decimal plates):
SCLDEFAULTS=16

## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	Mycurrency.sh -- MyCurrency.com API Access


SYNOPSIS
	myc.sh [-hlv]

	myc.sh [-sNUM] [AMOUNT] [FROM_CURRENCY] [TO_CURRENCY]


DESCRIPTION
	This programme fetches updated currency rates from mucurrency.net and 
	can convert any amount of one supported currency into another. It sup-
	ports 153 currency rates, not including precious metals.	
	
	Default precision is 16. No timestamp for this API, but rates update 
	every hour.


WARRANTY
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.


USAGE EXAMPLES
	(1) One Brazilian real in US Dollar:

		$ myc.sh brl

		$ myc.sh 1 brl usd

		
	(2) One thousand US Dollars in Japanese Yen:
		
		$ myc.sh 100 usd jpy
		

		Using math expression in AMOUNT:
		
		$ myc.sh '101+(2*24.5)+850' usd jpy


	(3) Half a Danish Krone in Chinese Yuan with 3 decimal 
	    plates (scale):

		$ myc.sh -s3 0.5 dkk cny


OPTIONS
	-h 	Show this help.

	-j 	Debug, print JSON.
	
	-l 	List supported currencies.
	
	-s NUM 	Scale (decimal plates).
	
	-v 	Show this programme version."

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Check if you are requesting any precious metals.
if grep -qi -e "XAU" -e "XAG" -e "XAP" -e "XPD" <<< "${*}"; then
	printf "mycurrency.com does not support precious metals.\n" 1>&2
	exit 1
fi

# Parse options
while getopts ":lhjs:tv" opt; do
  case ${opt} in
  	l ) ## List available currencies
		LISTOPT=1
		;;
	h ) # Show Help
		echo -e "${HELP_LINES}"
		exit 0
		;;
	j ) # Print JSON
		PJSON=1
		;;
	s ) # Decimal plates
		SCL=${OPTARG}
		;;
	t ) # Print Timestamp with result
		printf "No timestamp for this API. Rates update every hour.\n" 1>&2
		;;
	v ) # Version of Script
		head "${0}" | grep -e '# v'
		exit
		;;
	\? )
		printf "Invalid Option: -%s.\n" "$OPTARG" 1>&2
		exit 1
		;;
  esac
done
shift $((OPTIND -1))

## Set default scale if no custom scale
test -z "${SCL}" && SCL="${SCLDEFAULTS}"

# Set equation arquments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 ${@:1:2}
fi

if [[ -z ${3} ]]; then
set -- ${@:1:2} "USD"
fi

## Get JSON once
JSON="$(curl -s https://www.mycurrency.net/US.json)"
## Print JSON?
if [[ -n "${PJSON}" ]]; then
	printf "%s\n" "${JSON}"
	exit
fi
## List all suported currencies and USD rates?
if [[ -n ${LISTOPT} ]]; then
	# Test screen width
	# If stdout is redirected; skip this
	if ! [[ -t 1 ]]; then
		true
	else
		COLCONF="-TCOUNTRY,CURRENCY"
	fi
	printf "Rates are against USD.\n"
	jq -r '.rates[]|"\(.currency_code)/USD=\(.rate)=\(.name) (\(.code|ascii_downcase))=\(.currency_name)=\(.hits)"' <<< "${JSON}" | column -et -s'=' -N'MARKET,RATE,COUNTRY,CURRENCY,WEBHITS' ${COLCONF}
	printf "Currencies: %s.\n" "$(jq -r '.rates[].currency_code' <<< "${JSON}" | wc -l)"
	exit
fi
## Grep currency list and rates
CJSON=$(jq '[.rates[] | { key: .currency_code, value: .rate } ] | from_entries' <<< "${JSON}")

## Get currency rates
FROMCURRENCY=$(jq ".${2^^}" <<< "${CJSON}")
TOCURRENCY=$(jq ".${3^^}" <<< "${CJSON}")

## Make equation and print result
bc -l <<< "scale=${SCL};((${1})*${TOCURRENCY})/${FROMCURRENCY}"

exit

#Dead code

