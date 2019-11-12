#!/bin/bash

uxterm -T 'BNB Stream' -geometry 6x25+0+340 -e '/home/jsn/_scripts/markets/binance.sh -f3 -w bnbusdt' &

uxterm -T 'LTC Stream' -geometry 6x25+54+340 -e '/home/jsn/_scripts/markets/binance.sh -s ltcusdt' &

uxterm -T 'BTC Bitfinex Stream' -geometry 7x13+108+340 -e "/home/jsn/_scripts/markets/bitfinex.sh" &

uxterm -T 'BTC Bitstamp Stream' -geometry 7x11+108+570 -e "/home/jsn/_scripts/markets/bitstamp.sh -c" &

uxterm -T 'XRP Binance Stream' -geometry 7x20+0+0 -e "/home/jsn/_scripts/markets/binance.sh -f5 -s xrpusdt" &

uxterm -T 'BCHABC Binance Stream' -geometry 6x20+62+0 -e "/home/jsn/_scripts/markets/binance.sh -w bchabcusdt" &

uxterm -T 'ETH Binance Stream' -geometry 6x20+115+0 -e "/home/jsn/_scripts/markets/binance.sh -w ethusdt" &

uxterm -T 'BTC Detailed Stream' -geometry 77x53+172+0 -e '/home/jsn/_scripts/markets/binance.sh -i' &

uxterm -T 'Book Depth' -geometry 36x44+800+0 -e '/home/jsn/_scripts/markets/binance.sh -e' &

uxterm -T 'BTC New-Block' -geometry 74x18+506+487 -e '/home/jsn/_scripts/markets/binfo.sh -e' &

uxterm -T 'XAU-XAG-BRL Price roll' -geometry 30x42+1149+149 &

