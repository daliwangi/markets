#!/bin/bash
# v0.2  05/set/2019 by mountaineer_br
# Free Software under the GNU Public License 3

## Taxas da PARMETAL
# Ajuda "-h"
[[ "${1}" = "-h" ]] &&
	printf "Uso:\n\tparmetal\t#Todas cotações disponíveis\n" &&
		printf "\tparmetal -p\t#Somente Barras Parmetal\n" &&
	exit 0

# Removing all HTML tags from a webpage (for use with curl)
htmlfilter() {
	sed -E 's/<[^>]*>//g'
}

# Função Cotações Metais
metaisf() {
	METAIS="$(curl -s "https://www.parmetal.com.br/app/metais/" |
		sed -E 's/<[^>]*>/]/g' | sed 's/]]]]/[[/g' | sed 's/]]]/[/g' |
		sed 's/]]/[/g' | sed 's/\[/\n/g')"
	BPARM=( $(printf "%s\n" "${METAIS}" | grep -iA2 "barra parmetal" | sed 's/$/=/g') )
	BTRAD=( $(printf "%s\n" "${METAIS}" | grep -iA2 "barras tradicionais" | sed 's/$/=/g') )
	BOUTR=( $(printf "%s\n" "${METAIS}" | grep -iA2 "outras barras" | sed 's/$/=/g') )
	UPDATES="$(printf "%s\n" "${METAIS}" | grep -i -e "../../...." | sort | uniq)"
	UPTIMES="$(printf "%s\n" "${METAIS}" | grep -i -e "..:..:.." | sort | uniq)"
	}
# Pegar taxas somente das Barras da Parmetal "-p"
if [[ "${1}" = "-p" ]]; then
	curl -s "https://www.parmetal.com.br/app/metais/" |
		sed -E 's/<[^>]*>/]/g' | sed 's/]]]]/[[/g' |
		sed 's/]]]/[/g' | sed 's/]]/[/g' |
		sed 's/\[/\n/g' |
		grep --color=never -A2 -e "Barra Parmetal/RBM"
	exit
fi

# Moedas de Câmbios
moedasf() {
	MOEDAS="$(curl -s "https://www.parmetal.com.br/app/subtop-cotacao/" |
	htmlfilter |
	sed 's/&nbsp;//g' |
	grep -i -e dolar -e libra -e "ouro spot" -e euro |
	sed -e 's/^[ \t]*//' -e 's/Valor: //g' | tr '.' ',')" 
	# Preparar para Tebela
	USD=( $(printf "%s\n" "${MOEDAS}" | grep -i dolar | sed 's/cial:/cial=/g') )
	GBP=( $(printf "%s\n" "${MOEDAS}" | grep -i libra | sed 's/cial:/cial=/g') )
	XAU=( $(printf "%s\n" "${MOEDAS}" | grep -i ouro | sed 's/Spot:/Spot=/g') )
	EUR=( $(printf "%s\n" "${MOEDAS}" | grep -i euro | sed 's/cial:/cial=/g') )
	}

# Imprimir Tabela
metaisf
printf "Updates: %s  %s\n" "${UPDATES}" "${UPTIMES}"
printf "%s\n%s\n%s\n" "${BPARM[*]}" "${BTRAD[*]}" "${BOUTR[*]}" |
	column -t -s"=" -N'Ativo,Compra,Venda' -R'Ativo'
moedasf
printf "%s\n%s\n%s\n%s\n" "${USD[*]}" "${GBP[*]}" "${XAU[*]}" "${EUR[*]}" |
	column -dt -s"=" -N'              Ativo,Compra' -R'              Ativo'

