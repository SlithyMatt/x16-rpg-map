#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void main(int argc, char **argv) {
   FILE *ifp;
   FILE *ofp;

   int address;
   uint8_t *idata;
   int iwidth;
   int owidth;
   int factor;
   long jump;
   long rewind;
   long next;
   int row;
   int offset;

   if (argc < 5) {
      printf("Usage: %s [input bitmap] [input width] [output bitmap] [output width]\n", argv[0]);
      return;
   }

   ifp = fopen(argv[1], "rb");
   if (ifp == NULL) {
      printf("Error opening %s for reading\n", argv[1]);
      return;
   }

   iwidth = atoi(argv[2]);

   ofp = fopen(argv[3], "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", argv[3]);
      return;
   }

   owidth = atoi(argv[4]);

   if (owidth < 8) {
      printf("Output tile width must be at least 8 pixels\n");
      return;
   }

   if (iwidth % owidth != 0) {
      printf("Input tile width must be even multiple of %d\n", owidth);
      return;
   }

   factor = iwidth / owidth;
   jump = (long)(owidth * (owidth - 1));
   rewind = -1L * (long)factor * ((long)owidth + jump) + (long)owidth;
   next = -1L * rewind - jump;

   idata = malloc(iwidth);

   while (!feof(ifp)) {
      for (row = 0; row < owidth; row++) {
         if (fread(idata,1,iwidth,ifp) > 0) {
            for (int offset = 0; offset < iwidth; offset += owidth) {
               fwrite(&idata[offset],1,owidth,ofp);
               fseek(ofp,jump,SEEK_CUR);
            }
            fseek(ofp,rewind,SEEK_CUR);
         }
      }
      fseek(ofp,next,SEEK_CUR);
   }

   fclose(ifp);
   fclose(ofp);
}
