#!/usr/bin/bash
#
# Bcalc.sh -- Easy Calculator for Bash
# v0.4.2  2019/nov/24  by mountaineerbr

#Defaults
# Record file:
RECFILE="${HOME}/.bcalc_record"
# Extensions file:
EXTFILE="${HOME}/.bcalc_extensions"
# Number of decimal plates (16 bc defaults):
SCLDEF=16
# Don't change LC_NUMERIC
LC_NUMERIC="en_US.UTF-8"


## Manual and help
HELP_LINES="NAME
 	\033[01;36mBcalc.sh -- Easy Calculator for Bash\033[00m


SYNOPSIS
	bcalc.sh [-ct] [-sNUM] [\"EQUATION\"]
	
	bcalc.sh [-ehr] [-n\"SHORT NOTE\"]


DESCRIPTION
	Bcalc.sh uses the powerful Bash Calculator and adds some useful features.

	It creates a Record file at '${RECFILE}'. Use of \"ans\" in new 
	expression greps last result from record file.

	Equations containing () with backslashes may need escaping with \"\" or ''.

	Bash calculator uses LC_NUMERIC=\"en_US.UTF-8\", so a dot \".\" must be
	used as decimal separator and scale (decimal plates) can be set with \"-s\".
	Results may use printf to add a comma \",\" as thousands separator if set
	with option \"-t\".

	Results may round, depending on the scale setting.


SCIENTIFIC EXTENSION
	
	The scientific option will try to download a copy of a table of scien-
	tific constants and extra math functions to '${EXTFILE}' in a format
	readable by Bash Calculator (bc). Once downloaded, the table is kept for
	future use (needs Wget or cURL).

	Data is downloaded from:

		<http://x-bc.sourceforge.net/scientific_constants.bc>
		
		<http://x-bc.sourceforge.net/extensions.bc>


BASH ALIAS
	You may consider creating a bash alias to easier use. A suggestion is to
	add to your ~/.bashrc:
	

	  alias c=\"/path/to/bcalc.sh\"


USAGE EXAMPLES
			$ bcalc.sh 50.7+9

			$ bcalc.sh \"(100+100/2)*2\" 

			$ bcalc.sh 2^2+(8-4)

			$ bcalc.sh -s2 100/120

			$ bcalc.sh \\\(100+100\\\\)/1

			$ bcalc.sh -0.2*10
			
			$ bcalc.sh ans+33
			
			$ bcalc.sh -t -s4 50000*5

			$ bcalc.sh -c \"ln(0.3)\"
			
			$ bcalc.sh -c \"log(16)\"

		
		Define variables for use in the equation (lowercase):
		
			$ bcalc.sh \"a=5; -a+20\"


		Use of cientific constants option \"-c\"; na = Avogadro's con-
		stant; how many molecules in 0.234 M of solution? 
			
			$ bcalc.sh -c 0.234*na


BUGS
	Made and tested with Bash 5.0. This programme is distributed without 
	support or bug corrections. Licensed under GPLv3 and above.

	Give me a nickle! =)
        

	  bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
		-c 	Use scientific extensions.
    		
		-e 	Print cientific extensions.
    		
		-t 	Group thousands; if no expression is given, reuse last 
			answer.

    		-h 	Show this help.

		-n 	Add note to last result record; it should be used after 
			a result is recorded to record file.
    		
		-r 	Print results record.
    		
		-s 	Set scale (decimal plates); defaults='${SCLDEF}'; if no
			expression is passed, reuse last answer."

# Parse options
while getopts ":cehnrs:t" opt; do
	case ${opt} in
		c ) # Run calc with cientific extensions
			CIENTIFIC=1
			;;
		e ) # Print cientific extensions
			CIENTIFIC=1
			PEXT=1
			;;
		t ) # Group thousands
			GROUP="'"
			;;
		h ) # Show Help
			echo -e "${HELP_LINES}"
			exit
			;;
		n ) # Add comment to Record
			NOTE=1
			;;
		r ) # Print record
			cat "${RECFILE}"
			exit
			;;
		s ) # Scale ( decimal plates )
			SCL="${OPTARG}"
			;;
		\? )
			break
	esac
done
shift $((OPTIND -1))

# Set scale
if [[ -z ${SCL} ]]; then
	SCL="${SCLDEF}"
fi

## Check if there is a Record file available
## Otherwise, create an empty one
if [[ ! -f "${RECFILE}" ]]; then
	printf "## Bcalc.sh Record\n\n" >> "${RECFILE}"
fi
## Add Note function
if [[ -n "${NOTE}" ]];then
	sed -i "$ i\>> NOTE: ${*}" "${RECFILE}"
	exit
fi
# https://superuser.com/questions/781558/sed-insert-file-before-last-line
# http://www.yourownlinux.com/2015/04/sed-command-in-linux-append-and-insert-lines-to-file.html

## Scientific Extension Function
cientificf() {
	# Grab extensions and scientific constants
	if ! [[ -f "${EXTFILE}" ]]; then
		if command -v curl &>/dev/null; then
			YOURAPP="curl"
		elif command -v wget &>/dev/null; then
			YOURAPP="wget -O-"
		else
			printf "cURL or Wget is required.\n" 1>&2
			exit 1
		fi
		{ ${YOURAPP} "http://x-bc.sourceforge.net/scientific_constants.bc"
		  printf "\n"
		  ${YOURAPP} "http://x-bc.sourceforge.net/extensions.bc"
		  printf "\n";} > "${EXTFILE}"
	fi
	if [[ -n "${PEXT}" ]]; then
		cat "${EXTFILE}"
		exit
	fi
	EXT="$(cat "${EXTFILE}")"
}
test -n "${CIENTIFIC}" && cientificf

## Grep last answer result from calc Record and prepare equation
if grep -q ans <<< "${*}"; then 
	ANS=$(tail -1 "${RECFILE}")
	EQ="$(sed -e "s/ans/(${ANS})/" <<< "${*//,}")"
# If no args, reuses last Ans (format last ans with -s and/or -g )
elif [[ -z "${*}" ]]; then
	EQ="$(tail -1 "${RECFILE}")"
else
	EQ="${*//,}"
fi

## Check if equation syntax is valid
PRES="$(bc -l <<< "${EXT};${EQ}")"
if [[ -z "${PRES}" ]]; then
	exit 1
fi

## Calculate result
## If result is the same as last result, do not print it to Record again
if [[ "${PRES}" != $(tail -1 "${RECFILE}") ]]; then
	## Print timestamp in Record
	printf "## %s\n## { %s }\n" "$(date "+%FT%T%Z")" "${EQ}" 1>> "${RECFILE}"
	## Print original result to Record (default bc mathlib scale is 16)
	printf "%s\n" "${PRES}" >> "${RECFILE}"
fi

## Format result
if [[ -n "${GROUP}" ]]; then
	printf "%${GROUP}.${SCL}f\n" "$(bc -l <<<"${EXT};scale=${SCL};${EQ}/1")"
else
	bc -l <<<"${EXT};scale=${SCL};${EQ}/1"
fi

# Nought truncation (does not wortk with custom variables, etc)
# printf "define trunc(x){auto os;os=scale;for(scale=0;scale<=os;scale++)if(x==x/1){x/=1;scale=os;return x}}; trunc(%s/1)\n" "${EQ}" | bc -l

