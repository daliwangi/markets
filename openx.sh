#!/bin/bash
#
# openx.sh - bash (crypto)currency converter
# v0.3.17 - 2019/ago/17
# by mountaineerbr

## Some defaults
## Please make a free account and update this script
## with *your* Open Exchange Rates API IDi ( app_id ).
#APPID=""
#Dev key:
#APPID="a66bbee5ac8d4ea2838074cfffde390d"
# Below are general IDs which may stop working at any time
#APPID="ab605d846f3f40fabd4db64bf2258519"
#witacecu@crypto-net.club -- https://temp-mail.org/pt/ 
#https://openexchangerates.org -- senha: hellodear
APPID="9b87260e426e498ea5f2ecbb2fd04b4b"
#luxa@coin-link.com

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
	openx.sh \e[0;33;40m[AMOUNT]\033[00m \e[0;32;40m[FROM_CURRENCY]\033[00m \
\e[0;31;40m[TO_CURRENCY]\033[00m \e[0;35;40m[-t|-v]\033[00m

	openx.sh \e[0;31;40m[CURRENCY]\033[00m \e[0;35;40m[-t|-v]\033[00m

	openx.sh \e[0;35;40m[-h|-l|show c|show w|--version]\033[00m


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

			$ openx.sh 0.5 dkk cny -s3


OPTIONS
	Due to how this programme was written, flags \"-t\" and \"-v\" must be passed 
	*after* currency arguments. These can be combined in one single flag \"-tv\". 
		
	 	-h or --help
	 		Show this help.

		-j or --json
			Print JSON print to stdout (useful for debugging).

		-l or --list
			List available currency codes.

		-s or --scale=
			Set how many decimal plates are shown. Defaults=8.
			Rounding and removal of trailing noughts is active.
			If you are converting very small amounts of a currency,
			try changing scale to a big number such as 10 or 20.

	 	show c  Try to retrieve and show the GPLv3.

	 	show w  Show Warranty / About page.

		-t 	Print currency rate timestamp (from JSON).

		-v or --verbose
			Print result and currency equation.
			This option is not affected by the scale ( SCL ) setting.

		--version 	Show this programme version.


BUGS
	Made and tested solely with Bash 5.0.007-1. It should also work at
	least with Bash 4.2 ( partially tested ).
 	This programme is distributed without support or bug corrections.
	Licensed under GPLv3 and above.
		"

## Make sure typed currencies match strings in this array
CURRENCIES=(AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD
	BND BOB BRL BSD BTC BTN BTS BWP BYN BZD CAD CDF CHF CLF CLP CNH CNY COP
	CRC CUC CUP CVE CZK DASH DJF DKK DOGE DOP DZD EAC EGP EMC ERN ETB ETH
	EUR FCT FJD FKP FTC GBP GEL GGP GHS GIP GMD GNF GTQ GYD HKD HNL HRK HTG
	HUF IDR ILS IMP INR IQD IRR ISK JEP JMD JOD JPY KES KGS KHR KMF KPW KRW
	KWD KYD KZT LAK LBP LD LKR LRD LSL LTC LYD MAD MDL MGA MKD MMK MNT MOP
	MRO MRU MUR MVR MWK MXN MYR MZN NAD NGN NIO NMC NOK NPR NVC NXT NZD OMR
	PAB PEN PGK PHP PKR PLN PPC PYG QAR RON RSD RUB RWF SAR SBD SCR SDG SEK
	SGD SHP SLL SOS SRD SSP STD STN STR SVC SYP SZL THB TJS TMT TND TOP TRY
	TTD TWD TZS UAH UGX USD UYU UZS VEF VEF_BLKMKT VEF_DICOM VEF_DIPRO VES
	VND VTC VUV WST XAF XAG XAU XCD XDR XMR XOF XPD XPF XPM XPT XRP YER ZAR
	ZMW ZWL)

## Decimal plates
## Please define below the default number
## of decimal plates ( scale of floating numbers )
SCLDEFAULTS=16
if printf "%s\n" "${*}" | grep "\-\-scale=" &> /dev/null ||
	printf "%s\n" "${*}" | grep "\-s" &> /dev/null; then
	SCL=$(printf "%s\n" "${*}" | sed -n -e 's/.*\(--scale=[0-9]*\).*/\1/p' -e 's/.*\(-s[0-9]*\).*/\1/p' | grep -o "[0-9]*")
	set -- $(printf "%s\n" "${*}" | sed -e 's/--scale=[0-9]*//g' -e 's/-s[0-9]*//g')
fi
if [[ -z ${SCL} ]]; then
	SCL=$(printf "%s\n" "${SCLDEFAULTS}")
fi

## Functions relative to the Copyright notice
## and access to the Gnu Public License version 3
if [[ ${*,,} = "show w" ]]; then
	echo -e "${WARRANTY_NOTICE}"
	exit
elif [[ ${*,,} = "show c" ]] && 
	ping -q -w8 -c1 8.8.4.4 &> /dev/null; then
	curl --connect-timeout 10  --fail \
		https://www.gnu.org/licenses/gpl-3.0.txt
	printf "\n"
	exit
elif [[ ${*,,} = "show c" ]]; then
	echo -e "${WARRANTY_NOTICE}"
	exit
elif [[ -z ${*} ]]; then
	printf "Run with -h or --help\n"
	exit
elif [[ ${1,,} = "-h" || ${1,,} = "--help" ||
	${2,,} = "-h" || ${2,,} = "--help" ||
	${3,,} = "-h" || ${3,,} = "--help" ||
	${4,,} = "-h" || ${4,,} = "--help" ||
	${5,,} = "-h" || ${5,,} = "--help" ||
	${6,,} = "-h" || ${6,,} = "--help" ]]; then
 	echo -e "${HELP_LINES}\n\n${WARRANTY_NOTICE}" | less
	if [[ ${APPID} = "ab605d846f3f40fabd4db64bf2258519" ]] ||
		[[ ${APPID} = "9b87260e426e498ea5f2ecbb2fd04b4b" ]]; then
		printf "\e[1;33;44mKindly update script with your openexchangerates.org app_id\033[00m\n"
	exit
	fi
	exit
elif [[ ${*,,} = "-l" || ${*,,} = "--list" ]]; then
	printf "\n%s\n\n" "${CURRENCIES[*]}"
	printf "You may need to add a currency symbol manually within the\n"
	printf "array CURRENCIES inside this script source code.\n"
	printf "Check website: https://docs.openexchangerates.org/docs/supported-currencies\n"
	exit
elif [[ ${*} = "--version" ]]; then
	head "${0}" | grep -e '# v'
	exit
fi

## Check for internet connection
if ! ping -q -w7 -c1 8.8.4.4 &> /dev/null ||
	! ping -q -w7 -c1 8.8.8.8 &> /dev/null; then
	printf "No internet connection.\n"
	exit
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

## Some more options that require internet and other options
if [[ ${*,,} = "-j" || ${*,,} = "--json" ]]; then
	curl -s "https://openexchangerates.org/api/latest.json?app_id=${APPID}&show_alternative=true"
	printf "\n"
	exit
elif [[ ${*} = "-v" ]]; then
	printf "Useless --verbose mode without further parameters.\n"
	exit
fi

## Functions to prepare a variable with JSON file
getjson() {
	JSON=$(curl -s "https://openexchangerates.org/api/latest.json?app_id=${APPID}&show_alternative=true")
}
## Timestamp functions
grepts() {
	if [[ -n ${JSON} ]]; then
		TIMES=$(printf "%s\n" "${JSON}" | jq -c ".timestamp")
		date -d@"$TIMES" "+# %d/%b/%Y%n# %T (%Z)"
	fi
}
greptsverbose() {
	if [[ -n ${JSON} ]]; then
		TIMESVERBOSE=$(printf "%s\n" "${JSON}" | jq -c ".timestamp")
		date -d@"$TIMESVERBOSE" "+%n%d-%B-%Y (%A)%n%Hh %Mmin %Ssec (%Z)"
	fi
}
# One liner: cat JSON2 | grep timestamp | sed -e 's/"timestamp"://g' -e 's/,//g' | { read gmt ; date -d@"$gmt" ;}

## Check syntax and if only one curency is especified
## then how much of it is at parity with one US-dollar.
## Otherwise, try to set syntax for other conversions.
if [[ ${1^^} = "USD" ]] &&
	[[ -z ${2} || ${2,,} = --verbose || 
	${2,,} = -t || ${2,,} = -v ||
	${2,,} = -tv || ${2,,} = -vt ]]; then
	printf "Base currency is USD = 1\n"
	exit
elif printf "%s\n" "${CURRENCIES[@]}" | grep -x -q -- "${1^^}" &> /dev/null &&
	[[ -z ${2} || ${2,,} = -t ]] &&
	! [[ ${3,,} = -v || ${3,,} = --verbose ]]; then
	getjson
	if [[ ${2,,} = -t ]]; then
		grepts
	fi
	GREPCURRENCY=$(printf "%s\n" "${JSON}" | jq -c ".rates | .${1^^}")
	GREPCURRENCYSCL=$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc(%s/1)\n" "${SCL}" "${GREPCURRENCY}" | bc -lq )
	printf "%s\n" "${GREPCURRENCYSCL}"
	exit
elif printf "%s\n" "${CURRENCIES[@]}" | grep -x -q -- "${1^^}" &> /dev/null &&
	 ! printf "%s\n" "${CURRENCIES[@]}" | grep -x -q -- "${2^^}" &> /dev/null &&
	[[ ${2,,} = -v || ${2,,} = --verbose ||
	   ${2,,} = -vt || ${2,,} = -tv ||
	   ${3,,} = -v || ${3,,} = --verbose ]]; then
	getjson
	if [[ ${2,,} = -t || ${3,,} = -t ||
	        ${2,,} = -vt || ${2,,} = -tv ]]; then
		greptsverbose
	fi
	GREPCURRENCY=$(printf "%s\n" "${JSON}" | jq -c ".rates | .${1^^}")
	GREPCURRENCYSCL=$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc(%s/1)\n" "${SCL}" "${GREPCURRENCY}" | bc -lq )
	printf "\nUSD = %s %s\n\n" "${GREPCURRENCYSCL}" "${1^^}"
	exit
elif ! [[ ${*} =~ [0-9] ]]; then
		set -- 1 "${@:1:5}"
fi

# Setting static USD value for 1.
# Set do not download JSON file more often than needed.
if [[ ${2^^} = USD ]]; then
	FROMCURRENCY=1
elif printf "%s\n" "${CURRENCIES[@]}" | grep -x -q -- "${2^^}" &> /dev/null; then
	getjson
	FROMCURRENCY=$(printf "%s\n" "${JSON}" | jq -c ".rates | .${2^^}")
else
	printf "Currency %s not available.\n" "${2^^}"
	exit
fi


if [[ ${3,,} = -v || ${3,,} = -t || ${3,,} = -vt || ${3,,} = -tv ]]; then
	printf "TO_CURRENCY not set.\n"
	exit
elif [[ ${3^^} = USD ]]; then
	TOCURRENCY=1
elif printf "%s\n" "${CURRENCIES[@]}" | grep -x -q -- "${3^^}" &> /dev/null; then
	if [[ -z $JSON ]]; then
		getjson
	fi
	TOCURRENCY=$(printf "%s\n" "${JSON}" | jq -c ".rates | .${3^^}")
elif [[ -n ${3} ]] && ! [[ ${3,,} = -v || ${3,,} = -t || ${3,,} = -vt || ${3,,} = -tv ]]; then
	printf "Currency %s not available.\n" "${3^^}"
	exit
else
	printf "TO_CURRENCY not set.\n"
	exit
fi

## Make sure "," does not cause errors
AMOUNT=$(printf "%s\n" "${1}" | sed 's/,/./g')
set -- "${AMOUNT}" "${@:2:5}"

# Make currency exchange rate equation 
# and send to Bash Calculator to get results
CALC=$(printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; scale=%s; trunc((%s*%s)/%s)\n" "${SCL}" "${1}" "${TOCURRENCY}" "${FROMCURRENCY}" | bc -lq)

## Choose how the calculated value will be shown
if ! [[ ${4,,} = -v || ${4,,} = --verbose ||
	${4,,} = -vt || ${4,,} = -tv ||
	${5,,} = -v || ${5,,} = --verbose ||
	${5,,} = -vt || ${5,,} = -tv ]]; then
	## Check for timestamp flag
	if [[ ${4,,} = -t || ${4,,} = -vt || ${4,,} = -tv ]]; then
	## Get a simpler timestamp
		grepts
	fi
	## Print the calculated value of the conversion
	printf "%s\n" "${CALC}"
else
	## Check for timestamp flag
	if [[ ${4,,} = -t || ${4,,} = -vt || ${4,,} = -tv ]];	then
	## Get a more verbose timestamp
		greptsverbose
	fi
	## Print the calculated value & equation
	printf "\n%'f %s = %'f %s\n\n" "${1}" "${2^^}" "${CALC}" "${3^^}"
fi
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

