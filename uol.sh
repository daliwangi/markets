#!/bin/bash
# Uol.sh -- Puxa cotações do portal do UOL
# v0.1.20  feb/2020  by mountaineer_br

AJUDA="Uol.sh -- Puxa dados do UOL Economia


SINOPSE
	uol.sh [-bdi]
	
	uol.sh [-hlmv]

	
	O script puxa as cotações de páginas de economia do UOL.

	Os pacotes Bash, cURL ou Wget e gzip são necessários.


GARANTIA
	Este programa/script é software livre e está licenciado sob a Licença 
	Geral Pública v3 ou superior do GNU. Sua distribuição não oferece supor-
	te nem correção de bugs.
	
	O script precisa do cURL/Wget, JQ e Bash.

	If this programme was useful, consider giving me a nickle! =)
  
	Se este programa foi útil, considere me lançar um trocado!

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPÇÕES
	-b 	Índice da B3, série intraday com a opção '-i'.

	-d 	Cotação do dólar, série intraday com a opção '-i'.
	
	-i 	Série intraday com as opções '-b' e '-d'.
	
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
	UOLB3="$(${YOURAPP} 'https://api.cotacoes.uol.com/asset/intraday/list/?format=JSON&fields=price,high,low,open,volume,close,change,pctChange,date&item=1&://api.cotacoes.uol.com/asset/intraday/list/?format=JSON&fields=price,high,low,open,volume,close,bid,ask,change,pctChange,date&item=1&')"
	#bid,ask,

	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${UOLB3}"
		exit
	fi
	
	if [[ -z "${INTRADOPT}" ]]; then
		printf 'UOL - Bovespa B3\n'
		jq -r '.docs[0]|
			"Data   : \(.date)",
			"Alta   : \(.high)",
			"Baixa  : \(.low)",
			"Abertur: \(.open)",
			"Fechame: \(.close)",
			"Var    : \(.change)",
			"Var%   : \(.pctChange)%",
			"Pontos : \(.price)"'<<<"${UOLB3}" | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1-\2-\3 \4:\5:\6/'
	else
		printf 'UOL - Bovespa B3\n'
		jq -r '.docs|reverse[]|"\(.price)\t\(.high)\t\(.low)\t\(.open)\t\(.close)\t\(.change)\t\(.pctChange)\t\(.date)"'<<<"${UOLB3}" | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1-\2-\3 \4:\5:\6/' | column -ets$'\t' -NPREÇO,ALTA,BAIXA,ABERT,FECHA,VAR,VAR%,DATA

	fi
		
}

#Cotação dólar
dolarf() {
	#get data
	DT="$(${YOURAPP} 'https://api.cotacoes.uol.com/currency/intraday/list/?format=JSON&fields=bidvalue,askvalue,maxbid,minbid,variationbid,variationpercentbid,date&currency=3&')"
	DC="$(${YOURAPP} 'http://cotacoes.economia.uol.com.br/cambioJSONChart.html')"

	#Debug?
	if [[ -n "${PJSON}" ]]; then
		printf "%s\n" "${DT}"
		printf "%s\n" "${DC}"
		exit
	fi
	
	if [[ -z "${INTRADOPT}" ]]; then
		#turismo
		jq -r '.docs[0]|
			"UOL - Dólar Turismo",
			"Data    : \(.date)",
			"VarCompr: \(.variationbid)",
			"VarComp%: \(.variationpercentbid)",
			"Venda   : \(.askvalue)",
			"Compra  : \(.bidvalue)"' <<< "${DT}" | sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1-\2-\3 \4:\5:\6/'
		
		#comercial
		jq -r '.[2]|
			"",
			"UOL - \(.name)",
			"Data    : \(.timestamp/1000|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))",
			"Fresco  : \(if .notFresh == true then "não" else "sim" end)",
			"Abertura: \(if .open == "0" then empty else .open end)",
			"Alta    : \(.high)",
			"Baixa   : \(.low)",
			"Var(%)  : \(.pctChange)",
			"Venda   : \(.ask)",
			"Compra  : \(.bid)",
			"VarComp.: \(.varBid)"' <<< "${DC}"
			#TS="$(jq -r '.[2].timestamp' <<<"${COT}")"
			#printf "Hora    :%s" "$(date -d@"${TS:0:10}")"
	else
		#subfunction
		tablef() { sed -E 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1-\2-\3 \4:\5:\6/' | column -ets$'\t' -NCOMPRA,VENDA,VAR,VAR%,DATA;}

		#get data	
		DT="$(${YOURAPP} 'https://api.cotacoes.uol.com/currency/intraday/list/?format=JSON&fields=bidvalue,askvalue,maxbid,minbid,variationbid,variationpercentbid,date&currency=3&')"
		DC="$(${YOURAPP} 'https://api.cotacoes.uol.com/currency/intraday/list/?format=JSON&fields=bidvalue,askvalue,maxbid,minbid,variationbid,variationpercentbid,date&currency=1&')"

		#Debug?
		if [[ -n "${PJSON}" ]]; then
			printf "%s\n" "${DT}"
			printf "%s\n" "${DC}"
			exit
		fi

		printf 'UOL - Dólar Turismo\n'
		jq -r '.docs|reverse[]|
			"\(.bidvalue)\t\(.askvalue)\t\(.variationbid)\t\(.variationpercentbid)\t\(.date)"' <<< "${DT}" | tablef
		
		printf '\nUOL - Dólar Comercial\n'
		jq -r '.docs|reverse[]|
			"\(.bidvalue)\t\(.askvalue)\t\(.variationbid)\t\(.variationpercentbid)\t\(.date)"' <<< "${DC}" | tablef
	fi

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
	grep -Eo --color=never 'Ouro.{117}' <<<"${COT}" | grep -e 'US$' -e '%' |sed -e 's/[0-9]\s/&\n/g' -e 's/^\s\s*//' -e 's/US\$//g' | column -et -N'METAL,VAR,VENDA(US$/OZ)'
	grep -o "Câmbio     Atualizado em..............." <<<"${COT}" | sed -e 's/\s\s*/ /g' -e 's/Atualizado/atualizado/'
}

# Check for no arguments or options in input
if ! [[ "${@}" =~ [a-zA-Z]+ ]]; then
	printf "Rode com -h para ajuda.\n"
	exit 1
fi

# Test for must have packages
if command -v curl &>/dev/null; then
	YOURAPP="curl -s --compressed"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO- --header='Accept-Encoding: gzip'"
else
	printf "cURL ou Wget é requerido.\n" 1>&2
	exit 1
fi

#request compressed response
if ! command -v gzip &>/dev/null; then
	printf 'warning: gzip may be required\n' 1>&2
fi


# Parse options
while getopts ':bdijlmhv' opt; do
	case ${opt} in
		b ) #b3 
			B3OPT=1
	      		;;
		d ) #dolar 
			DOLAROPT=1
	      		;;
		i ) #timeseries intraday 
			INTRADOPT=1
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
if [[ -n "${B3OPT}" ]]; then
	b3f 
elif [[ -n "${DOLAROPT}" ]]; then
	dolarf 
elif [[ -n "${METAISOPT}" ]]; then
	metf
elif [[ -n "${LSTOCKSOPT}" ]]; then
	lstocksf
fi
