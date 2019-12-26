#!/bin/bash
# Uol.sh -- Puxa cotações do portal do UOL
# v0.1.4  dez/2019  by mountaineer_br

AJUDA="Uol.sh -- Puxa dados do UOL Economia


SINOPSE
	uol.sh [-bhlmv]

	
	O script puxa as cotações de páginas de economia do UOL.

	Os pacotes Bash, cURL ou Wget e iconv (Glibc) são necessários.


OPÇÕES
	-b 	Índice da B3.
	
	-h 	Mostra esta ajuda.

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
 	grep --color=never -A1 '%' <<<"${UOLB3}"
 	grep --color=never -Eo "[[:digit:]]+:[[:digit:]]+" <<<"${UOLB3}"
	exit
}

# Lista de ações
lstocksf() {
	PRELIST="$(${YOURAPP} "http://cotacoes.economia.uol.com.br/acoes-bovespa.html?exchangeCode=.BVSP&page=1&size=2000" | hf | sed -n "/Nome Código/,/Páginas/p" | sed -e 's/^[ \t]*//' -e '1,2d' -e '/^[[:space:]]*$/d' -e '$d' | sed '$!N;s/\n/=/')"
	column -et -s'=' -N'NOME,CÓDIGO' <<<"${PRELIST}"
	printf "Items: %s.\n" "$(wc -l <<<"${PRELIST}")"
	exit
}

# Cotação dos metais
metf() {
	COT="$(${YOURAPP} "https://economia.uol.com.br/cotacoes/" | hf)"
	printf "UOL - Metais Preciosos\n"
	grep -iEo --color=never 'ouro.{120}' <<<"${COT}" | grep -e 'US$' -e '%' |sed -e 's/[0-9]\s/&\n/g' -e 's/^\s\s*//' -e 's/US\$//g' | column -et -N'METAL,VAR,VENDA(US$/OZ)'
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
while getopts ":blmhv" opt; do
	case ${opt} in
		b ) #b3 
			b3f
	      		;;
		l ) #lista de ações
			lstocksf
	      		;;
		m ) #cotações metais
			metf
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

