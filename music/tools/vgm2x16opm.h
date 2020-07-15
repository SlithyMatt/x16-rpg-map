#ifndef VGM2X16OPM_H
#define VGM2X16OPM_H

#include <stdio.h>

#define DELAY_REG 2
#define DONE_REG  4

int loadmusic(FILE *ofp, const char *vgm_fn);
int conv_vgm_intro(const char *intro_vgm_fn, const char *bin_fn);
int conv_vgm_loop(const char *loop_vgm_fn, const char *bin_fn);
int conv_vgm(const char *intro_vgm_fn, const char *loop_vgm_fn, const char *bin_fn);

#endif
