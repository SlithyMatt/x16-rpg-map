#!/bin/bash

./asc2bin.exe tilemap0.hex TILEMAP0.BIN 0000
./asc2bin.exe tilemap1.hex TILEMAP1.BIN 0000
./asc2bin.exe sprites.hex SPRITES.BIN 0000
./asc2bin.exe tiles0.hex TILES0.BIN 0000
./asc2bin.exe tiles1.hex TILES1.BIN 0000
./asc2bin.exe palette.hex PAL.BIN FA00
./vgm2x16opm.exe test.vgm MUSIC.BIN A000
