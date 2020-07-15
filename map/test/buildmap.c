#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define BANK_SIZE 8192
#define MAX_FN_SIZE 256

uint8_t *zeros;

int copy_file(const char *ifn, FILE *ofp, int banks) {
   FILE *ifp;
   uint8_t buffer[BANK_SIZE];
   size_t size;
   int bank = 0;

   ifp = fopen(ifn, "rb");

   if (ifp == NULL) {
      printf("Error opening %s\n", ifn);
      return -1;
   }

   fread(buffer,1,2,ifp); // header

   while (bank++ < banks) {
      size = fread(buffer,1,BANK_SIZE,ifp);
      fwrite(buffer,1,size,ofp);
      if (size < BANK_SIZE) {
         fwrite(zeros,1,BANK_SIZE-size,ofp);
      }
   }

   fclose(ifp);

   return 0;
}

int get_next_file(FILE *cfgFile, FILE *ofp, int banks) {
   char filename[MAX_FN_SIZE];

   fgets(filename,MAX_FN_SIZE,cfgFile);
   strtok(filename,"\r\n");

   copy_file(filename,ofp,banks);

   return 0;
}

int build_all(const char *cfg_fn, FILE *ofp) {
   FILE *cfgFile;

   cfgFile = fopen(cfg_fn, "r");

   if (cfgFile == NULL) {
      printf("Error opening %s\n", cfg_fn);
      return -1;
   }

   // Music: 2 banks
   if (get_next_file(cfgFile,ofp,2) < 0) {
      return -1;
   }

   // Sound: 2 banks
   if (get_next_file(cfgFile,ofp,2) < 0) {
      return -1;
   }

   // Tilemap 0: 1 bank
   if (get_next_file(cfgFile,ofp,1) < 0) {
      return -1;
   }

   // Tilemap 1: 4 banks
   if (get_next_file(cfgFile,ofp,4) < 0) {
      return -1;
   }

   // Tileset 0: 4 banks
   if (get_next_file(cfgFile,ofp,4) < 0) {
      return -1;
   }

   // Tileset 1: 3 banks
   if (get_next_file(cfgFile,ofp,3) < 0) {
      return -1;
   }

   // Sprites: 4 banks
   if (get_next_file(cfgFile,ofp,4) < 0) {
      return -1;
   }

   // Map config: 1 bank
   if (get_next_file(cfgFile,ofp,1) < 0) {
      return -1;
   }

   // Map metadata: 1 bank
   if (get_next_file(cfgFile,ofp,1) < 0) {
      return -1;
   }

   // Scripts: 2 banks
   if (get_next_file(cfgFile,ofp,2) < 0) {
      return -1;
   }

   fclose(cfgFile);
}

int replace_music(const char *patch_fn, const char *orig_fn, FILE *ofp) {
   copy_file(orig_fn,ofp,24);
   fseek(ofp,2,SEEK_SET);
   copy_file(patch_fn,ofp,2);
}

int replace_sound(const char *patch_fn, const char *orig_fn, FILE *ofp) {
   copy_file(orig_fn,ofp,24);
   fseek(ofp,2+BANK_SIZE*2,SEEK_SET);
   copy_file(patch_fn,ofp,2);
}

int replace_sprites(const char *patch_fn, const char *orig_fn, FILE *ofp) {
   copy_file(orig_fn,ofp,24);
   fseek(ofp,2+BANK_SIZE*16,SEEK_SET);
   copy_file(patch_fn,ofp,4);
}

int main (int argc, char **argv) {
   FILE *ofp;
   uint8_t buffer[2];
   const char *ofn;

   if (argc < 2) {
      printf("Usage: %s [config file] [output file]\n", argv[0]);
      printf("   or: %s [--music|--sound|--sprites] [patch file] [original file] [output file]", argv[0]);
      return -1;
   }

   zeros = calloc(1,BANK_SIZE);

   if (strncmp(argv[1],"--",2) == 0) {
      if (argc < 5) {
         printf("Usage: %s [config file] [output file]\n", argv[0]);
         printf("   or: %s [--music|--sound|--sprites] [patch file] [original file] [output file]", argv[0]);
         return -1;
      }
      ofn = argv[4];
   } else {
      ofn = argv[2];
   }

   ofp = fopen(ofn, "wb");

   if (ofp == NULL) {
      printf("Error opening %s\n", ofn);
      return -1;
   }

   buffer[0] = 0x00;
   buffer[1] = 0xA0;
   fwrite(buffer,1,2,ofp); // header

   if (strcmp(argv[1],"--music") == 0) {
      replace_music(argv[2],argv[3],ofp);
   } else if (strcmp(argv[1],"--sound") == 0) {
      replace_sound(argv[2],argv[3],ofp);
   } else if (strcmp(argv[1],"--sprites") == 0) {
      replace_sprites(argv[2],argv[3],ofp);
   } else {
      build_all(argv[1], ofp);
   }

   fclose(ofp);
   free(zeros);
   return 0;
}
