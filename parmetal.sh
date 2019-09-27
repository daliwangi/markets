#!/bin/bash
# v0.2.8  27/set/2019 by mountaineer_br
# Free Software under the GNU Public License 3

LC_NUMERIC=en_US.UTF-8

## Taxas da PARMETAL
# Ajuda "-h"
if [[ "${1}" = "-h" ]]; then
	printf "Uso:\n\tparmetal\t#Todas cotações disponíveis\n"
	printf "\tparmetal -p\t#Somente Barras Parmetal\n"
	exit 0
fi

# Removing all HTML tags from a webpage (for use with curl)
htmlfilter() { sed -E 's/<[^>]*>//g';}

# Pegar taxas somente das Barras da Parmetal "-p"
if [[ "${1}" = "-p" ]]; then
	# Can also use to parse XML files   grep -oPm1 -e "(?<=<descr>)[^<]+"
	# From:https://unix.stackexchange.com/questions/277861/parse-xml-returned-from-curl-within-a-bash-script
	PRICE="$(curl -s "https://www.parmetal.com.br/app/metais/" |
		sed -E 's/<[^>]*>/]/g' | sed 's/]]]]/[[/g' |
		sed 's/]]]/[/g' | sed 's/]]/[/g' | sed 's/\[/\n/g' |
		grep --color=never -A2 -e "Barra Parmetal/RBM")"
	printf "%s\n" "${PRICE}"
	PRICE2=($(grep -oe "[0-9]*,[0-9]*" <<< "${PRICE}"))
	SPREAD="$(tr ',' '.' <<< "((${PRICE2[1]}/${PRICE2[0]})-1)*100" | bc -l)"
	printf "SPD: %'.3f %%\n" "${SPREAD}"
	exit
fi

# Função Cotações Metais
metaisf() {
	METAIS="$(curl -s "https://www.parmetal.com.br/app/metais/" |
		sed -E 's/<[^>]*>/]/g' | sed 's/]]]]/[[/g' | sed 's/]]]/[/g' |
		sed 's/]]/[/g' | sed 's/\[/\n/g')"
	BPARM=( $(grep -iA2 "barra parmetal" <<< "${METAIS}" | sed 's/$/=/g') )
	BTRAD=( $(grep -iA2 "barras tradicionais" <<< "${METAIS}" | sed 's/$/=/g') )
	BOUTR=( $(grep -iA2 "outras barras" <<< "${METAIS}" | sed 's/$/=/g') )
	UPDATES="$(grep -i -e "../../...." <<< "${METAIS}" | sort | uniq)"
	UPTIMES="$(grep -i -e "..:..:.." <<< "${METAIS}" | sort | uniq)"
	}

# Moedas de Câmbios
moedasf() {
	MOEDAS="$(curl -s "https://www.parmetal.com.br/app/subtop-cotacao/" |
		htmlfilter | sed 's/&nbsp;//g' | grep -i -e dolar -e libra -e "ouro spot" -e euro |
		sed -e 's/^[ \t]*//' -e 's/Valor: //g' | tr '.' ',')" 
	# Preparar para Tebela
	USD=( $(grep -i "dolar" <<< "${MOEDAS}" | sed 's/cial:/cial=/g') )
	GBP=( $(grep -i "libra" <<< "${MOEDAS}" | sed 's/cial:/cial=/g') )
	XAU=( $(grep -i "ouro" <<< "${MOEDAS}" | sed 's/Spot:/Spot=/g') )
	EUR=( $(grep -i "euro" <<< "${MOEDAS}" | sed 's/cial:/cial=/g') )
	}

# Imprimir Tabela
# Metais
metaisf
printf "%s\n%s\n%s\n" "${BPARM[*]}" "${BTRAD[*]}" "${BOUTR[*]}" |
	column -t -s"=" -N'Ativo,Compra,Venda' -R'Ativo,Compra,Venda'

# Spread
BPARM2=($(grep -oe "[0-9]*,[0-9]*" <<< "${BPARM[@]}"))
SPREAD="$(tr ',' '.' <<< "((${BPARM2[1]}/${BPARM2[0]})-1)*100" | bc -l)"
printf " SPD B Parmetal/RBM     %'.3f%%\n" "${SPREAD}"
# Update timestamps
printf "Updates: %s %s\n\n" "${UPDATES}" "${UPTIMES}"

# Outras moedas
moedasf
printf "%s\n%s\n%s\n%s\n" "${USD[*]}" "${GBP[*]}" "${XAU[*]}" "${EUR[*]}" |
	column -t -s"=" -N'              Índice,Taxa' -R'              Índice'

exit
# Dead Code
#printf "%s\n" "${BPARM[2]%\=}" 
#printf "%s\n" "${BPARM[3]%\=}"
#SPREAD="$(printf "((%s/%s)-1)*100\n" "$(printf "%s\n" "${BPARM[@]}" | tail -n 1)" "$(printf "%s\n" "${BPARM[@]}" | tail -n 2 | head -n 1)" | tr ',' '.' | tr -d '=' | bc -l)"
#SPREAD="$(tr ',' '.' <<< "(($(printf "%s\n" "${BPARM[@]}" | tail -n 1)/$(printf "%s\n" "${BPARM[@]}" | tail -n 2 | head -n 1))-1)*100" | tr -d '=' | bc -l)"
#SPREAD="$(bc -l "(($(tail -n 1 <<< "${PRICE}")/$(tail -n 2 <<< "${PRICE}" | head -n 1)" | tr ',' '.'))-1)*100"

