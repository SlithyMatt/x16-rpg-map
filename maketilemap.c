#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <json-c/json.h>
#include <libxml/tree.h>
#include <libxml/parser.h>

#define MAX_JSON_SIZE 65536

void main(int argc, char **argv) {
   FILE *json_fp;
   FILE *ofp;

   int address;
   uint8_t odata[2];
   xmlDocPtr doc;
   xmlNode *root_element = NULL;
   char json_buffer[MAX_JSON_SIZE];
   struct json_object *parsed_json;
   struct json_object *map;


   if (argc < 5) {
      printf("Usage: %s [tilemap XML input] [layer JSON input] [layer 0 binary output] [layer 1 binary output]\n", argv[0]);
      return;
   }

   doc = xmlReadFile(argv[1], NULL, 0);
   if (doc == NULL) {
      printf("Failed to parse %s as XML\n", argv[1]);
   }

   root_element = xmlDocGetRootElement(doc);
   printf("XML Root name: %s\n", root_element->name);

   json_fp = fopen(argv[2], "r");
   if (json_fp == NULL) {
      printf("Error opening %s for reading\n", argv[1]);
      return;
   }

   fread(json_buffer, MAX_JSON_SIZE, 1, json_fp);
	fclose(json_fp);
   parsed_json = json_tokener_parse(json_buffer);

   json_object_object_get_ex(parsed_json,"map",&map);
   printf("JSON map: %s\n", json_object_get_string(map));

   if (parsed_json == NULL) {
      printf("Failed to parse %s as JSON\n", argv[2]);
   }


   // start with layer 0

   ofp = fopen(argv[3], "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", argv[3]);
      return;
   }

   // set default load address to 0x0000
   address = 0x0000;

   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);



   fclose(ofp);

   // then layer 1

   ofp = fopen(argv[4], "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", argv[4]);
      return;
   }

   // set default load address to 0x0000
   address = 0x0000;

   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);



   fclose(ofp);

   xmlFreeDoc(doc);
}
