#!/bin/bash
#
# openx.sh - bash (crypto)currency converter
# v0.5.6 - 2019/nov/13  by mountaineerbr


## Please make a free account and update this script
## with *your* Open Exchange Rates API ID ( app_id ).
#OPENXAPPID=""


## Some defaults
## You should not change this:
LC_NUMERIC="en_US.UTF-8"

## Copyleft / About
WARRANTY_NOTICE="NAME
\033[012;36mOpenX.sh - Bash (Crypto)Currency Converter\033[00m
      \033[012;31mCopyleft (C) 2019  mountaineerbr\033[00m


SYNOPSIS
      This program is free software: you can redistribute it and/or modify
      it under the terms of the GNU General Public License as published by
      the Free Software Foundation, either version 3 of the License, or
      (at your option) any later version.
  
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
      
      <https://www.gnu.org/licenses/>.  
     

API KEY
	Please create a free API key and add it to the script source-code or 
	set it as an environment variable as \"OPENXAPPID\".


ACCURACY
      As with all exchange rate data, accuracy can never be guaranteed when
      you're not paying through the teeth for the service - and when money
      changes currencies, everyone takes a cut. 
      
      Also see: https://openexchangerates.org/license
                https://openexchangerates.org/terms"

## Manual and help
## Usage: $ openx.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	OpenX.sh - Bash Currency Converter
		   OpenExchangeRates.org API access


SYNOPSIS
	openx.sh [amount] [from_currency] [to_currency] 

	openx.sh [-j|-t|-s] [from_code] [to_code]

	openx.sh [-h|-j|-l|-v|-w]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	A JSON file  with rates is retrieved from openexchangerates.org with a 
	personal API key. Please, create a free or buy an account and update the
	script source code with *your* API key as soon as possible. That will 
	prevent the script stop working unexpectedly or unreliably when the 
	default key access exceeds allowance.

	Openexchangerates.org offers 193 currency rates currently, including 
	alternative,  black  market  and some digital currencies. These rates 
	should not be used to perform precise forex trades, as the free plan
	updates hourly only.

	OpenX.sh uses the power of Bash Calculator and its standard mathlib for 
	floating point calculations. A value of 16 decimal plates is defaults, 
	but that precision value is easily configurable with flag \"-s\".

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 4-7).

		OZ=\"28.349523125\"

	
WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES

		(1) One Canadian Dollar in US Dollar:
		
			$ openx.sh cad usd
			
			$ openx.sh 1 cad usd
	

		(2) 100 Brazilian Real to Japanese Yen

			$ openx.sh 100 BRL JPY


		(3) Half  a Danish  Krone  to Chinese Yuan with three decimal
		    plates (scale):

			$ openx.sh -s3 0.5 dkk cny

		
		(4) \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ openx.sh \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(5) \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ openx.sh \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(6) \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ openx.sh \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(7) \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ openx.sh \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


OPTIONS
	 	-h	Show this help.

		-j	Print JSON print to stdout (useful for debugging).

		-l	List available currency codes.

		-s	Set how many decimal plates are shown. Defaults=16.
			Rounding and removal of trailing noughts is active.

	 	-w 	Show Warrantyi notice.

		-t 	Print JSON timestamp.

		-v 	Show this programme version."

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
	exit 1
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
		echo -e "${WARRANTY_NOTICE}"
		exit 0
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

#Check for API KEY
if [[ -z "${OPENXAPPID}" ]]; then
	printf "Please create a free API key and add it to the script source-code or set it as an environment variable.\n" 1>&2
	exit 1
fi

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
JSON=$(curl -s "https://openexchangerates.org/api/latest.json?app_id=${OPENXAPPID}&show_alternative=true")
## Print JSON?
if [[ -n "${PJSON}" ]]; then
	printf "%s\n" "${JSON}"
	exit 0
fi

# -l Print Currency List
if [[ -n "${LISTOPT}" ]]; then
	printf "List of supported currency codes.\n"
	jq -r ".rates|keys[]" <<< "${JSON}" | column -c 80
	printf "Website: https://docs.openexchangerates.org/docs/supported-currencies\n"
	exit 0
fi

## Check if input has supported currencies:
if ! jq -r '.rates | keys[]' <<< "${JSON}" | grep -qi "^${2}$"; then
	printf "Not a supported currency: %s\n" "${2}" 1>&2
	exit 1
fi
if ! jq -r '.rates | keys[]' <<< "${JSON}" | grep -qi "${3}"; then
	printf "Not a supported currency: %s\n" "${3}" 1>&2
	exit 1
fi

## -t Timestamp option
if [[ -n "${TIMES}" ]]; then
	TIMES=$(jq -r ".timestamp" <<< "${JSON}")
	date -d@"$TIMES" "+# %Y-%m-%dT%H:%M:%S%Z"
fi

## Get currency rates
FROMCURRENCY=$(jq ".rates.${2^^}" <<< "${JSON}" | sed 's/e/*10^/g')
TOCURRENCY=$(jq ".rates.${3^^}" <<< "${JSON}" | sed 's/e/*10^/g')

# Make currency exchange rate equation 
# and send to Bash Calculator to get results
bc -l <<< "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=${SCL}; trunc((${1}*${TOCURRENCY})/(${FROMCURRENCY}))"

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

