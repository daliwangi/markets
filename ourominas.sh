#!/bin/bash
# v0.2.3 27/set/2019  by mountaineer_br
# Free Software under the GNU Public License 3

LC_NUMERIC=en_US.UTF-8

## Taxas da Ouro Minas
DATA="$(curl -s "https://www.cambiorapido.com.br/tabelinha_wl.asp?filial=MESAVAREJO%20243" |
	sed -E 's/<[^>]*>//g' |	iconv -c -f utf-8 | tr -d ' ' |
	grep -iv "pr-pago" | sed -e 's/^[ \t]*//')"
USD=($(grep -i -A2 "laramericano" <<< "${DATA}" | sed 's/.$/=/g'))
EUR=($(grep -i -A2 "euro" <<< "${DATA}" | sed 's/.$/=/g'))
GBP=($(grep -i -A2 "libra" <<< "${DATA}" | sed 's/.$/=/g'))
AUD=($(grep -i -A2 "laraustraliano" <<< "${DATA}" | sed 's/.$/=/g'))
CAD=($(grep -i -A2 "larcanadense" <<< "${DATA}" | sed 's/.$/=/g'))
NZD=($(grep -i -A2 "larneozelandes" <<< "${DATA}" | sed 's/.$/=/g'))
CHF=($(grep -i -A2 "francosui" <<< "${DATA}" | sed 's/.$/=/g'))
JPY=($(grep -i -A2 "iene" <<< "${DATA}" | sed 's/.$/=/g'))
CNY=($(grep -i -A2 "yuan" <<< "${DATA}" | sed 's/.$/=/g'))
ARS=($(grep -i -A2 "pesoargentino" <<< "${DATA}" | sed 's/.$/=/g'))
CLP=($(grep -i -A2 "pesochileno" <<< "${DATA}" | sed 's/.$/=/g'))
MXN=($(grep -i -A2 "pesomexicano" <<< "${DATA}" | sed 's/.$/=/g'))
UYU=($(grep -i -A2 "pesouruguaio" <<< "${DATA}" | sed 's/.$/=/g'))
COP=($(grep -i -A2 "pesocolombiano" <<< "${DATA}" | sed 's/.$/=/g'))
ZAR=($(grep -i -A2 "rande" <<< "${DATA}" | sed 's/.$/=/g'))
RUB=($(grep -i -A2 "ruble" <<< "${DATA}" | sed 's/.$/=/g'))
ILS=($(grep -i -A2 "shekel" <<< "${DATA}" | sed 's/.$/=/g'))

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
	printf "Venda Ouro Estimada(R$/g): %s\n" "$(bc -l <<< "scale=3; ${CGKXAU}*${USDP/,/.}/28.349523125")"
fi

exit
#Não trampam com Prata!
#CGKXAG="$(~/_Scripts/markets/cgk.sh -b xag usd)"
#printf "Venda Prata Estimada:  %s\n" "$(printf "scale=3; %s*%s/28.349523125\n" "${CGKXAG}" "${USDP/,/.}" | bc -l)"

