#!/bin/bash
#
# erates.sh -- Currency converter Bash wrapper for exchangeratesapi.io API
# v0.1.3 - 2019/ago/17
# by mountaineerbr

SCRIPTBASECUR="USD"

## Manual and help
## Usage: $ erates.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	\033[01;36mErates.sh -- Currency converter and Bash wrapper for exchangeratesapi.io API\033[00m


SYNOPSIS
	erates.sh \e[0;35;40m[-h|-l]\033[00m

	erates.sh \e[0;35;40m[-j|-s]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY]\033[00m \e[0;31;40m[TO_CURRENCY]\033[00m

DESCRIPTION
	This programme fetches updated currency rates and can convert any amount
	of one supported currency into another. It is a wrapper	for the
	exchangerates.io API.
	
	Exchangerates.io API is a free service for current and historical foreign
	exchange rates published by the European Central Bank. Check their project:
	<https://github.com/exchangeratesapi/exchangeratesapi>

	It supports 33 central bank currencies and does not include precious metals.
 	
	The reference rates are usually updated around 16:00 CET on every working
	day, except on TARGET closing days. They are based on a regular daily
	concertation procedure between central banks across Europe,
	which normally takes place at 14:15 CET.

	Even though we get the raw data with rates against the EUR, I prefer
	to check rates against USD by default (when TO_CURRENCY is not specified).
	You may change that to EUR or any other currency setting the \"SCRIPTBASECUR\"
	variable in the script source code.

	Bash Calculator uses dot for floating numbers.
	Trailing zeroes are trimmed by default.


	Usage examples:
		
		(1) One Brazilian real in US Dollar:

		$ erates.sh brl

		$ erates.sh 1 brl usd

		
		(2) One Euro to Japanese yen (one-EUR-worth of JPY):
		
		$ erates.sh eur jpy


		(3) Half a Danish Krone to Chinese Yuan with 3 decimal plates (scale):

		$ erates.sh -s3 0.5 dkk cny


OPTIONS
	 	
		-h 	Show this help.

		-j 	Print JSON file.

		-l 	List supported currencies
			and their rates agains EUR.

		-s 	Set scale (defaults=16).


WARRANTY & LICENSE
 	This programme needs latest versions of Bash, Curl and JQ to work
	properly.

	It is licensed under GPLv3 and distributed without support or bug
	corrections.

	"

## Check for some needed packages
if ! command -v curl &> /dev/null; then
	printf "%s\n" "Package not found: curl." 1>&2
	exit 1
elif ! command -v jq &> /dev/null; then
	printf "%s\n" "Package not found: jq." 1>&2
	printf "%s\n" "Ref: https://stedolan.github.io/jq/download/" 1>&2
	exit 1
fi

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Check if you are requesting any precious metals.
if printf "%s\n" "${*}" | grep -qi -e "XAU" -e "XAG" -e "XAP" -e "XPD"; then
	printf "exchangerates.io does not support precious metals.\n" 1>&2
	exit 1
fi


# Parse options
while getopts ":lhjs:t" opt; do
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
		printf "No timestamp for this API; check -h.\n" 1>&2
		;;
	\? )
		printf "%s\n" "Invalid Option: -$OPTARG" 1>&2
		exit 1
		;;
  esac
done
shift $((OPTIND -1))


## Set default scale if no custom scale
SCLDEFAULTS=16
if [[ -z ${SCL} ]]; then
	SCL=${SCLDEFAULTS}
fi

# Set equation arquments
if ! [[ ${1} =~ [0-9] ]]; then
	set -- 1 ${@:1:2}
fi

if [[ -z ${3} ]]; then
	set -- ${@:1:2} "${SCRIPTBASECUR}"
fi

## Get JSON once
JSON="$( curl -s https://api.exchangeratesapi.io/latest)"
## Print JSON?
if [[ -n "${PJSON}" ]]; then
	printf "%s\n" "${JSON}"
	exit
fi
## List all suported currencies and EUR rates?
if [[ -n ${LISTOPT} ]]; then
	printf "\nList of all supported currencies against EUR.\n\n"
	printf " Code: Rate"
 	printf "%s\n" "${JSON}" | jq -r '.rates' | tr -d '{}",' | sort
	printf "\nAlso check:\n\n"
	printf "<https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html>\n\n"
	exit
fi
## Check if request is a supported currency:
if ! [[ "${2^^}" = "EUR" ]] && ! printf "%s\n" "${JSON}" | jq -r '.rates | keys[]' | grep -qi "${2}"; then
	printf "Not a supported currency at exchangeratesapi.io: %s\n" "${2}" 1>&2
	exit 1
elif ! [[ "${3^^}" = "EUR" ]] && ! printf "%s\n" "${JSON}" | jq -r '.rates | keys[]' | grep -qi "${3}"; then
	printf "Not a supported currency at exchangeratesapi.io: %s\n" "${3}" 1>&2
	exit 1
fi

## Get currency rates
if [[ ${2^^} = "EUR" ]]; then
	FROMCURRENCY=1
else
	FROMCURRENCY=$(printf "%s\n" "${JSON}" | jq ".rates.${2^^}")
fi
if [[ ${3^^} = "EUR" ]]; then
	TOCURRENCY=1
else
	TOCURRENCY=$(printf "%s\n" "${JSON}" | jq ".rates.${3^^}")
fi

## Make equation and print result
printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc((%s*%s)/%s)\n" "${SCL}" "${1}" "${TOCURRENCY}" "${FROMCURRENCY}" | bc -l

