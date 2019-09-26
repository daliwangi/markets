#!/usr/bin/bash
#
# Clay.sh -- Currencylayer.com API Access
# v0.3  2019/set/25  by mountaineerbr

## Some defaults
# Get your own personal API KEY
#APIKEY=""
# Dev key:
#APIKEY="6f72de44bee2e5411640f522437e9a64"
# Spare Key:
#APIKEY="35324a150b81290d9fb15e434ed3d264"
# somabal@emailate.com -- hellodear
#João silva piruto@hd-mail.com "**g*h*"https://temp-mail.org
#APIKEY="eda835237fd59b44e8d03c2df80a6a00"
#ForFriends Friendz --sahijowo@alltopmail.com-- hellodr
APIKEY="e2b3e4e50fae3bcfa7c9cd43abb84541"


## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	\033[01;36mClay.sh -- Currencylayer.com API Access\033[00m


SYNOPSIS
	clay.sh \e[0;35;40m[-h|-j|-l|-v]\033[00m

	clay.sh \e[0;35;40m[-s|-t]\033[00m \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY]\033[00m \
\e[0;31;40m[TO_CURRENCY]\033[00m

DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Free plans should get currency updates daily only. It supports very few 
	cyrpto currencies. You may want to access <https://currencylayer.com/>
	and sign up for a free private API key and change it in the script source
	code (look for variable APIKEY), as the script default API key may start 
	stop wrking at any moment and without warning!

	Gold and other metals are priced in Ounces.
		
		\"Gram/Ounce\" rate: 28.349523125


	It is also useful to define a variable OZ in your \".bashrc\" to work 
	with precious metals (see usage examples 3-6).

		OZ=\"28.349523125\"

	
	Default precision is 16. Trailing zeroes are trimmed by default.


USAGE EXAMPLES
		
		(1) One Brazilian real in US Dollar:

			$ clay.sh brl

			$ clay.sh 1 brl usd


		(2) Fifty a Djiboutian Franc in Chinese Yuan with 3 decimal plates (scale):

			$ clay.sh -s3 50 djf cny
		

		(3) \e[0;33;40m[Amount]\033[00m of EUR in grams of Gold:
					
			$ cgk.sh \"\e[0;33;40m[amount]\033[00m*28.3495\" eur xau 

			    Just multiply amount by the \"gram/ounce\" rate.


		(4) \e[1;33;40m1\033[00m EUR in grams of Gold:
					
			$ clay.sh \"\e[1;33;40m1\033[00m*28.3495\" eur xau 


		(5) \e[0;33;40m[Amount]\033[00m (grams) of Gold in USD:
					
			$ clay.sh \"\e[0;33;40m[amount]\033[00m/28.3495\" xau usd 
			
			    Just divide amount by the \"gram/ounce\" rate.

		
		(6) \e[1;33;40m1\033[00m gram of Gold in EUR:
					
			$ clay.sh \"\e[1;33;40m1\033[00m/28.3495\" xau eur 




WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


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
		curl -s https://currencylayer.com/site_downloads/cl-currencies-table.txt | 
			sed -e 's/<[^>]*>//g' |
			sed -e 's/^[ \t]*//' |
			sed '/^$/d'
		exit
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

