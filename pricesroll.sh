#!/bin/bash

uxterm -T 'BNB Stream' -geometry 6x29+0+24 -e '/home/jsn/_Scripts/markets/binance.sh -f3 -w bnbusdt' &

uxterm -T 'LTC Stream' -geometry 6x24+0+0 -e '/home/jsn/_Scripts/markets/binance.sh -f3 -s ltcusdt' &

uxterm -T 'BTC Bitstamp Stream' -geometry 8x53+52+0 -e "/home/jsn/_Scripts/markets/bitstamp.sh -w" &

uxterm -T 'BTC Detailed Stream' -geometry 77x53+121+0 -e '/home/jsn/_Scripts/markets/binance.sh -i' &

uxterm -T 'Book Depth' -geometry 36x44+741+0 -e '/home/jsn/_Scripts/markets/binance.sh -e' &

uxterm -T 'BTC New-Block' -geometry 74x18+506+487 -e '/home/jsn/_Scripts/markets/binfo.sh -e' &

uxterm -T 'XAU-XAG-BRL Price roll' -geometry 32x42+1149+149 &

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

