#!/bin/bash
#
# Clay.sh -- Currencylayer.com API Access
# v0.3.8  2019/nov/29  by mountaineerbr

## Get your own personal API KEY, please!
#CLAYAPIKEY=""

## Some defaults
SCLDEFAULTS=8
## You should not change this:
LC_NUMERIC="en_US.UTF-8"

## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	Clay.sh -- Currency Converter
		   CurrencyLayer.com API Access


SYNOPSIS

	clay.sh [-t] [sNUM] [AMOUNT] [FROM_CURRENCY] [TO_CURRENCY]

	clay.sh [-hjlv]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Free plans should get currency updates daily only. It supports very few 
	cyrpto currencies. Please, access <https://currencylayer.com/> and sign
	up for a free private API key.

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 4-7).

		OZ=\"28.349523125\"

	
	Bc uses a dot as decimal separtor. Default precision is 8.


API KEY
	Please create a free API key and add it to the script source-code or set
	it as an environment variable as \"CLAYAPIKEY\".


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


		(5) \e[1;33;40mOne\033[00m EUR in grams of Gold:
					
			$ clay.sh \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(6) \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ clay.sh \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(7) \e[1;33;40mOne\033[00m gram of Gold in EUR:
					
			$ clay.sh \"\e[1;33;40m1\033[00m/28.3495\" xau eur 


OPTIONS
		-h 	Show this help.

		-j 	Debug; print JSON.

		-l 	List supported currencies.

		-s 	Set decimal plates; defaults=8.

		-t 	Print timestamp.
		
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

#Check for API KEY
if [[ -z "${CLAYAPIKEY}" ]]; then
	printf "Please create a free API key and add it to the script source-code or set it as an environment variable.\n" 1>&2
	exit 1
fi


## Set default scale if no custom scale
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
CLJSON="$(curl -s "http://www.apilayer.net/api/live?access_key=${CLAYAPIKEY}")"

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

## Print timestamp ?
if [[ -n ${TIMEST} ]]; then
	JSONTIME=$(jq ".timestamp" <<< "${CLJSON}")
	date -d@"$JSONTIME" "+## %FT%T%Z"
fi

## Make equation and print result
bc -l <<< "scale=${SCL};(${1}*${TOCURRENCY})/${FROMCURRENCY};"

