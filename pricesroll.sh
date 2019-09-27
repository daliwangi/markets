#!/bin/bash

uxterm -T 'BNB Stream' -geometry 6x25+0+340 -e '/home/jsn/_Scripts/markets/binance.sh -f3 -w bnbusdt' &

uxterm -T 'LTC Stream' -geometry 6x25+54+340 -e '/home/jsn/_Scripts/markets/binance.sh -s ltcusdt' &

uxterm -T 'BTC Bitstamp Stream' -geometry 7x25+108+340 -e "/home/jsn/_Scripts/markets/bitstamp.sh -w" &

uxterm -T 'XRP Binance Stream' -geometry 7x20+0+0 -e "/home/jsn/_Scripts/markets/binance.sh -f5 -s xrpusdt" &

uxterm -T 'BCHABC Binance Stream' -geometry 6x20+62+0 -e "/home/jsn/_Scripts/markets/binance.sh -w bchabcusdt" &

uxterm -T 'ETH Binance Stream' -geometry 6x20+115+0 -e "/home/jsn/_Scripts/markets/binance.sh -s ethusdt" &

uxterm -T 'BTC Detailed Stream' -geometry 77x53+172+0 -e '/home/jsn/_Scripts/markets/binance.sh -i' &

uxterm -T 'Book Depth' -geometry 36x44+800+0 -e '/home/jsn/_Scripts/markets/binance.sh -e' &

uxterm -T 'BTC New-Block' -geometry 74x18+506+487 -e '/home/jsn/_Scripts/markets/binfo.sh -e' &

uxterm -T 'XAU-XAG-BRL Price roll' -geometry 30x42+1149+149 &

exit

OLD CONFIGS


xfce4-terminal -T 'BNB Stream' --geometry 6x43+0+0 -e '/home/jsn/_Scripts/markets/binance.sh -f3 -w bnbusdt' &

xfce4-terminal -T 'BTC Bitstamp Stream' --geometry 8x43+52+0 -e "/home/jsn/_Scripts/markets/bitstamp.sh -w" &

xfce4-terminal -T 'BTC Detailed Stream' --geometry 77x44+120+0 -e '/home/jsn/_Scripts/markets/binance.sh -i' &

xfce4-terminal -T 'Book Depth' --geometry 36x43+740+0 -e '/home/jsn/_Scripts/markets/binance.sh -e' &

xfce4-terminal -T 'BTC New-Block' --geometry 74x18+480+439 -e '/home/jsn/_Scripts/markets/binfo.sh -e' &

xfce4-terminal -T 'XAU-XAG-BRL Price roll' --geometry 32x35+1106+149 &





xfce4-terminal -T 'BTC Stream' --geometry 8x43+0+20 -e '/home/jsn/_Scripts/markets/binance.sh -s' &

xfce4-terminal -T 'BTC Bitstamp Stream' --geometry 8x43+68+20 -e "/home/jsn/_Scripts/markets/bitstamp.sh -w" &

xfce4-terminal -T 'BNB Stream' --geometry 6x43+136+20 -e '/home/jsn/_Scripts/markets/binance.sh -f3 -w bnbusdt' &

xfce4-terminal -T 'Book Depth' --geometry 36x43+188+20 -e '/home/jsn/_Scripts/markets/binance.sh -e' &

xfce4-terminal -T 'BTC New-Block' --geometry 74x18+480+439 -e '/home/jsn/_Scripts/markets/binfo.sh -e' &

xfce4-terminal -T 'XAU-XAG-BRL Price roll' --geometry 37x35+1066+149 &

