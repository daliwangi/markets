#!/bin/bash
#
# openx.sh - bash (crypto)currency converter
# v0.4 - 2019/ago/21
# by mountaineerbr

## Some defaults
## Please make a free account and update this script
## with *your* Open Exchange Rates API IDi ( app_id ).
#APPID="5b28f174f36949c68b9feb395f92bac8"
#Dev key:
#APPID="a66bbee5ac8d4ea2838074cfffde390d"
# Below are general IDs which may stop working at any time
#APPID="ab605d846f3f40fabd4db64bf2258519"
#witacecu@crypto-net.club -- https://temp-mail.org/pt/ 
#https://openexchangerates.org -- senha: hellodea
#APPID="9b87260e426e498ea5f2ecbb2fd04b4b"
#luxa@coin-link.com
#sahijowo@alltopmail.com - hellode
APPID="5b28f174f36949c68b9feb395f92bac8"

## You should not change this:
LC_NUMERIC="en_US.UTF-8"

## Copyleft / About
WARRANTY_NOTICE="
      \033[012;36mOpenX.sh - Bash (Crypto)Currency Converter\033[00m
      \033[012;31mCopyright (C) 2019  mountaineerbr\033[00m
  
      This program is free software: you can redistribute it and/or modify
      it under the terms of the GNU General Public License as published by
      the Free Software Foundation, either version 3 of the License, or
      (at your option) any later version.
  
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
      
      You should have received a copy of the GNU General Public License
      along with this program.  If not, see <https://www.gnu.org/licenses/>.  
      
      ACCURACY

      As with all exchange rate data, accuracy can never be guaranteed when
      you're not paying through the teeth for the service - and when money
      changes currencies, everyone takes a cut. 
      
      Also see: https://openexchangerates.org/license
                https://openexchangerates.org/terms
         "

## Manual and help
## Usage: $ openx.sh [amount] [from currency] [to currency]
HELP_LINES="
NAME
 	\033[01;36mOpenX.sh - Bash (Crypto)Currency Converter\033[00m


SYNOPSIS
	openx.sh [-j|-t|-s] \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY]\033[00m \
\e[0;31;40m[TO_CURRENCY]\033[00m 

	openx.sh [-j|-t|-s] \e[0;31;40m[CURRENCY]\033[00m
	      Will default to pair with USD

	openx.sh [-h|-j|-l|-v|-w]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one currency into another.

	A JSON file is retrieved from openexchangerates.org through an API and 
	ap_id access key code. Please, create a free or buy an account and up-
	date the script code with *your* app_id as soon as possible. That will 
	avoid the script stop working unexpectedly or unreliably when the 
	default key access exceeds allowance.

	Openexchangerates.org offers 193 currency rates currently, including 
	alternative, black market and some digital currencies. The rates should not 
	be used to perform precise forex trades, as the	free plan updates hourly.

	This programme can be considered merely a wrapper for the above-mentioned
	website for use in Bash.

	OpenX.sh uses the power of Bash Calculator and its standard mathlib for 
	floating point calculations. Precision of currency rates differs in the 
	number of decimal plates available. A value of sixteen decimal plates is
	defaults, but it is easily configurable with flag \"-s\".

		Usage examples:	


		(1) One Canadian Dollar in US Dollar:
		
			$ openx.sh CAD USD
			
			$ openx.sh 1 cad usd
	

		(2) 100 Brazilian Real to Japanese Yen

			$ openx.sh 100 BRL JPY


		(3) Half a Danish Krone to Chinese Yuan with 3 decimal plates (scale):

			$ openx.sh -s3 0.5 dkk cny


		(4) 1 gram of GOLD in USD:
					
			$ openx.sh \"1/28.3495\" xau usd 
			
			    1/28.3495 is the rate of one gram/ounce.


		(5) \e[0;33;40m100\033[00m grams of GOLD in EUR:
					
			$ openx.sh \"(1/28.3495)\e[0;33;40m*100\033[00m\" xau eur 
			

OPTIONS


	 	-h	Show this help.

		-j	Print JSON print to stdout (useful for debugging).

		-l	List available currency codes.

		-s	Set how many decimal plates are shown. Defaults=8.
			Rounding and removal of trailing noughts is active.
			If you are converting very small amounts of a currency,
			try changing scale to a big number such as 10 or 20.

	 	-w 	Show Warrantyi notice.

		-t 	Print JSON timestamp.

		-v 	Show this programme version.


BUGS
	Made and tested solely with Bash 5.0.007-1. It should also work at
	least with Bash 4.2 ( partially tested ).
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
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


# Parse options
while getopts ":lhjs:tvw" opt; do
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
		TIMES=1
		;;
	w ) # Warrant notice
		echo ""
		echo -e "${WARRANTY_NOTICE}"
		echo ""
		exit
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

## Check for some needed packages
if ! command -v curl &> /dev/null; then
	printf "%s\n" "Package not found: curl." 1>&2
	exit 1
elif ! command -v jq &> /dev/null; then
	printf "%s\n" "Package not found: jq." 1>&2
	printf "%s\n" "Ref: https://stedolan.github.io/jq/download/" 1>&2
	exit 1
fi

## Check for internet connection
if ! ping -q -w7 -c1 8.8.4.4 &> /dev/null ||
	! ping -q -w7 -c1 8.8.8.8 &> /dev/null; then
	printf "No internet connection.\n"
	exit
fi

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

## Grep JSON from server
JSON=$(curl -s "https://openexchangerates.org/api/latest.json?app_id=${APPID}&show_alternative=true")
## Print JSON?
if [[ -n "${PJSON}" ]]; then
	printf "%s\n" "${JSON}"
	exit
fi

# -l Print Currency List
if [[ -n "${LISTOPT}" ]]; then
	printf "\nList of supported currency codes.\n\n"
	printf "%s\n" "${JSON}" | jq -r ".rates|keys[]" |
		column -c 80
	printf "\nWebsite: https://docs.openexchangerates.org/docs/supported-currencies\n\n"
	exit
fi

## Check if input has supported currencies:
if ! printf "%s\n" "${JSON}" | jq -r '.rates | keys[]' | grep -qi "^${2}$"; then
	printf "Not a supported currency: %s\n" "${2}" 1>&2
	exit 1
fi
if ! printf "%s\n" "${JSON}" | jq -r '.rates | keys[]' | grep -qi "${3}"; then
	printf "Not a supported currency: %s\n" "${3}" 1>&2
	exit 1
fi

## -t Timestamp option
if [[ -n "${TIMES}" ]]; then
	TIMES=$(printf "%s\n" "${JSON}" | jq -c ".timestamp")
	date -d@"$TIMES" "+# %Y-%m-%dT%H:%M:%S(%Z)"
fi

## Get currency rates
FROMCURRENCY=$(printf "%s\n" "${JSON}" | jq ".rates.${2^^}")
TOCURRENCY=$(printf "%s\n" "${JSON}" | jq ".rates.${3^^}")
#echo "${TOCURRENCY}" "${FROMCURRENCY}"

# Make currency exchange rate equation 
# and send to Bash Calculator to get results
printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc((%s*%s)/%s)\n" "${SCL}" "${1}" "${TOCURRENCY}" "${FROMCURRENCY}" | bc -l

exit
#
# Ref:
# printf formatting
# https://docs.openexchangerates.org/
# https://techantidote.com/how-to-get-real-time-currency-exchange-rates-in-your-linux-terminal/
# https://stackoverflow.com/questions/8008546/remove-unwanted-character-using-awk-or-sed
# ? - awk ref missing -- it basically prints column number 2
# Search Array with grep: https://stackoverflow.com/questions/26675681/how-to-check-the-exit-status-using-an-if-statement-using-bash
# https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash/806923  #grep regex of decimal numbers
# https://stackoverflow.com/questions/28957568/check-whether-input-is-number-or-not-in-bash
# https://stackoverflow.com/questions/4827690/how-to-change-a-command-line-argument-in-bash  #change arguments $1 $2..
# https://askubuntu.com/questions/441208/how-to-change-the-value-of-an-argument-in-a-script
# https://www.tldp.org/LDP/abs/html/nestedifthen.html -- Nested if statements
#
#
# █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
#  █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
#   █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
#  █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
# █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
#  █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░
#   █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░ █▓▒░

