#!/bin/bash
# v0.1.2  14/oct/2019

# You can create a blockchair.com API key for more requests/min
#CHAIRKEY="?key=MYSECRETKEY"

# Help -- run with -h
HELP="This script uses Vanitygen to generate an address and its private key.
It then checks for at least one received transaction at the public address. 
If a transaction is detected, even if the balance is currently nought, a copy 
of the generated private key and its public address will be printed in the 
screen and logged to ~/ADDRESS.

It uses two APIs: blockchain.info and blockchair.com. if you want to try
and use only blockchain.info, use option \"-b\".

Required packages are: Bash, Vanitygen, OpenSSL, Pcre and JQ.


Blockchain.info rate limits, from Twitter 2013:

	\"Developers: API request limits increased to 28,000 requests per 8 hour
	period and 600 requests per 5 minute period.\"


Blockchair.com API docs:

	\"Since the introduction of our API more than two years ago it has been free to use in both non-commercial and commercial cases with a limit of 30 requests per minute.\"

	It seems that you can create a blockchair.com API key for more requests
	/min. Add it to the CHAIRKEY variable in the script source code.


Options:
	-b 	Use only the blockchain.info API.

	-c 	Use only the blockchair.com API.

	-d 	Debug, prints server response on error.

	-h 	Show this help.

	-s 	Sleep time (seconds) between new queries; defaults=10.

	-v 	Print this script version."


# Must have vanitygen
if ! command -v vanitygen >/dev/null; then
	printf "Vanitygen is required.\n" 1>&2
	exit 1
fi
# Must have cURL or Wget
if command -v curl >/dev/null; then
	MYAPP="curl -s"
elif command -v wget >dev/null; then
	MYAPP="wget -qO-"
else
	printf "cURL or Wget is required.\n" 1>&2
	exit 1
fi
if ! command -v jq >/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi
# DEFAULTS
# Pay attention to rate limit: 
#  Developers: API request limits increased to 28,000 requests per 8 hour period 
#  and 600 requests per 5 minute period.
#  1:27 PM · Oct 11, 2013 -- Twitter @blockchain
SLEEPTIME="10"

# Parse options
while getopts ":cbdhs:v" opt; do
	case ${opt} in
		b ) # Use only Blockchain.info
			BINFOOPT=1
			;;
		c ) # Use only Blockchair.com
			CHAIROPT=1
			;;
		h ) # Help
			head "${0}" | grep -e '# v'
			echo -e "${HELP}"
			exit 0
			;;
		v ) # Version of Script
			head "${0}" | grep -e '# v'
			exit 0
			;;
		s ) # Sleep time
			SLEEPTIME="${OPTARG}"
			;;
		d ) # Debug
			DEBUG=1
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	 esac
done
shift $((OPTIND -1))

# Option handling
if [[ -n "${BINFOOPT}" ]] && [[ -n "${CHAIROPT}" ]]; then
	unset BINFOOPT
	unset CHAIROPT
fi

#Functions
queryf() {
	# Choose resquesting between blockchain.info or blockchair.com (or blockcypher.com -- need to set up)
	if [[ -z "${CHAIROPT}" ]] && { [[ -n "${BINFOOPT}" ]] || [[ $((${N: -1}%2)) -eq 0 ]];}; then
		QUERY="$(${MYAPP} "https://blockchain.info/balance?active=$address")"
	else
		QUERY="$(${MYAPP} "https://api.blockchair.com/bitcoin/dashboards/address/${address}${CHAIRKEY}")"
		#Blockcypher.com
		#QUERY="$(${MYAPP} "https://api.blockcypher.com/v1/btc/main/addrs/${address}/balance")"
	fi
}

getbal() {
	# Test for rate limit erro
	if grep -iq -e "Please try again shortly" -e "Quota exceeded" -e "Servlet Limit" -e "rate limit" -e "exceeded" -e "limited" -e "not found" -e "429 Too Many Requests" -e "Error 402" -e "Error 429" -e "too many requests" -e "banned" <<< "${QUERY}"; then
		print "\nRate limited. Requests may fail. Try to increase sleep time, option \"-s\".\n" 1>&2
		test -n "${DEBUG}" && printf "%s\n" "${QUERY}" 1>&2
	elif grep -iq -e "Invalid API token" <<< "${QUERY}"; then
		printf "\nInvalid API token.\n" 1>&2
		exit 1
	fi
	# Choose processing between blockchain.info or blockcypher.com
	if [[ -z "${CHAIROPT}" ]] && { [[ -n "${BINFOOPT}" ]] || [[ $((${N: -1}%2)) -eq 0 ]];}; then
		jq -er '.["'"${address}"'"].total_received' <<< "${QUERY}" 2>/dev/null || return 1
	else
		jq -er '.data[].address.received' <<< "${QUERY}" || return 1
		#Blockcypher.com
		#jq -er '.total_received' <<< "${QUERY}" 2>/dev/null || return 1
	fi
	}

# Start count
N=1
# Heading
date 
# Loop
# Spaces = 14
printf ".............." 1>&2
while :; do
	printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b" 1>&2
	printf "Addrs: %07d" "${N}" 1>&2
	VANITY="$(vanitygen -q 1 2>&1)"
	address="$(grep -e "Address:" <<< "${VANITY}" | cut -d' ' -f2)"
	queryf
	# If JQ detects an error, skip address
	if ! getbal >/dev/null; then
		if [[ -n "${DEBUG}" ]]; then
			printf "Skipped Addr: %s\n" "${address}" 1>&2
			getbal
			printf "%s\n.............." "${QUERY}" 1>&2
		fi
		sleep 10
		continue
	fi
	# Get received amount for further processing
	REC="$(getbal)"
	if [[ -n "${REC}" ]] && [[ "${REC}" != "0" ]]; then
		{ printf 'Check this address! \n'
		  printf "%s\n" "${VANITY}"
		  printf "Received? %s\n" "${REC}"
		  date
		  printf "Addrs checked: %s.\n.............." "${N}"
		} | tee -a ~/ADDRESS
	fi
	sleep "${SLEEPTIME}"
	N=$((N+1))
done

exit

#Dead code
#Blockcypher.com API docs:
#	\"Classic requests, up to 3 requests/sec and 200 requests/hr\"

