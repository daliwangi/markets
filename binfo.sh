#!/bin/bash
#
# Binfo.sh -- Bash Interface for Blockchain.info API & Websocket Access
# v0.3.14  2019/08/23 by mountaineer_br

## Some defalts
LC_NUMERIC=en_US.UTF-8

HELP="\"This programme is licensed under the latest GNU General Public License\".


   Binfo.sh  -- Bash Interface for Blockchain.info API & Websocket Access

This programme fetches information of Bitcoin blocks, addresses and
transactions from Blockchain.info (same as Blockchain.com) public APIs.
It is intended to be used as a simple Bitcoin blockchain explorer.
It only accepts one argument for lookup at a time.

Blockchain.info still does not support segwit addresses.
A workaround is to fetch information from Blockchair.com.
Blockchair.com supports segwit and other types of addresses.

Usage:
   binfo.sh [option] [block|address|tx|id]

Options:
Blockhain
  -i 	24-H Rolling Ticker for the Bitcoin Blockchain.
Block
  -b 	Block information by hash or id (index number).
  -n 	Block information by height.
  -e 	Socket stream for new blocks.
  -l 	Latest block summary information.
Address
  -a 	Address information.
  -s 	Summary Address information.
  -c 	Address information from BlockChair.
Transaction
  -t 	Transaction information by hash or id.
  -x 	Transaction information by hash or id from Blockchair.
  -u 	Unconfirmed transactions (mempool) from BlockChair;
     	You can pipe the output to grep a specific address.
Other
  -h 	Help (this textpage).
  -j 	Fetch and print JSON.
  -v    Show this programme version.

This programme needs latest Bash, Curl, JQ and Websocat.
Give me a nickle!
bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
"

## Check if there is any argument
if ! [[ ${*} =~ [a-zA-Z]+ ]]; then
	printf "Run with -h for help.\n"
	exit
fi

# Parse options
while getopts ":acsnjlbetuhixv" opt; do
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
      echo -e "${HELP}"
      echo ""
      exit 0
      ;;
    v ) # Version of Script
      head "${0}" | grep -e '# v'
      exit
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
	echo '{"op":"blocks_sub"}' | websocat --text --no-close --ping-interval 20 wss://ws.blockchain.info/inv
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
	"Height:\t\(.height)\t\tVer:\t\(.version)\tReward:\t\(if .reward == 0 then "??" else .reward end)",
	"Size:\t\(.size/1000) KB\tTxs:\t\(.nTx)",
	"Output:\t\(.totalBTCSent/100000000) BTC\tEst Tx Vol:\t\(.estimatedBTCSent/100000000) BTC",
	"Time:\t\(.foundBy.time | strftime("%Y-%m-%dT%H:%M:%SZ"))\tLocal:\t\(.foundBy.time | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"\t\t\t\tNow:\t\(now|round | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	"Ip:\t\(.foundBy.ip)  \tDesc:\t\(.foundBy.description)",
	"Link:\t\(.foundBy.link)"'
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
printf "\nTx Index:\n\n"
printf "%s\n" "${TXIDS[@]}" | column
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
# Test response from server
if [[ "$(printf "%s\n" "${RAWTX}" | wc -l)" -le "1" ]]; then
	printf "%s\n" "${RAWTX}"
	exit 1
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
	"\t\(.inputs[] | .prev_out | "\(.addr)  \(if .value == null then "??" else (.value/100000000) end)  \(if .spent == true then "SPENT" else "UNSPENT" end)  From txid: \(.tx_index)  \(.addr_tag // "")")",
	" To:",
	"\t\(.out[] | "\(.addr)  \(if .value == null then "??" else (.value/100000000) end)  \(if .spent == true then "SPENT" else "UNSPENT" end)  To txid: \(.spending_outpoints // [] | .[] // { "tx_index": "00" } | .tx_index // "")  \(.addr_tag // "")")"'

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
# Test response from server
if [[ "$(printf "%s\n" "${RAWB}" | wc -l)" -le "1" ]]; then
	printf "%s\n" "${RAWB}"
	exit 1
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
BLKREWARD=$(printf "%s-%s\n" "${VOUT}" "${VIN}" | bc -l)
printf "Reward:\t%'.8f BTC\n" "${BLKREWARD}"
printf "Input:\t%'.8f BTC\n" "${VIN}"
printf "Output:\t%'.8f BTC\n\n" "${VOUT}"
}
if [[ -n "${RAWOPT}" ]]; then
	rblockf "${1}"
	exit
fi


## -n Block info by height
hblockf() {
RAWBORIG="$(curl -s https://blockchain.info/block-height/${1}?format=json)"
# Test response from server
if [[ "$(printf "%s\n" "${RAWBORIG}" | wc -l)" -le "1" ]]; then
	printf "%s\n" "${RAWBORIG}"
	exit 1
fi
RAWB="$(printf "%s\n" "${RAWBORIG}" | jq .blocks[])"
# Print JSON?
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
  # -s Address Sumary?
if [[ -n "${SUMMARYOPT}" ]]; then
	SUMADD=$(curl -s https://blockchain.info/balance?active=${1})
	# Print JSON?
	if [[ -n  "${PJSON}" ]]; then
		printf "%s\n" "${SUMADD}"
		exit
	fi
	# Test response from server
	if [[ "$(printf "%s\n" "${SUMADD}" | wc -l)" -le "1" ]]; then
		printf "%s\n" "${SUMADD}"
		exit 1
	fi
	printf "\n\n--------\n"
	printf "Summary Address Info\n\n"
	printf "%s\n" "${SUMADD}" | jq -r '"Address:    \(keys[])",
	"N of tx:    \(.[].n_tx)",
	"T Recv:     \(.[].total_received) sat    (\(.[].total_received/100000000) BTC)",
	"Balance:    \(.[].final_balance) sat    (\(.[].final_balance/100000000) BTC)\n"'
	exit
fi
# Get RAW ADDR
RAWADD=$(curl -s https://blockchain.info/rawaddr/${1})
# Print JSON?
if [[ -n  "${PJSON}" ]]; then
	printf "%s\n" "${RAWADD}"
	exit
fi
# Test response from server
if [[ "$(printf "%s\n" "${RAWADD}" | wc -l)" -le "1" ]]; then
	printf "%s\n" "${RAWADD}"
	exit 1
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
# Test response from server
if printf "%s\n" "${CHAIRADD}" | jq -r '. | .data[] | "\t\(.address[type])"' | grep -iq "null"; then
	printf "\n\e[1;33;44mWarning:\e[0m This Address does not \"seem\" to be valid...\n" 1>&2
	exit 1
fi
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
# Test response from server
if printf "%s\n" "${TXCHAIR}" | grep -iq "DOCTYPE html"; then
	printf "Error: Transaction not found.\n" 1>&2
	exit 1
fi
printf "\nTransaction info:\n\n"
printf "%s\n" "${TXCHAIR}" | jq -er '.data[].inputs as $i | .data[].outputs as $o | .data[] | .transaction | "","--------",
	"Tx hash:","\t\(.hash)",
	"Tx id:\t\(.id)\tBlk Id:\t\(.block_id)  \(if .is_coinbase == true then "(Coinbase Tx)" else "" end)",
	"Size:\t\(.size) bytes\tLock T:\t\(.lock_time)\t\tVer: \(.version)",
	"Fee:\t\(.fee // "??") sat  \tFee:\t\(.fee_per_kb // "??") sat/KB",
	"Fee:\t\(.fee_usd // "??") USD  \tFee:\t\(.fee_per_kb_usd // "??") USD/KB",
	"Time:\t\(.time)Z\tLocal:\t\(.time | strptime("%Y-%m-%d %H:%M:%S")|mktime | strflocaltime("%Y-%m-%dT%H:%M:%S(%Z)"))",
	" From:",
	($i[]|"\t\(.recipient)  \(.value/100000000)  \(if .is_spent == true then "SPENT" else "UNSPENT" end)"),
	" To:",
	($o[]|"\t\(.recipient)  \(.value/100000000) \(if .is_spent == true then "SPENT" else "UNSPENT" end)  To txid: \(.spending_transaction_id)")'


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
