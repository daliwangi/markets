#!/bin/bash
# openx.sh - bash (crypto)currency converter
# v0.2  2019/jun/26  by mountaineerbr

## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	\033[01;36mMycurrency.sh -- MyCurrency.com API Access\033[00m


SYNOPSIS
	myc.sh \e[0;35;40m[-h|-j|-l|-v]\033[00m

	myc.sh \e[0;35;40m[-s]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY]\033[00m \
\e[0;31;40m[TO_CURRENCY]\033[00m

DESCRIPTION
	This programme fetches updated currency rates from mucurrency.net and can
	convert any amount of one supported currency into another.

	It supports 153 currency rates, not including precious metals.
 	
	No timestamp for this API. Rates update every hour.
	
	Default precision is 16. Trailing zeroes are trimmed by default.

	Usage example:
		
		(1) One Brazilian real in US Dollar:

		$ myc.sh brl

		$ myc.sh 1 brl usd

		
		(2) One Euro to Japanese yen (one-EUR-worth of JPY):
		
		$ myc.sh eur jpy


		(3) Half a Danish Krone to Chinese Yuan with 3 decimal plates (scale):

		$ myc.sh -s3 0.5 dkk cny


OPTIONS
	 	
		-h 	Show this help.

		-j 	Fetch JSON file and send to STOUT.

		-l 	List supported currencies.

		-s 	Set scale ( decimal plates ).
		
		-v 	Show this programme version.


BUGS
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
		"

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Check if you are requesting any precious metals.
if printf "%s\n" "${*}" | grep -qi -e "XAU" -e "XAG" -e "XAP" -e "XPD"; then
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
	printf "\nRates are in USD.\n"
 	printf "%s\n" "${JSON}" | jq -r '.rates[] | "\(.name) (\(.code))","Currency: \(.currency_name)","    Code: \(.currency_code)\t\(.rate)",""'
	exit
fi
## Grep currency list and rates
CJSON=$(printf "%s\n" "${JSON}" | jq '[.rates[] | { key: .currency_code, value: .rate } ] | from_entries')

## Get currency rates
FROMCURRENCY=$(printf "%s\n" "${CJSON}" | jq ".${2^^}")
TOCURRENCY=$(printf "%s\n" "${CJSON}" | jq ".${3^^}")

## Make equation and print result
printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc((%s*%s)/%s)\n" "${SCL}" "${1}" "${TOCURRENCY}" "${FROMCURRENCY}" | bc -lq





















## Dead Code
#cat TEST1 | jq -r '[.rates[] | .currency_code as $k | {"\(.currency_code)":"\(.rate)"}]'
#curl -s https://www.mycurrency.net/US.json | jq -r '[.rates[] | { key: .currency_code, value: .rate } ] | from_entries' </tmp/cur
#https://bbs.archlinux.org/viewtopic.php?pid=1851783#p1851783
## Check if JSON timestamp is within this hour
#TIMES=$(cat "${JSONF}" | jq -c ".timestamp")
#TIMEJSONDAY=$(date --date "$(date --date ${TIMES} +%F)" "+%s")
#TIMETODAY=$(date --date "$(date +%F)" "+%s")
#TIMEJSONHOUR=$(date --date "${TIMES}" "+%H")
#if [[ "${TIMEJSONDAY}" < "${TIMETODAY}" ]] || 
#	[[ "${TIMEJSONHOUR}" < "$(date +H)" ]]; then
#	curl -s "https://openexchangerates.org/api/latest.json?app_id=${APPID}&show_alternative=true" > "${JSONF}"
#fi
