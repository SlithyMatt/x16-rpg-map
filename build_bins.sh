#!/bin/bash

./asc2bin.exe tilemap0.hex TILEMAP0.BIN 0000
./asc2bin.exe tilemap1.hex TILEMAP1.BIN 0000
./asc2bin.exe sprites.hex SPRITES.BIN 0000
#./asc2bin.exe tiles0.hex TILES0.BIN 0000
./make4bitbin.exe tiles16.data TILES0.BIN 0000
#./asc2bin.exe tiles1.hex TILES1.BIN 0000
./make4bitbin.exe tiles8.data TILES1.BIN 0000
#./asc2bin.exe palette.hex PAL.BIN FA00
./pal12bit.exe tiles16.data.pal PAL.BIN 0000
./vgm2x16opm.exe SNW.vgm MUSIC.BIN A000
