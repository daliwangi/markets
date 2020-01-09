#!/bin/bash
# HG Brasil -- Cotação de ações
# v0.3.4  jan/2020  by mountaineer_br


# *Sua* chave privada (grátis) do HG Brasil
#HGBAPIKEY=""


HELP="Visão Geral    : $ hgb
Cotação de ação: $ hgb [ação]
Lista de ações : $ hgb.sh -l
Esta ajuda     : $ hgb.sh -h
Variável para chave de API: HGBAPIKEY=\"\""

# Cotações do HG Brasil Finança - Visão Geral do Mercado
hgb() {
	## API Público
	# Puxar JSON
	local HQRES="$(curl -s "https://api.hgbrasil.com/finance")"
	# Moedas
	printf "Visão Geral -- HG Brasil\n"
	{ jq -r '.results.currencies[]' <<<"${HQRES}"| tail -n +2 |
		jq -r '"\(.name)=\(.variation//"??")=\(.sell//"??")=\(.buy//"??")"';
		jq -r '"INDEX=VAR%=PONTOS",(.results.stocks[] | "\(.name)=\(.variation//"??")=\(.points//"??")")'<<<"${HQRES}";} |
		column -et -s= -N'NOME,VAR%,VENDA,COMPRA' 
	printf "\nTaxas\n"
		curl -s "https://api.hgbrasil.com/finance/taxes?key=${HGBAPIKEY}" |
			jq -r '(.results[]|"\(.cdi)=\(.selic)=\(.daily_factor)=\(.date)")' |
			column -et -s= -N'CDI,SELIC,FATOR/DIA,DATA'
}

# -a Cotações do HQ Brasil Finança - Uma Ação/Ativo específico
hga() {
	# Puxar JSON
	local HQRES="$(curl -s "https://api.hgbrasil.com/finance/stock_price?key=${HGBAPIKEY}&symbol=${1,,}")"
	# Mais checagem de erro
	if [[ "$(printf "%s\n" "${HQRES}" | jq -r ".results.${1^^}.error")" = "true" ]]; then
		printf "%s\n" "${HQRES}" | jq -r ".results.${1^^}.message"
		exit 1
	fi
	# Imprime resultado
		jq -r '.results."'${1^^}'" |
		"\(.name)",
		"\(.symbol)",
		"Update: \(.updated_at)",
		"MktCap: \(.market_cap)",
		"Abertu: \(.market_time.open)",
		"Fecham: \(.market_time.close)",
		"Var___: \(.change_percent)",
		"Preço_: \(.price)"'<<<"${HQRES}"
}

#lista de títulos
listf() {
	procf() { sed 's/<[^>]*>//g' <<<"${DATA}" | grep --color=auto -- '-\s[A-Z0-9][A-Z0-9]*$';}  #'^.*\s-\s'
	DATA="$(curl -s "https://console.hgbrasil.com/documentation/finance/symbols")"
	procf
	printf "Títulos: %s\n" "$(procf | wc -l)"
	printf "<https://console.hgbrasil.com/documentation/finance/symbols>"
 }

# Parse Options
# Check for no arguments or options in input
if [[ "${1}" = "-h" ]]; then
	echo "${HELP}"
	exit 0
elif [[ "${1}" = "-l" ]]; then
	listf
	exit 0
elif [[ "${1}" = "-v" ]]; then
	head "${0}" | grep -e '# v'
	exit 0
elif [[ -z "${HGBAPIKEY}" ]]; then
	printf "Por favor, crie uma chave de API grátis e adicione no código-fonte do script.\n" 1>&2
	exit 1
elif [[ -n "${1}" ]]; then
	hga "${1}"
	exit
else
	hgb
	exit
fi

