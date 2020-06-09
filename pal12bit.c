#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void main(int argc, char **argv) {
   FILE *ifp;
   FILE *ofp;

   uint8_t idata[3];
   uint8_t odata[2];
   int address;
   int i;

   if (argc < 3) {
      printf("Usage: %s [12-bit palette] [24-bit palette]...\n", argv[0]);
      return;
   }

   ofp = fopen(argv[1], "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", argv[2]);
      return;
   }

   // start 12-bit with default address
   address = 0xFA00;
   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);

   for (i = 2; i < argc; i++) {
      ifp = fopen(argv[i], "rb");
      if (ifp == NULL) {
         printf("Error opening %s for reading\n", argv[i]);
         return;
      }

      while (!feof(ifp)) {
         if (fread(idata,1,3,ifp) > 0) {
            odata[0] = (idata[1] & 0xf0) |         // green
                       ((idata[2] & 0xf0) >> 4);   // blue
            odata[1] = (idata[0] & 0xf0) >> 4;     // red
            fwrite(odata,1,2,ofp);
         }
      }
      fclose(ifp);
   }
   fclose(ofp);
}
