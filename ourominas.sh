#!/bin/bash
# v0.2.2 09/set/2019  by mountaineer_br
# Free Software under the GNU Public License 3

LC_NUMERIC=en_US.UTF-8

## Taxas da Ouro Minas
DATA="$(curl -s "https://www.cambiorapido.com.br/tabelinha_wl.asp?filial=MESAVAREJO%20243" |
	sed -E 's/<[^>]*>//g' |
	iconv -c -f utf-8 |
	tr -d ' ' |
	grep -iv "pr-pago" |
	sed -e 's/^[ \t]*//')"
USD=( $(printf "%s\n" "${DATA}" | grep -i -A2 "laramericano" | sed 's/.$/=/g') )
EUR=( $(printf "%s\n" "${DATA}" | grep -i -A2 "euro" | sed 's/.$/=/g') )
GBP=( $(printf "%s\n" "${DATA}" | grep -i -A2 "libra" | sed 's/.$/=/g') )
AUD=( $(printf "%s\n" "${DATA}" | grep -i -A2 "laraustraliano" | sed 's/.$/=/g') )
CAD=( $(printf "%s\n" "${DATA}" | grep -i -A2 "larcanadense" | sed 's/.$/=/g') )
NZD=( $(printf "%s\n" "${DATA}" | grep -i -A2 "larneozelandes" | sed 's/.$/=/g') )
CHF=( $(printf "%s\n" "${DATA}" | grep -i -A2 "francosui" | sed 's/.$/=/g') )
JPY=( $(printf "%s\n" "${DATA}" | grep -i -A2 "iene" | sed 's/.$/=/g') )
CNY=( $(printf "%s\n" "${DATA}" | grep -i -A2 "yuan" | sed 's/.$/=/g') )
ARS=( $(printf "%s\n" "${DATA}" | grep -i -A2 "pesoargentino" | sed 's/.$/=/g') )
CLP=( $(printf "%s\n" "${DATA}" | grep -i -A2 "pesochileno" | sed 's/.$/=/g') )
MXN=( $(printf "%s\n" "${DATA}" | grep -i -A2 "pesomexicano" | sed 's/.$/=/g') )
UYU=( $(printf "%s\n" "${DATA}" | grep -i -A2 "pesouruguaio" | sed 's/.$/=/g') )
COP=( $(printf "%s\n" "${DATA}" | grep -i -A2 "pesocolombiano" | sed 's/.$/=/g') )
ZAR=( $(printf "%s\n" "${DATA}" | grep -i -A2 "rande" | sed 's/.$/=/g') )
RUB=( $(printf "%s\n" "${DATA}" | grep -i -A2 "ruble" | sed 's/.$/=/g') )
ILS=( $(printf "%s\n" "${DATA}" | grep -i -A2 "shekel" | sed 's/.$/=/g') )

# Make Table
printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n" \
	"${USD[*]}" "${EUR[*]}" "${GBP[*]}" "${AUD[*]}" "${CAD[*]}" "${NZD[*]}" \
	"${CHF[*]}" "${JPY[*]}" "${CNY[*]}" "${ARS[*]}" "${CLP[*]}" "${MXN[*]}" \
	"${UYU[*]}" "${COP[*]}" "${ZAR[*]}" "${RUB[*]}" "${ILS[*]}" |
	sed -e 's/Dlar/Dólar/g' -e 's/Suio/Suiço/g' -e 's/Chins/Chinês/g' |
	column -t -s"=" -N'Moeda,Venda,Compra' -R'Moeda'

# Calcular o preço de venda com o CGK.sh
if [[ -e "/home/jsn/_Scripts/markets/cgk.sh" ]]; then
	CGKXAU="$(~/_Scripts/markets/cgk.sh -b xau usd)"
	USDP="${USD[@]:1:1}"
	USDP="${USDP%\=}"
	printf "Venda Ouro Estimada:  %s\n" "$(printf "scale=3; %s*%s/28.349523125\n" "${CGKXAU}" "${USDP/,/.}" | bc -l)"
	#Não trampam com Prata!
	#CGKXAG="$(~/_Scripts/markets/cgk.sh -b xag usd)"
	#printf "Venda Prata Estimada:  %s\n" "$(printf "scale=3; %s*%s/28.349523125\n" "${CGKXAG}" "${USDP/,/.}" | bc -l)"
fi

