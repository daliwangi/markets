#!/bin/bash
#
# Binfo.sh -- Bash Interface for Blockchain.info API & Websocket Access
# v0.3.4  2019/07/14 by mountaineer_br

## Some defalts
LC_NUMERIC=en_US.UTF-8

## Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi

# Parse options
while getopts ":acsnjlbetuhix" opt; do
  case ${opt} in
    a ) # Address info
      ADDOPT=1
      ;;
    c ) # Blockchair Address info
      CHAIROPT=1
      ;;
    s ) # Summary  Address info
      SUMMARYOPT=1
      ADDOPT=1
      ;;
    n ) # Block Height info
      HOPT=1
      ;;
    j ) # Print JSON
      PJSON=1
      ;;
    l ) # Latest Block info
      LATESTOPT=1
      ;;
    b ) # Raw Block info
      RAWOPT=1
      ;;
    e ) # Soket mode for new BTC blocks
      SOCKETOPT=1
      ;;
    t ) # Transaction info
      TXOPT=1
      ;;
    x ) # Transaction info from Blockchair.com
      TXBCHAIROPT=1
      ;;
    u ) # Unconfirmed Txs
      UTXOPT=1
      ;;
    i ) # 24-H Blockchain Ticker
      BLKCHAINOPT=1
      ;;
    h ) # Help
      echo ""
      echo "Organização e Exploração do Blockchain do Bitcoin

O Blockchain é o caderno contábil que grava as transações que acontecem com o
Bitcoin. Ele pode ser analisado em quatro níveis:
	0 ) Blockchain propriamente dito;
	1 ) Blocos;
	2 ) Endereços;
	3 ) Transações

Quem mantém o livro contábil são os mineradores. Cada minerador ou grupo de 
mineradores formam un \"nó\" na rede descentralizada do Bitcoin. Cada nó segura 
uma cópia do livro contábil do Bitcoin, e um novo bloco só é inserido no block-
chain se a maioria dos mineradores aceitarem o novo bloco como válido.

Cada pagina de um livro contábil é como se fosse um bloco na cadeia do Bitcoin.
Os usuários abrem uma conta no Bitcoin (ou seja, criam endereços privados através
de uma \"frase semente\")...

Essa frase semente, ou ainda chamada de chave de endereço privada, pode germinar
infinitos novos endereços públicos de recebimento para que as pessoas o mandem
Bitcoin. De forma que, normalmente, se usa um único endereço para uma
única transação para possibilitar que o receptor saiba quem mandou o dinheiro para
ele, pois deve ter passado o seu endereço de recebimento de forma direta para o
pagador. Por sua vez, no Blockchain, não há registro de dados que possam identificar
as partes da transação, somente os endereços de partida e recebimento dos valores.

Todos os balancetes dos seus endereços vão se somer em um único balancete na
conta do usuário...

Para poder começar a se indentificar informações pessoais dos envolvidos em uma
cadeia inteira de transações a partir de um endereço é necessário informação
externa sobre quem é o dono de pelo menos um dos endereços do Blockchain..
A partir daí é uma tarefa investigativa de detetives de blockchain para fazer
deduções dos demais envolvidos nas transações subsequentes ou antecedentes..

Da mesma forma ocorre com dinheiro papel-moeda.
No papel moeda se tem o registro do número de série das notas, de qual banco elas
sairam e até qual banco elas chegaram.. Talvez registrem para quem foi o saque das
cédulas com número X, Y e Z.. Mas o caminho percorrido depois do primeiro recipiente
até o antepenúltimo, só poderá saber se conseguir informações adicionais sobre quem
teve a posse do dinheiro nese meio termo, e tentar fazer mais conexões..

Se usar ouro sem nenhuma marcação que possa identificar o tostão, é praticamente
impossível saber com certeza por quais caminhos a pepita percorreu... No máximo,
suposições, mas daí teriam que saber o peso, aspecto e pureza de uma barra de ouro
para tentar seguir o seu caminho em particular... Além do mais, o ouro é altamente
fundível, já o Bitcoin não o é.

Ou seja, o risco de ladrões fazerem lavagem de dinheiro é maior quanto mais um
dinheiro se aproxima do caráter do ouro ou do papel moeda. Quero dizer que o Bit-
coin não é melhor de se usar para fazer lavagem do que papel-moeda.

Ao contrário, no blockchain do Bitcoin sempre haverá registros gerais das transações,
e um lavador de dinheiro poderá ter que esperar anos ou décadas, até conseguir 
usufruir do que roubou.. E sabemos que o intuíto deles não é de poupar para depois.
Pois sempre estará sendo vigiado, e se conseguirmos interceptar o receptor do dinheiro,
mesmo que de uma pequena parte do bitcoin roubado, logo conseguiríamos identificar
melhor o ladrão (pois o receptor/loja/Agência de Câmbio deverá ter mais informações
sobre quem o mandou o dinheiro)..

Portanto, o blockchain é tão vigiado e as transações deixam tantos registros, e
cada vez ficará mais vigiado, que será constrangedor usá-lo para operações ilegais,
pelo menos o mesmo tanto quanto se usar malas de dinheiro ...

O segundo nível de organização do blockchain são os blocos. Os usuários solicitam
transações para serem incluídas em um bloco e pagam uma pequena taxa para que
os mineradores consigam achar um número de espalhamento ("hash") que possa conter
sua transação. Os números de espalhamento dos blocos da cadeia do Bitcoin precisam
ser registros matemáticos de todas as transações contidas em um bloco, e são 
tanto mais difíceis de serem encontrados quanto mais mineradores procuram por eles.

A dificuldade para geração de um número de espalhamento é modificada a cada duas
semanas, ou seja, há uma reobjetivação da dificuldade do número de espalhamento
que redefine as características que ele deve ter para ser válido... É como se a
dona/dono de casa espalhasse uma saca de feijão em cima da mesa, e fosse espalhando
até econtrar um único grão de feijão com características peculiares. A cada duas
semanas, mudam a especificação do grão de feijão perfeito (a dificuldade).

No inglês, isso se chama "Retarget" da dificuldade e também serve para que, sempre,
independentemente do número de mineradores, se ache um bloco a cada 10 minutos,
mais ou menos. Estatisticamente, por exemplo em um período de duas semanas, a 
razão \"(tempo decorrido) / (número de blocos encontrados)\" deverá ser muito pró-
xima de 10 min/bloco. Porém, observe que essa razão pode variar muito em um único
dia..

Quando um minerador consegue achar um número de hash adequado, ele pode gravar
todas as transações específicas que ele separou no início e que também fizeram
parte da definição das características do número de espalhamento antes mesmo de
se começar a procurar por ele. Além das taxas transacionais que os usuários pagam
por esse serviço, o minerador ganha um prêmio por ter achado um novo bloco.

Os novos bitcoins criados, atualmente 12,5 bitcoins por número de hash descoberto,
são criados do nada e são transaferidos para a conta (endereço) do minerador.
Como nessa transação não tem um remetente de verdade, os bitcoins criados são
transferidos no que se conhece como a transação da \"coinbase\", ou traduzindo
livremente, \"transação base de moedas\". Não tem nada a ver com a Corretora Coinbase!

Na exploração da cadeia de blocos do Bitcoin, podemos explorar o terceiro
nível de organização que são os endereços de recebimento e seus balancetes. Cada
endereço do bitcoin \"pode\" ser utilizado várias vezes, mesmo que o usuário possa
gerar infinitos endereços de recebimento novos a partir de uma chave privada (semen-
te), ele pode querer por alguma razão, usar um único endereço para uma 
certa demanda.

O quarto nível de detalhes de exploração do blockchain são as transações indivi-
duais. Por exemplo, se eu receber 0,00010000 BTC (ou 10  mil satoshis) de alguém,
haverá um registro no blockchain do endereço do remetente. Assim, se se desejar
verificar a transação antecedente que transaferiu esse valor para o meu cliente/
pagador, também poderei verificar o registro básico de qual endereço enviou o
dinheiro para ele. De forma que se se for voltando no tempo e nas transações, che-
gar-se-há até a transação da \"coinbase\" que gerou aqueles bitcoins!

Há mais uma observação relevante a ser exclarecida com rlação às transações e
os endereços. Quandov ocê recebe uma quantidade de bitcoins, eles ficam presos ao
endereço de recebimento. Numa única conta, você tem vários endereços de recebimento.
Se precisar pagar um valor maior que o contido em um único endereço, poderá ser
notado que a transação tem dois ou mais endereços de partida (sob o domínio de
um único usuário). Além do fato que o usuário poderá pagar para vários enderços
diferentes a cada transação, também é de se notar que, se a soma de valores conti-
dos nos endereços de partida do usuário for maior que o total que ele irá mandar
para outras pessoas, ele receberá um troco. Portanto, nas transações registradas,
geralmente se vê que o endereço de partida também recebe um valor como troco.

Cada bloco da cadeia pode ser identificado por um número de espalhamento,
por sua altura no blockchain (ou seja, o primeiro bloco é de altura 1, enquanto
o segundo é de altura 2 e assim por diante..) ou ainda por um outro número ainda
chamado de \"número de index\" (ou número de \"id\"). Já os endereços, só são identi-
ficáveis pelo seu próprio número de hash. As transações específicas podem ser 
identificadas ou por seu número de hash ou, também, por um número de index.

Nos exploradores de Bitcoin, o usuário geralmente poderá ver todo o caminho que os
bitcoins em questão percorreram até chegar a um determinado destinatário. Também
poderá ver dados de cada bloco, como número de transações, taxas, tamanho do blo-
co (em bytes), hora que foi minerado, sua altura no blockchain, etc.

Transações que foram pedidas par serem registradas ficam na piscina de memória
(mempool) do Bitcoin. Os mineradores pescam algumas transações ou escolhem quais
querem inserir no bloco. Maiores taxas de transações chamam mais a atenção dos
mineradores, porém eles geralmente pegam desde transações com as maiores taxas
até as transações com taxas bem pequenas... Mas depende muito se a piscina de 
memória está lotada ou não!

Se por acaso o usuário pedir para incluir uma transação e quiser pagar uma taxa
baixa demais para os mineradores, se ela não for processada em três dias, mais
ou menos, ela é excluída da mempool e o balancete do usuário volta a ser liberado
com o mesmo tanto que tinha antes de pedir para fazer a transação que foi recusada..

Endereços de contas do bitcoin mais recentes, chamados de Segwit, usam uma tec-
nologia mais nova e alguns sites de exploradores de blockchain não dão suporte
ainda. O protocolo de Segwit só foi aderido por menos de 50% da comunidade até
agora. O protocolo de Segwit permite que transações para destinatários múltiplos
economizem espaço no bloco, economizem nas taxas de mineração, e permitem mais
transações serem incuídas por bloco.

Exploradores de interface web que eu recomendo do blockchain do Bitcoin são
blockchair.com , blockcypher.com e blockchain.com .

Eu implementei um programa em Bash para puxar as mesmas informações que esses
sites oferecem pelo Terminal. Assim, economizamos banda e ficamos mais focados
nas informações, sem precisar deixar o Terminal!!!

Puxo as mesmas informações disponíveis no Blockchain.com pelo API deles.
O API deles, apesar de ser muito bom, ainda não suporta segwit, então
para algumas funções, implementei a função extra de puxar as informações
pelo API do Blockchair.com.

Exemplos para se usar o programa(script):

1) Ticker rolante do blockchain com estatísticas das últimas 24-H:

binfo.sh -i

2) Informação detalhadas do bloco por seu número de espalhamento OU id:

binfo.sh -b 00000000000000000013cb9ca12e6c0ba8d7538bfd38d1f81f88a0f17c60b544

ou

binfo.sh -b 1774904

ou para puxar info do último bloco encontrado:

binfo.sh -b


3) Informação do bloco por altura do bloco:

binfo.sh -n 586576

4) informações sumárias do última bloco (id das transações do bloco + número de
hash o bloco)

binfo.sh -l

5 ) Notificações para acompanhar quando acharem um novo bloco, e algumas info
dele:

binfo.sh -e

OBS: precisa do programa websocat!

6 ) Informção de um endeço (pode não mostrar todas as info se for endereço de segwit
de ou outras tecnologias mais recentes)

binfo.sh -a 1ADgkShKRsz5EwWmeeUhabYyeVuu6HwLpA

7 ) Informação sumárias de um endeço

binfo.sh -s 1ADgkShKRsz5EwWmeeUhabYyeVuu6HwLpA

8 ) Informações de endereços do Blockchair.com (pode ser segwit)

binfo.sh -c bc1qwl7jc00sngdnpmryfq4lyynehakz3q0qxxzzd8

9 ) Informação de transação pela sua hash ou número de id;
Se endereços segwit estiverem envolvidos, podem não aparecer direito!
Transações da coinbase também aparecem com destinatário \"null\"!

binfo.sh -t 211fe93efe9c02428c83a2b040afa7c84f7c57d685b4aa03a116e3b689fa1d09

10 ) Informação de transação pela sua hash ou número de id pelo Blockchair.com;
Mostra endereços segwit e de outras tecnologias!

binfo.sh -x a928de66c4b7b0e431639fc4693ea3ad63fa73e091e0e85940fb8a78a51b2e07

11 ) Puxa a mempool da rede do Bitcoin;
Transação não-confirmadas:

binfo.sh -u

LINK DE DOWNLOAD:
Procure pelo arquivo \"BINFO.SH\" nesse repo do github abaixo:
https://github.com/mountaineerbr/markets

Talvez, se quiser ver um vídeo onde eu falo do Blockchain e apresento as funções
desse explorador em Bash, você poderá ir em:
https://www.youtube.com/watch?v=S06VFDAVXJw

Se tiver algum bug, me perdoem. Provavelmente se achar um bug, vou dando uma
consertada no código-fonte de vez em quando e atualizo no repo do github.

Boa exploração!"
      echo ""  
      echo "\"This programme is licensed under the latest GNU General Public License\"."
      echo ""
      echo ""
      echo "   Binfo.sh  -- Bash Interface for Blockchain.info API & Websocket Access"
      echo ""
      echo "This programme fetches information of Bitcoin blocks, addresses and"
      echo "transactions from Blockchain.info (same as Blockchain.com) public APIs."
      echo "It is intended to be used as a simple Bitcoin blockchain explorer."
      echo "It only accepts one argument for lookup at a time."
      echo ""
      echo "Blockchain.info still does not support segwit addresses."
      echo "A workaround is to fetch information from Blockchair.com."
      echo "Blockchair.com supports segwit and other types of addresses."
      echo ""
      echo "Usage:"
      echo "   binfo.sh [option] [block|address|tx|id]"
      echo ""
      echo "Options:"
      echo "Blockhain"
      echo "  -i 	24-H Rolling Ticker for the Bitcoin Blockchain."
      echo "Block"
      echo "  -b 	Block information by hash or id (index number)."
      echo "  -n 	Block information by height."
      echo "  -e 	Socket stream for new blocks."
      echo "  -l 	Latest block summary information."
      echo "Address"
      echo "  -a 	Address information."
      echo "  -s 	Summary Address information."
      echo "  -c 	Address information from BlockChair."
      echo "Transaction"
      echo "  -t 	Transaction information by hash or id."
      echo "  -x 	Transaction information by hash or id from Blockchair."
      echo "  -u 	Unconfirmed transactions (mempool) from BlockChair;"
      echo "     	You can pipe the output to grep a specific address."
      echo "Other"
      echo "  -h 	Help (this textpage)."
      echo "  -j 	Fetch and print JSON."
      echo ""
      echo "This programme needs latest Bash, Curl, JQ and Websocat."
      echo ""
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))


## -e Socket stream for new blocks
sstreamf() {
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "Raw JSON will be printed when received...\n\n"
	echo '{"op":"blocks_sub"}' | websocat --text --no-close --ping-interval 20 wss://ws.blockchain.info/inv | jq -r . 
	exit 0
fi
# Start websocket connection and loop for recconeccting
while true; do
printf "New Bitcoin block websocket started\n\n"
echo '{"op":"blocks_sub"}' | websocat --text --no-close --ping-interval 18 wss://ws.blockchain.info/inv |
	jq -r '.x | "","--------",
	"New block found!",
	"Hash:","\t\(.hash)",
	"Merkel Root:",
	"\t\(.mrklRoot)",
	"Bits:\t\(.bits)\tNonce:\t\(.nonce)",
	"Blk Id:\t\(.blockIndex)\t\tPrevId:\t\(.prevBlockIndex)",
	"Height:\t\(.height)\t\tVer:\t\(.version)\tReward:\t\(.reward)",
	"Size:\t\(.size/1000) KB\tTxs:\t\(.nTx)",
	"Output:\t\(.totalBTCSent/100000000) BTC\tEst Tx Vol:\t\(.estimatedBTCSent)",
	"Time:\t\(.foundBy.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocal:\t\(.foundBy.time | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"\t\t\t\tNow:\t\(now|round | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"Ip:\t\(.foundBy.ip)  \tDesc:\t\(.foundBy.description)",
	"Link:","\t\(.foundBy.link)"'
#{"op":"blocks_sub"}
#{"op":"ping"}
printf "\nPress Ctrl+C twice to exit.\n\n"
sleep 2
N=$(( ${N} + 1 ))
printf "This is reconnection try number %s at %s.\n" "${N}" "$(date "+%Y-%m-%dT%H:%M:%S(%Z)")" | tee -a /tmp/binfo.sh_connect_retries.log
printf "Log file at: /tmp/binfo.sh_connect_retries.log\n"
printf "It will try reconnecting to websocket in some seconds.\n\n"
sleep 8
done
# If it automatically exits, exit as err
exit 1
}
if [[ -n "${SOCKETOPT}" ]]; then
	sstreamf
	exit 1
fi


## -l Latest block (Similar to socket stream data )
latestf() {
# Get JSON ( only has hash, time, block_index, height and txIndexes )
LBLOCK="$(curl -s https://blockchain.info/latestblock)"
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${LBLOCK}"
	exit
fi
# Print tx indexes first
TXIDS="$(printf "%s\n" "${LBLOCK}" | jq -r .txIndexes[] | sort)"
printf "\nTx Index:\n%s\n" "${TXIDS[@]}" | column -i"\n"
# Print the other info
printf "%s\n" "${LBLOCK}" | jq -r '. | "",
	"Block Hash:","\t\(.hash)",
	"Index:\t\(.block_index)","Height:\t\(.height)",
	"Time:\t\(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))",
	"Local:\t\(.time |strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))"'
}
if [[ -n "${LATESTOPT}" ]]; then
	latestf
	exit
fi

## -t Raw Tx info
rtxf() {
# Check if there is a RAWTX from another function already
if [[ -z "${RAWTX}" ]]; then 
	RAWTX=$(curl -s https://blockchain.info/rawtx/${1})
fi
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${RAWTX}"
	exit
fi
printf "\nTransaction info:\n\n"
printf "%s\n" "${RAWTX}" | jq -er '. | "","--------",
	"Tx hash:","\t\(.hash)",
	"Tx id:\t\(.tx_index)\tBlk Id:\t\(.block_index)\t\tDouble spend: \(.double_spend)",
	"Size:\t\(.size) bytes\tLock T:\t\(.lock_time)\t\tVer: \(.ver)",
	"Fee:\t\(.fee // "??") sat  \tFee:\t\(if .fee == null then "??" else (.fee/.size) end) sat/byte",
	"Relayed by:  \(.relayed_by//empty)",
	"Time:\t\(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocal:\t\(.time |strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	" From:",
	"\t\(.inputs[] | .prev_out | "\(.addr)  \(.value)  \(if .spent == true then "SPENT" else "UNSPENT" end)  From txid: \(.tx_index)  \(.addr_tag // "")")",
	" To:",
	"\t\(.out[] | "\(.addr)  \(.value)  \(if .spent == true then "SPENT" else "UNSPENT" end)  To txid: \(.spending_outpoints // [] | .[] // { "tx_index": "00" } | .tx_index // "")  \(.addr_tag // "")")"'

}
if [[ -n "${TXOPT}" ]]; then
	rtxf "${1}"
	exit
fi

## -b Raw Block info
rblockf() {
# Check if there is a block has in input or
# whether RAWB is from the hblockf function
if [[ -z "${RAWB}" ]] && [[ -z "${1}" ]]; then
	printf "Fetching latest block hash...\n" 1>&2
	RAWB="$(curl -s https://blockchain.info/rawblock/$(curl -s https://blockchain.info/latestblock | jq -r .hash))"
elif [[ -z "${RAWB}" ]]; then
	RAWB="$(curl -s https://blockchain.info/rawblock/${1})"
fi
# print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${RAWB}"
	exit
fi
# Print Txs info
# Grep txs and call rawtxf function
RAWTX="$(printf "%s\n" "${RAWB}" | jq -r '.tx[]')"
rtxf
# Print Block info
printf "\n\n--------\n"
printf "Block info\n"
printf "%s\n" "${RAWB}" | jq -r '. | "Hash:\t\(.hash)",
	"Merkel Root:","\t\(.mrkl_root)",
	"Prev block:",
	"\t\(.prev_block)",
	"Next block:",
	"\t\(.next_block[])",
	"",
	"Time:\t\(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocal:\t\(.time | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"Bits:\t\(.bits)\tNonce:\t\(.nonce)",
	"Index:\t\(.block_index)  \tVer:\t\(.ver)",
	"Height:\t\(.height)   \tChain:\t\(if .main_chain == true then "Main" else "Secondary" end)",
	"Size:\t\(.size/1000) kB\tTxs:\t\(.n_tx)",
	"Fees:\t\(.fee/100000000) BTC",
	"Avg F:\t\(.fee/.size) sat/byte",
	"Relayed by:\t\(.relayed_by // empty)"'
# Calculate total volume
II=($(printf "%s\n" "${RAWB}" | jq -r '.tx[] | .inputs[] | .prev_out.value // empty'))
OO=($(printf "%s\n" "${RAWB}" | jq -r '.tx[] | .out[] | .value // empty'))
VIN=$( echo "(${II[@]/%/+}0)/100000000" | bc -l)
VOUT=$(echo "(${OO[@]/%/+}0)/100000000" | bc -l)
printf "Input:\t%'.8f BTC\n" "${VIN}"
printf "Output:\t%'.8f BTC\n\n" "${VOUT}"
}
if [[ -n "${RAWOPT}" ]]; then
	rblockf "${1}"
	exit
fi


## -n Block info by height
hblockf() {
RAWB="$(curl -s https://blockchain.info/block-height/${1}?format=json | jq .blocks[])"
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${RAWB}"
	exit
fi
rblockf
}
if [[ -n "${HOPT}" ]]; then
	hblockf "${1}"
	exit
fi


## -a Address info
raddf() {
RAWADD=$(curl -s https://blockchain.info/rawaddr/${1})
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${RAWADD}"
	exit
fi
# -s Address Sumary?
if [[ -n "${SUMMARYOPT}" ]]; then
	printf "\n\n--------\n"
	printf "Summary Address info\n\n"
	curl -s https://blockchain.info/balance?active=${1} | jq -r '"Address:    \(keys[])",
	"N of tx:    \(.[].n_tx)",
	"T Recv:     \(.[].total_received) sat    (\(.[].total_received/100000000) BTC)",
	"Balance:    \(.[].final_balance) sat    (\(.[].final_balance/100000000) BTC)\n"'
	exit
fi
# Tx info
# Grep txs and call rawtxf function
RAWTX="$(printf "%s\n" "${RAWADD}" | jq -r '.txs[]')"
rtxf
printf "\n\n--------\n"
printf "Address info\n\n"
printf "%s\n" "${RAWADD}" | jq -r '. | "Address:    \(.address)",
	"Hash160:    \(.hash160)",
	"N of tx:    \(.n_tx)","T Recv:     \(.total_received) sat    ( \(.total_received/100000000) BTC )",
	"T Sent:     \(.total_sent) sat    ( \(.total_sent/100000000) BTC )",
	"Balance:    \(.final_balance) sat    ( \(.final_balance/100000000) BTC )\n"'
}
if [[ -n "${ADDOPT}" ]]; then
	raddf "${1}"
	exit
fi

## -c Address Info ( from Blockchair )
chairaddf() {
CHAIRADD="$(curl -s https://api.blockchair.com/bitcoin/dashboards/address/${1})"
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${CHAIRADD}"
	exit
fi
# Print Tx Hashes (only last 100)
printf "\nTx Hashes (last 100):\n"
printf "%s\n" "${CHAIRADD}" | jq -r '. | .data[] | "\t\(.transactions[])"'
# Print unspent tx
printf "\nUnspent Txs:\n"
printf "%s\n" "${CHAIRADD}" | jq -r '.data[] | .utxo[] | "\t\(.transaction_hash)",
	"\t\t\t\tBlk id:\(.block_id)\tValue:\t\(.value/100000000) BTC"'
# Print Address info
printf "%s\n" "${CHAIRADD}" | jq -r '. | "",
	"Address:\(.data|keys[])",
	"Type:\t\(.data[]|.address.type)",
	"",
	"Txs:\t\(.data[]|.address.transaction_count)",
	"Output Counts",
	"Receivd:\(.data[]|.address.output_count)",
	"Unspent:\(.data[]|.address.unspent_output_count)",
	"",
	"Bal:\t\(.data[]|.address.balance/100000000) BTC\t\t\(.data[]|.address.balance_usd|round) USD",
	"Rcved:\t\(.data[]|.address.received/100000000) BTC\t\t\(.data[]|.address.received_usd|round) USD",
	"Spent:\t\(.data[]|.address.spent/100000000) BTC\t\t\(.data[]|.address.spent_usd|round) USD",
	"",
	"First Received:\t\t\tLast Received:",
	"\t\(.data[]|.address.first_seen_receiving//"")\t\(.data[]|.address.last_seen_receiving//"")",
	"First Spent:\t\t\tLast Spent:",
	"\t\(.data[]|.address.first_seen_spending//"")\t\(.data[]|.address.last_seen_spending//"")",
	"Updated:\t\t\tNext Update:",
	"\t\(.context.cache.since)Z\t\(.context.cache.until)Z",
	""'
}
if [[ -n "${CHAIROPT}" ]]; then
	chairaddf "${1}"
	exit
fi


## -u Unconfirmed Txs ( Memory Pool )
## Uses blockchain.info and blockchair.com
utxf() {
printf "All addresses in mempool transactions and\n" 1>&2
printf "their change in balance will be shown.\n" 1>&2
printf "Pipe it to grep info for a particular address.\n\n" 1>&2
MEMPOOL="$(curl -s https://api.blockchair.com/bitcoin/state/changes/mempool)"
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${MEMPOOL}"
	exit
fi
# Print Addresses and balance delta (in satoshi and BTC)
printf "%s\n" "${MEMPOOL}" | jq -r '.data | keys_unsorted[] as $k | "\($k)    \(.[$k]) sat    \(.[$k]/100000000) BTC"'
# 100 last blocks:
printf "\nStats for last 100 blocks\n"
sleep 1
printf "Average txs per block:\n\t\t%.0f\n" "$(curl -s https://blockchain.info/q/avgtxnumber)"
sleep 1
printf "Average time between block:\n\t\t%.2f minutes\n" "$(echo "$(curl -s https://blockchain.info/q/interval)/60" | bc -l)"
sleep 1
printf "\nUnconfirmed transactions:\n\t\t%s\n" "$(curl -s https://blockchain.info/q/unconfirmedcount)"
printf "ETA for next block:\n\t\t%.2f minutes\n\n" "$(echo "$(curl -s https://blockchain.info/q/eta)/60" | bc -l)"
}
if [[ -n "${UTXOPT}" ]]; then
	utxf
	exit
fi



## -x Transaction info from Blockchair.com
txinfobcf() {
TXCHAIR=$(curl -s https://api.blockchair.com/bitcoin/dashboards/transaction/${1})
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${TXCHAIR}"
	exit
fi
#

printf "\nTransaction info:\n\n"
printf "%s\n" "${TXCHAIR}" | jq -er '.data[].inputs as $i | .data[].outputs as $o | .data[] | .transaction | "","--------",
	"Tx hash:","\t\(.hash)",
	"Tx id:\t\(.id)\tBlk Id:\t\(.block_id)  \(if .is_coinbase == "true" then "(Coinbase Tx)" else "" end)",
	"Size:\t\(.size) bytes\tLock T:\t\(.lock_time)\t\tVer: \(.version)",
	"Fee:\t\(.fee // "??") sat  \tFee:\t\(.fee_per_kb // "??") sat/KB",
	"Fee:\t\(.fee_usd // "??") USD  \tFee:\t\(.fee_per_kb_usd // "??") USD/KB",
	"Time:\t\(.time)Z\tLocal:\t\(.time | strptime("%Y-%m-%d %H:%M:%S")|mktime | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	" From:",
	($i[]|"\t\(.recipient)  \(.value)  \(if .is_spent == true then "SPENT" else "UNSPENT" end)"),
	" To:",
	($o[]|"\t\(.recipient)  \(.value) \(if .is_spent == true then "SPENT" else "UNSPENT" end)  To txid: \(.spending_transaction_id)")'


}
if [[ -n "${TXBCHAIROPT}" ]]; then
	txinfobcf ${*}
	exit
fi

## -i 24-H Ticker for the Bitcoin Blockchain
blkinfof() {
printf "Bitcoin Blockchain General Information.\n" 1>&2
CHAINJSON="$(curl -s https://api.blockchain.info/stats)"
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${CHAINJSON}"
	exit
fi
# Print the 24-H ticker
printf "%s\n" "${CHAINJSON}" | 
	jq -r '"Time:\t\((.timestamp/1000) | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"",
	"Blockchain",
	"Total Mined:",
	"\t\(.totalbc/100000000) BTC",
	"Height:\t\(.n_blocks_total) blocks",
	"",
	"Rolling 24-H Ticker",
	"T between blocks:\t\(.minutes_between_blocks) min",
	"Mined:\t\(.n_btc_mined/100000000) BTC\t\(.n_blocks_mined) blocks",
	"Reward:\t\((.n_btc_mined/100000000)/.n_blocks_mined) BTC/block",
	"Blocks size:\t\tAvg Block size:",
	"\t\(.blocks_size/1000000) MB\t\((.blocks_size/1000)/.n_blocks_mined) KB/block",
	"",
	"Difficulty and Hash Rate",
	"Diff:\t\(.difficulty)",
	"H Rate:\t\(.hash_rate) H/s",
	"Diff/HR Rate:","\t\(.difficulty/.hash_rate)",
	"Next Retarget",
	"Height:\t\(.nextretarget)",
	"\t\(.nextretarget-.n_blocks_total) blocks away",
	"\t~\( (.nextretarget-.n_blocks_total)*.minutes_between_blocks/(60*24)) days away",
	"",
	"Mining costs",
	"T Fees:\t\(.total_fees_btc/100000000) BTC",
	"Miners revenue:",
	"\t\(.miners_revenue_btc) BTC\t\(.miners_revenue_usd|round) USD",
	"Earned from Tx Fees (Total Fees/Miners Revenue):",
	"\t\(((.total_fees_btc/100000000)/.miners_revenue_btc)*100) %",
	"% of Tx Volume:",
	"\t\((.miners_revenue_btc/(.estimated_btc_sent/100000000))*100) %",
	"",
	"Market",
	"Price:\t\(.market_price_usd) USD",
	"Trade volume:",
	"\t\(.trade_volume_btc) BTC\t\(.trade_volume_usd|round) USD",
	"",
	"Transactions",
	"Estimated Tx Volume:",
	"\t\(.estimated_btc_sent/100000000) BTC\t\(.estimated_transaction_volume_usd|round) USD",
	""'
}
if [[ -n "${BLKCHAINOPT}" ]]; then
	blkinfof
	exit
fi

## Dead Code
#printf "Transactions:"
#printf "%s\n" "${RAWADD}" | jq -r '.txs[] | "\n\nHASH: \(.hash)","Size: \(.size) bytes","Time: \(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))","Local:\(.time | strflocaltime("%Y-%m-%dT%H:%M:%S"))"," From:","\t\(.inputs[] | "\(.prev_out.addr)\t\(.prev_out.value)")"," To:","\t\(.out[] | "\(.addr)\t\(.value)")\n"'
##NOTES:EX:curl -s https://blockchain.info/latestblock
# Payload ex: {"hash":"000000000000000000225ad8da8ad19647c98f448b7eeb6cbf18208c0e4db563","time":1561994663,"block_index":1771423,"height":583331,"txIndexes":[464938657,...]}
#TXIDS="$(printf "%s\n" "${RAWB}" | jq -r '.tx[] | .tx_index' | sort)"
#printf "\nTx Index:\n%s\n" "${TXIDS[@]}" | column -i"\n"
#######################
## Grep Block Tx info -- ALREADY DONE
#PRINT ONCE JQ | .block_index
#curl -s https://blockchain.info/rawblock/00000000000000000006e3d031d269dfd8b96e1b274a3f6b2c1a0549bb186c00 | jq -r '.tx[] | "Tx. Seq: \(.inputs[] | .sequence)\n Hash: \(.hash)\n Time: \(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\n Fee(total): \(.fee) sat\n Size: \(.size) bytes\n  Fee(sat/byte): \(.fee/(.size)|round)\n\n"'
#
## Total Block output
#AA=($(curl -s https://blockchain.info/rawblock/00000000000000000006e3d031d269dfd8b96e1b274a3f6b2c1a0549bb186c00 | jq -r '.tx[] | .inputs[] | .prev_out.value'))
# Delete null values:
#AA=($(curl -s https://blockchain.info/rawblock/00000000000000000006e3d031d269dfd8b96e1b274a3f6b2c1a0549bb186c00 | jq -r '.tx[] | .inputs[] | .prev_out.value // empty'))
#| tr -d '[a-z][A-Z]'))
#https://github.com/stedolan/jq/issues/354
#
#echo "${AA[@]/%/+}0" | bc -l
#Sum numbers in a array   echo "${AA[@]/%/+}0" | bc -l
## Get all inputs and tab value
#curl -s https://blockchain.info/rawtx/df0f8a4f0988de2875705a79ec826c8b9f8b08c9ffa4e5b4a5ea1b7bf956306c | jq -r '.inputs[] | "\(.prev_out.addr)\t\t\(.prev_out.value)"'
## Outs
#curl -s https://blockchain.info/rawtx/df0f8a4f0988de2875705a79ec826c8b9f8b08c9ffa4e5b4a5ea1b7bf956306c | jq -r '.out[] | "\(.addr)\t(.value)\t(.spent)"'
## OR for Total Volume
#OUTVOL=($(curl -s https://blockchain.info/rawtx/df0f8a4f0988de2875705a79ec826c8b9f8b08c9ffa4e5b4a5ea1b7bf956306c | jq -r '.out[] | "\(.value)"'))
#echo "${AA[@]/%/+}0" | bc -l
#######################

#Tx hash:","\t\(.hash)","","Height:\t\(.block_height)","Index:\t\(.tx_index)","Size:\t\(.size) bytes","Time:\t\(.time | strftime("%Y-%m-%dT%H:%M:%SZ"))","Local:\t\(.time | strflocaltime("%Y-%m-%dT%H:%M:%S"))"," From:","\t\(.inputs[] | "\(.prev_out.addr)\t\(.prev_out.value)")"," To:","\t\(.out[] | "\(.addr)\t\(.value)")\n"
#
#
#curl -s https://blockchain.info/unconfirmed-transactions?format=json)"
# Unarray txs and pass to rawtxf function
#RAWTX="$(printf "%s\n" "${MEMPOOL}" | jq -r '.txs[]')" 
#rtxf
#
