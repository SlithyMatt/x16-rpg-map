#ifndef MAKETILEMAP_H
#define MAKETILEMAP_H

#define MAX_JSON_SIZE 65536

#define L0_ROWS 64
#define L0_COLUMNS 64
#define L1_ROWS 128
#define L1_COLUMNS 128

int maketilemap(const char *xml_fn, const char *json_fn, const char *layer0_fn, const char *layer1_fn);

#endif
