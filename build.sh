#!/bin/bash

if [ ! -f "asc2bin.exe" ]; then
  ./build_tools.sh
fi

if [ ! -f "TILEMAP0.BIN" ]; then
  ./build_bins.sh
fi

cl65 --cpu 65C02 -o RPGMAP.PRG -l rpgmap.list rpgmap.asm
