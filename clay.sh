#!/usr/bin/bash
#
# Clay.sh -- Currencylayer.com API Access
# v0.3.1  2019/set/25  by mountaineerbr

## Some defaults
# Get your own personal API KEY, please!
#APIKEY=""
# Dev keys
#APIKEY="6f72de44bee2e5411640f522437e9a64"
# Spare Key:
#APIKEY="35324a150b81290d9fb15e434ed3d264"
# somabal@emailate.com -- hellodear
#João silva piruto@hd-mail.com "**g*h*"https://temp-mail.org
#APIKEY="eda835237fd59b44e8d03c2df80a6a00"
#ForFriends Friendz --sahijowo@alltopmail.com-- hellodr
APIKEY="e2b3e4e50fae3bcfa7c9cd43abb84541"

## You should not change this:
LC_NUMERIC="en_US.UTF-8"

## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	Clay.sh -- Currency Converter
		   CurrencyLayer.com API Access


SYNOPSIS
	clay.sh [options] [from_currency] [to_currency]

	clay.sh [-s|-t] [amount] [from_currency] [to_currency]

	clay.sh [-h|-j|-l|-v]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Free plans should get currency updates daily only. It supports very few 
	cyrpto currencies. Please, access <https://currencylayer.com/> and sign
	up for a free private API key and change it in the script source code 
	(look for variable APIKEY), as the script default API key may stop wor-
	king at any moment and without warning!

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 4-7).

		OZ=\"28.349523125\"

	
	Default precision is 16. Trailing zeroes are trimmed by default.



WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES
		
		(1) One Brazilian real in US Dollar:

			$ clay.sh brl

			$ clay.sh 1 brl usd


		(2) One US Dollar in Brazilian Real:

			$ clay.sh usd brl


		(3) 50 Djiboutian Franc in Chinese Yuan with three decimal 
		    plates (scale):

			$ clay.sh -s3 50 djf cny
		

		(4) \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ clay.sh \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(5) \e[1;33;40m1\033[00m EUR in grams of Gold:
					
			$ clay.sh \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(6) \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ clay.sh \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(7) \e[1;33;40m1\033[00m gram of Gold in EUR:
					
			$ clay.sh \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


OPTIONS
		-h 	Show this help.

		-j 	Print JSON to stdout (useful for debugging).

		-l 	List supported currencies.

		-s 	Set scale ( decimal plates ).

		-t 	Print JSON timestamp.
		
		-v 	Show this programme version."

# Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi
# Parse options
while getopts ":lhjs:tv" opt; do
  case ${opt} in
  	l ) ## List available currencies
		curl -s "https://currencylayer.com/site_downloads/cl-currencies-table.txt" | 
			sed -e 's/<[^>]*>//g' |
			sed '1d'| sed -e 's/^[ \t]*//' |
			sed '$!N;s/\n/ /' | awk 'NF'
		exit 0
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
		TIMEST=1
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
	set -- 1 "${@:1:2}"
fi

if [[ -z ${3} ]]; then
set -- "${@:1:2}" "USD"
fi

## Get JSON once
cljsonf() {
	CLJSON=$(curl -s http://www.apilayer.net/api/live?access_key=${APIKEY}&callback=CALLBACK_FUNCTION)
}
cljsonf

# Test and try a different APIKEY
#if printf "%s\n" "${CLJSON}" | grep -iq '"success":false'; then
#	APIKEY="6f72de44bee2e5411640f522437e9a64"
#	cljsonf
#fi

# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${CLJSON}"
	exit 0
fi

## Get currency rates
if ! [[ ${2^^} = USD && ${3^^} = USD ]]; then
	FROMCURRENCY=$(jq ".quotes.USD${2^^}" <<< "${CLJSON}")
	TOCURRENCY=$(jq ".quotes.USD${3^^}" <<< "${CLJSON}")
elif [[ ${2^^} = USD ]]; then
	FROMCURRENCY=1
	TOCURRENCY=$(jq ".quotes.USD${3^^}" <<< "${CLJSON}")
elif [[ ${3^^} = USD ]]; then
	FROMCURRENCY=$(jq ".quotes.USD${2^^}" <<< "${CLJSON}")
	TOCURRENCY=1
fi

## Transform "e" to "*10^" in rates
if grep -q "e" <<< "${FROMCURRENCY}"; then
	FROMCURRENCY=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<< "${FROMCURRENCY}")
	if [[ ${SCL} < 6 ]]; then
		SCL=10
		printf "%s\n" "Scale changed to 10." 1>&2
	fi
fi
if grep -q "e" <<< "${TOCURRENCY}"; then
	TOCURRENCY=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<< "${TOCURRENCY}") 
	if [[ ${SCL} < 6 ]]; then
		SCL=10
		printf "%s\n" "Scale changed to 10." 1>&2
	fi
fi

## Print JSON timestamp ?
if [[ -n ${TIMEST} ]]; then
	JSONTIME=$(jq ".timestamp" <<< "${CLJSON}")
	date -d@"$JSONTIME" "+## %FT%T%Z"
fi

## Make equation and print result
bc -l <<< "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=${SCL}; trunc((${1}*${TOCURRENCY})/${FROMCURRENCY})"

