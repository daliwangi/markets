#!/bin/bash
#
# Clay.sh -- Currencylayer.com API Access
# v0.4.4  dec/2019  by mountaineerbr


## Get your own personal API KEY, please!
#CLAYAPIKEY=""


## Some defaults
# Number of decimal plates (scale):
SCLDEFAULTS=20   #Bash Calculator defaults is 20 (plus one uncertainty digit)

## You should not change these:
LC_NUMERIC="en_US.UTF-8"
## Troy ounce to gram ratio
TOZ='31.1034768'

## Manual and help
## Usage: $ clay.sh [amount] [from currency] [to currency]
HELP_LINES="NAME
 	Clay.sh -- Currency Converter
		   CurrencyLayer.com API Access


SYNOPSIS

	clay.sh [-tg] [-sNUM] [AMOUNT] [FROM_CURRENCY] [TO_CURRENCY]

	clay.sh [-hjlv]


DESCRIPTION
	This programme fetches updated currency rates from the internet	and can
	convert any amount of one supported currency into another.

	Free plans should get currency updates daily only. It supports very few 
	cyrpto currencies. Please, access <https://currencylayer.com/> and sign
	up for a free private API key.

	Gold and Silver are priced in Troy Ounces. It means that in each troy 
	ounce there are aproximately 31.1 grams, such as represented by the
	following constant:
		
		\"GRAM/OUNCE\" rate = 31.1034768


	Option \"-g\" will try to calculate rates in grams instead of ounces for
	precious metals (as a side note, platinum and palladium would be priced
	in regular ounces).

	Nonetheless, it is useful to learn how to do this convertion manually.
	It is useful to define a variable with the gram to troy oz ratio in your
	\".bashrc\" to work with precious metals (see usage example 10). I sug-
	gest a variable called TOZ that will contain the GRAM/OZ constant.

		TOZ=\"31.1034768\"


	Bash Calculator uses a dot \".\" as decimal separtor. Default precision
	is ${SCLDEFAULTS}, plus an uncertainty digit.


API KEY
	Please create a free API key and add it to the script source-code or set
	it as an environment variable as \"CLAYAPIKEY\".


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


USAGE EXAMPLES
		
		(1) One Canadian Dollar in US Dollar, two decimal plates:

			$ clay.sh -s2 1 cad usd

			$ clay.sh -2 cad usd


		(2) 50 Djiboutian Franc in Chinese Yuan with three decimal 
		    plates (scale):

			$ clay.sh -s3 50 djf cny


		(3)    Using grams for precious metals instead of troy ounces.

			To use grams instead of ounces for calculation precious 
			metals rates, use option \"-g\". E.g., one gram of gold 
			in USD:

				$ clay.sh -g xau usd 


			The following section explains about the GRAM/OZ cons-
			tant used in this program.

			The rate of conversion (constant) of grams by troy ounce
			may be represented as below:
			 
				GRAM/OUNCE = \"31.1034768\"
			

			
			To get \e[0;33;40mAMOUNT\033[00m of EUR in grams of Gold,
			just multiply AMOUNT by the \"GRAM/OUNCE\" constant.

				$ clay.sh \"\e[0;33;40mAMOUNT\033[00m*31.1\" eur xau 


				One EUR in grams of Gold:

				$ clay.sh \"\e[1;33;40m1\033[00m*31.1\" eur xau 



			To get \e[0;33;40mAMOUNT\033[00m of grams of Gold in EUR,
			just divide AMOUNT by the \"GRAM/OUNCE\" constant.

				$ clay.sh \"\e[0;33;40m[amount]\033[00m/31.1\" xau usd 
			

				One gram of Gold in EUR:
					
				$ clay.sh \"\e[1;33;40m1\033[00m/31.1\" xau eur 


OPTIONS
	-NUM 	  Shortcut for scale setting, same as \"-sNUM\".

	-g 	  Use grams instead of troy ounces; only for precious metals.
		
	-h 	  Show this help.

	-j 	  Debug; print JSON.

	-l 	  List supported currencies.

	-s [NUM]  Set decimal plates; defaults=${SCLDEFAULTS}.

	-t 	  Print timestamp.
	
	-v 	  Show this programme version."

# Precious metals in grams?
ozgramf() {	
	# Precious metals - ounce to gram
	#CGK does not support Platinum(xpt) and Palladium(xpd) yet,a nd thos eowuld be in regular ounces
	if [[ -n "${GRAMOPT}" ]]; then
		if grep -qi -e 'XAU' -e 'XAG' <<<"${1}"; then
			FMET=1
		fi
		if grep -qi -e 'XAU' -e 'XAG' <<<"${2}"; then
			TMET=1
		fi
		if [[ -n "${FMET}" ]] && [[ -n "${TMET}" ]] ||
			[[ -z "${FMET}" ]] && [[ -z "${TMET}" ]]; then
			unset TOZ
			unset GRAM
		elif [[ -n "${FMET}" ]] && [[ -z "${TMET}" ]]; then
			GRAM='/'
		elif [[ -z "${FMET}" ]] && [[ -n "${TMET}" ]]; then
			GRAM='*'
		fi
	else
		unset TOZ
		unset GRAM
	fi
}


# Parse options
while getopts ":1234567890lghjs:tv" opt; do
	case ${opt} in
		( [0-9] ) #scale, same as '-sNUM'
			SCL="${SCL}${opt}"
			;;
		( l ) ## List available currencies
			LIST="$(curl -s "https://currencylayer.com/site_downloads/cl-currencies-table.txt" | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//' -e '/^$/d'| sed -e '$!N;s/\n/ /')"
			printf "%s\n" "${LIST}"
			printf "Currencies: %s\n" "$(($(wc -l <<<"${LIST}")-1))" 
			exit 0
			;;
		( g ) # Gram opt
			GRAMOPT=1
			;;
		( h ) # Show Help
			echo -e "${HELP_LINES}"
			exit 0
			;;
		( j ) # Print JSON
			PJSON=1
			;;
		( s ) # Decimal plates
			SCL=${OPTARG}
			;;
		( t ) # Print Timestamp with result
			TIMEST=1
			;;
		( v ) # Version of Script
			grep -m1 '# v' "${0}"
			exit
			;;
		( \? )
			printf "Invalid option: -%s\n" "$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

# Check if there is any argument
if [[ -z "${*}" ]]; then
	printf "Run with -h for help.\n" 1>&2
	exit 1
fi

#Check for API KEY
if [[ -z "${CLAYAPIKEY}" ]]; then
	printf "Please create a free API key and set it in the script source-code or as an environment variable.\n" 1>&2
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
if [[ "${FROMCURRENCY}" =~ e ]]; then
	FROMCURRENCY=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<< "${FROMCURRENCY}")
fi
if [[ "${TOCURRENCY}" =~ e ]]; then
	TOCURRENCY=$(sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<< "${TOCURRENCY}") 
fi

## Print timestamp ?
if [[ -n ${TIMEST} ]]; then
	JSONTIME=$(jq ".timestamp" <<< "${CLJSON}")
	date -d@"$JSONTIME" "+## %FT%T%Z"
fi

# Precious metals in grams?
ozgramf "${2}" "${3}"
## Make equation and print result
bc -l <<< "scale=${SCL};((${1}*${TOCURRENCY}/${FROMCURRENCY})${GRAM}${TOZ})/1;"

