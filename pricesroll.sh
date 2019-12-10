#!/bin/bash

uxterm -T 'BNB Binance' -geometry 6x25+0+340 -e '/home/jsn/bin/markets/binance.sh -f3 -w bnbusdt' &

uxterm -T 'LTC Binance' -geometry 6x25+54+340 -e '/home/jsn/bin/markets/binance.sh -s2 ltcusdt' &

uxterm -T 'BTC Binance US' -geometry 7x6+108+340 -e "/home/jsn/bin/markets/binance.sh -2us btc usd" &

uxterm -T 'BTC Bitstamp' -geometry 7x8+108+615 -e "/home/jsn/bin/markets/bitstamp.sh -c" &

uxterm -T 'BTC Bitfinex' -geometry 7x8+108+455 -e "/home/jsn/bin/markets/bitfinex.sh" &

uxterm -T 'XRP Binance' -geometry 7x20+0+0 -e "/home/jsn/bin/markets/binance.sh -f5 -s xrpusdt" &

uxterm -T 'BCHABC Binance' -geometry 6x20+62+0 -e "/home/jsn/bin/markets/binance.sh -w2 bchusdt" &

uxterm -T 'ETH Binance' -geometry 6x20+115+0 -e "/home/jsn/bin/markets/binance.sh -w2 ethusdt" &

uxterm -T 'BTC Detailed' -geometry 77x53+172+0 -e '/home/jsn/bin/markets/binance.sh -i' &

uxterm -T 'BTC Book Depth Binance' -geometry 36x44+800+0 -e '/home/jsn/bin/markets/binance.sh -dd' &

uxterm -T 'BTC New-Block Blockchain.info' -geometry 74x17+506+495 -e '/home/jsn/bin/markets/binfo.sh -e' &

uxterm -T 'Misc' -geometry 30x42+1149+149 &

