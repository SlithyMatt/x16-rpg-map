#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void main(int argc, char **argv) {
   FILE *ifp;
   FILE *ofp;
   
   uint8_t idata[3];
   uint8_t odata[2];
   int address;

   if (argc < 3) {
      printf("Usage: %s [24-bit palette] [12-bit palette] [load address]\n", argv[0]);
      return;
   }

   ifp = fopen(argv[1], "r");
   if (ifp == NULL) {
      printf("Error opening %s for reading\n", argv[1]);
      return;
   }
   ofp = fopen(argv[2], "w");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", argv[2]);
      return;
   }
   
   // start 12-bit with default address
   if (argc >= 4) {
      sscanf(argv[3],"%x",&address);
   } else {
      // set default load address to 0xA000
      address = 0xA000;
   }
   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);
   
   while (!feof(ifp)) {
      if (fread(idata,1,3,ifp) > 0) {
         odata[0] = (idata[1] & 0xf0) |         // green
                    ((idata[2] & 0xf0) >> 4);   // blue
         odata[1] = (idata[0] & 0xf0) >> 4;     // red
         fwrite(odata,1,2,ofp);
      }
   }
}   

