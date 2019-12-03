#!/bin/bash
# v0.2.9  03/dez/2019  by mountaineer_br
# Free Software under the GNU Public License 3

LC_NUMERIC=en_US.UTF-8

## Taxas da PARMETAL
# Ajuda "-h"
if [[ "${1}" = "-h" ]]; then
	printf "Uso:\n"
	printf "\tparmetal.sh    #todas cotações disponíveis\n\n"
	printf "Opções:\n"
	printf " 	-p    Somente barras parmetal\n"
	printf " 	-v    Imprime versão do script.\n"
	exit 0
fi
# Imprime versão -v
if [[ "${1}" = "-v" ]]; then
	grep -m1 '# v' "${0}"
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
	BPARM=($(grep -iA2 "barra parmetal" <<< "${METAIS}" | sed -e 's/$/=/g' -e 's/Barra Parmetal\/RBM/Barra Par\/RBM/g'))
	BTRAD=($(grep -iA2 "barras tradicionais" <<< "${METAIS}" | sed -e 's/$/=/g' -e 's/Barras Tradicionais/Barra Trad/g'))
	BOUTR=($(grep -iA2 "outras barras" <<< "${METAIS}" | sed -e 's/$/=/g' -e 's/Outras Barras/Outras/g'))
	UPDATES="$(grep -i -e "../../...." <<< "${METAIS}" | sort | uniq)"
	UPTIMES="$(grep -i -e "..:..:.." <<< "${METAIS}" | sort | uniq)"
	BPARM2=($(grep -oe "[0-9]*,[0-9]*" <<< "${BPARM[@]}"))
	SPREAD="$(tr ',' '.' <<< "((${BPARM2[1]}/${BPARM2[0]})-1)*100" | bc -l)"
	column -t -s"=" -N'Ativo,Compra,Venda,Spread' -R'Compra,Venda,Spread' <<-EOF
		${BPARM[@]}$(printf "%.4f" "${SPREAD}")
		${BTRAD[@]}
		${BOUTR[@]}
		EOF
	printf "%s %s\n" "${UPDATES}" "${UPTIMES}"
	}

# Moedas de Câmbios
moedasf() {
	printf "Puxando índices...\r" 1>&2
	MOEDAS="$(curl -s "https://www.parmetal.com.br/app/subtop-cotacao/" |
		htmlfilter | sed 's/&nbsp;//g' | grep -i -e dolar -e libra -e "ouro spot" -e euro |
		sed -e 's/^[ \t]*//' -e 's/Valor: //g' | tr '.' ',')" 
	# Preparar para Tebela
	USD=($(grep -i "dolar" <<< "${MOEDAS}" | sed 's/cial: /cial=/g'))
	GBP=($(grep -i "libra" <<< "${MOEDAS}" | sed 's/cial: /cial=/g'))
	XAU=($(grep -i "ouro" <<< "${MOEDAS}" | sed 's/Spot: /Spot=/g'))
	EUR=($(grep -i "euro" <<< "${MOEDAS}" | sed 's/cial: /cial=/g'))
	column -t -s"=" -N'Índice,Cotação'  <<-EOF
		${USD[@]}
		${GBP[@]}
		${XAU[@]}
		${EUR[@]}
		EOF
	}

# Imprimir Tabela
printf "PARMETAL\n"
# Outras moedas
moedasf
printf "\n"
# Metais
metaisf

exit

