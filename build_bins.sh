#!/bin/bash

#./asc2bin.exe tilemap0.hex TILEMAP0.BIN 0000
#./asc2bin.exe tilemap1.hex TILEMAP1.BIN 0000
./asc2bin.exe sprites.hex SPRITES.BIN 0000
#./asc2bin.exe tiles0.hex TILES0.BIN 0000
./make4bitbin.exe TILES0.BIN tiles16.data
#./asc2bin.exe tiles1.hex TILES1.BIN 0000
./make4bitbin.exe TILES1.BIN gfx/tiles8_0_column.data gfx/tiles8_128.data
./maketilemap.exe gfx/layers.tmx gfx/layers.json TILEMAP0.BIN TILEMAP1.BIN
#./asc2bin.exe palette.hex PAL.BIN FA00
./pal12bit.exe PAL.BIN gfx/tiles8_0.data.pal gfx/tiles8_128.data.pal
./vgm2x16opm.exe /dev/null QuietTown.vgm MUSIC.BIN
