#!/bin/bash
# Uol.sh -- Puxa cotações do portal do UOL
# v0.1.9  dez/2019  by mountaineer_br

AJUDA="Uol.sh -- Puxa dados do UOL Economia


SINOPSE
	uol.sh [-bhlmv]

	
	O script puxa as cotações de páginas de economia do UOL.

	Os pacotes Bash, cURL ou Wget e iconv (Glibc) são necessários.


GARANTIA
	Este programa/script é software livre e está licenciado sob a Licença 
	Geral Pública v3 ou superior do GNU. Sua distribuição não oferece supor-
	te nem correção de bugs.
	
	O script precisa do cURL/Wget, JQ e Bash.

	If this programme was useful, consider giving me a nickle! =)
  
	Se este programa foi útil, considere me lançar um trocado!

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPÇÕES
	-b 	Índice da B3.

	-d 	Cotação do dólar comercial.
	
	-h 	Mostra esta ajuda.

	-j 	Debug, imprime json.

	-l 	Lista de ações

	-m 	Cotação dos metais preciosos.

	-v 	Mostra versão do script." 

## Funções
# Filtro HTML
hf() {  sed 's/<[^>]*>//g';}

# Cotação da BOVESPA B3 Hack
b3f() {
	printf "UOL - B3\n"
	UOLB3="$(${YOURAPP} "https://cotacoes.economia.uol.com.br/index.html" | hf | tr -d '\t' | sed '/^[[:space:]]*$/d')"
	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${UOLB3}"
		exit
	fi
 	grep --color=never -A1 '%' <<<"${UOLB3}"
 	grep --color=never -Eo "[[:digit:]]+:[[:digit:]]+" <<<"${UOLB3}"
	exit
}

#Cotação dólar comercial
dolarf() {
	COT="$(${YOURAPP} 'http://cotacoes.economia.uol.com.br/cambioJSONChart.html')"
	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${COT}"
		exit
	fi
	jq -r '.[2]|
		"UOL - \(.name)",
		(.timestamp/1000|strflocaltime("%Y-%m-%dT%H:%M:%S%Z")),
		"Fresco  : \(if .notFresh == true then "não" else "sim" end)",
		"Abertura: \(if .open == "0" then empty else .open end)",
		"Alta    : \(.high)",
		"Baixa   : \(.low)",
		"Var(%)  : \(.pctChange)",
		"Venda   : \(.ask)",
		"Compra  : \(.bid)",
		"VarComp.: \(.varBid)"' <<< "${COT}"
		#TS="$(jq -r '.[2].timestamp' <<<"${COT}")"
		#printf "Hora    :%s" "$(date -d@"${TS:0:10}")"
		
	exit

}

# Lista de ações
lstocksf() {
	PRELIST="$(${YOURAPP} "http://cotacoes.economia.uol.com.br/acoes-bovespa.html?exchangeCode=.BVSP&page=1&size=2000" | hf | sed -n "/Nome Código/,/Páginas/p" | sed -e 's/^[ \t]*//' -e '1,2d' -e '/^[[:space:]]*$/d' -e '$d' | sed '$!N;s/\n/=/')"
	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${PRELIST}"
		exit
	fi
	column -et -s'=' -N'NOME,CÓDIGO' <<<"${PRELIST}"
	printf "Items: %s.\n" "$(wc -l <<<"${PRELIST}")"
	exit
}

# Cotação dos metais
metf() {
	COT="$(${YOURAPP} "https://economia.uol.com.br/cotacoes/" | hf)"
	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${COT}"
		exit
	fi
	printf "UOL - Metais Preciosos\n"
	grep -iEo --color=never 'ouro.{117}' <<<"${COT}" | grep -e 'US$' -e '%' |sed -e 's/[0-9]\s/&\n/g' -e 's/^\s\s*//' -e 's/US\$//g' | column -et -N'METAL,VAR,VENDA(US$/OZ)'
	grep -o "Câmbio     Atualizado em..............." <<<"${COT}" | sed -e 's/\s\s*/ /g' -e 's/Atualizado/atualizado/'
	exit
}

# Check for no arguments or options in input
if ! [[ "${@}" =~ [a-zA-Z]+ ]]; then
	printf "Rode com -h para ajuda.\n"
	exit 1
fi

# Test for must have packages
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "cURL ou Wget é requerido.\n" 1>&2
	exit 1
fi

# Parse options
while getopts ":bdjlmhv" opt; do
	case ${opt} in
		b ) #b3 
			B3OPT=1
	      		;;
		d ) #dolarcomercial 
			DOLAROPT=1
	      		;;
		j ) #debug, print json
			PJSON=1
			;;
		l ) #lista de ações
			LSTOCKSOPT=1
	      		;;
		m ) #cotações metais
			METAISOPT=1
	      		;;
		h ) # Help
	      		echo -e "${AJUDA}"
	      		exit 0
	      		;;
		v ) # Version of Script
	      		grep -m1 '# v' "${0}"
	      		exit 0
	      		;;
		\? )
	     		printf "Opção inválida: -%s\n" "${OPTARG}" 1>&2
	     		exit 1
	     		;;
  	esac
done
shift $((OPTIND -1))

#Call opts
test -n "${B3OPT}" && b3f 
test -n "${LSTOCKSOPT}" && lstocksf 
test -n "${DOLAROPT}" && dolarf 
test -n "${METAISOPT}" && metf 
