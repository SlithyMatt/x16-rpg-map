#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <json-c/json.h>
#include <libxml/tree.h>
#include <libxml/parser.h>

#define MAX_JSON_SIZE 65536

typedef struct tileset_s {
   struct tileset_s *next;
   const char *set;
   int start;
} tileset_t;

typedef struct offset_s {
   struct offset_s *next;
   int offset;
   int start;
} offset_t;

int parse_layer_json(struct json_object *layer, tileset_t **tile_list, offset_t **offset_list) {
   struct json_object *tiles;
   tileset_t *tile;
   struct json_object *offsets;
   offset_t *offset;
   struct json_object *element;
   struct json_object *property;
   int i;

   json_object_object_get_ex(layer,"tiles",&tiles);

   if (tiles == NULL) {
      printf("Layer has no \"tiles\" value\n");
      return -1;
   }

   if (json_object_get_type(tiles) != json_type_array) {
      printf("\"tiles\" value is not an array\n");
      return -1;
   }

   for (i = 0; i < json_object_array_length(tiles); i++) {
      if (i == 0) {
         tile = malloc(sizeof(tileset_t));
         *tile_list = tile;
      } else {
         tile->next = malloc(sizeof(tileset_t));
         tile = tile->next;
      }
      tile->next = NULL;
      element = json_object_array_get_idx(tiles,i);
      json_object_object_get_ex(element,"set",&property);
      tile->set = json_object_get_string(property);
      json_object_object_get_ex(element,"start",&property);
      tile->start = json_object_get_int(property);
   }

   json_object_object_get_ex(layer,"offsets",&offsets);

   if (offsets == NULL) {
      printf("Layer has no \"offsets\" value\n");
      return -1;
   }

   if (json_object_get_type(offsets) != json_type_array) {
      printf("\"offsets\" value is not an array\n");
      return -1;
   }

   for (i = 0; i < json_object_array_length(offsets); i++) {
      if (i == 0) {
         offset = malloc(sizeof(offset_t));
      } else {
         offset->next = malloc(sizeof(offset_t));
         offset = offset->next;
      }
      offset->next = NULL;
      element = json_object_array_get_idx(offsets,i);
      json_object_object_get_ex(element,"offset",&property);
      offset->offset = json_object_get_int(property);
      json_object_object_get_ex(element,"start",&property);
      offset->start = json_object_get_int(property);
   }

   return 0;
}

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
   struct json_object *layers;
   struct json_object *layer0;
   struct json_object *layer1;

   tileset_t *l0_tiles = NULL;
   offset_t *l0_offsets = NULL;
   tileset_t *l1_tiles = NULL;
   offset_t *l1_offsets = NULL;

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

   if (parsed_json == NULL) {
      printf("Failed to parse %s as JSON\n", argv[2]);
   }

   json_object_object_get_ex(parsed_json,"map",&map);

   if (map == NULL) {
      printf("%s does not have a \"map\" value\n", argv[2]);
      return;
   }

   if (strcmp(json_object_get_string(map), argv[1]) != 0) {
      printf("JSON map value (%s) does not match XML filename (%s)\n",
         json_object_get_string(map), argv[1]);
      return;
   }

   json_object_object_get_ex(parsed_json,"layers",&layers);

   if (layers == NULL) {
      printf("%s does not have a \"layers\" value\n", argv[2]);
      return;
   }

   if (json_object_get_type(layers) != json_type_array) {
      printf("\"layers\" value in %s is not an array\n", argv[2]);
      return;
   }

   layer0 = json_object_array_get_idx(layers,0);
   layer1 = json_object_array_get_idx(layers,1);

   if (parse_layer_json(layer0, &l0_tiles, &l0_offsets) < 0) {
      printf("Error parsing layer 0 JSON\n");
      return;
   }

   if (parse_layer_json(layer1, &l1_tiles, &l1_offsets) < 0) {
      printf("Error parsing layer 1 JSON\n");
      return;
   }

   printf("Parsing %s...\n", argv[1]);

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
