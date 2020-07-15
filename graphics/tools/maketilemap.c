#include "maketilemap.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <json-c/json.h>
#include <libxml/tree.h>
#include <libxml/parser.h>

#define MAX_GID 0x3FFFFFFF

typedef struct tileset_s {
   struct tileset_s *next;
   const char *set;
   int start;
   int firstgid;
   int lastgid;
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
         *offset_list = offset;
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

int gid2index(int gid, tileset_t *tiles) {
   tileset_t *tileset = tiles;
   int start = 0;
   int firstgid = 1;

   // zero means "empty" so assume tile index 0 will be completely transparent
   if (gid == 0) {
      return 0;
   }

   while (tiles != NULL) {
      if ((gid >= tiles->firstgid) && (gid <= tiles->lastgid)) {
         start = tiles->start;
         firstgid = tiles->firstgid;
      }
      tiles = tiles->next;
   }

   return gid - firstgid + start;
}

int index2offset(int index, offset_t *offsets) {
   offset_t *offset_ptr = offsets;
   int offset = 0;

   while (offset_ptr != NULL) {
      if (index >= offset_ptr->start) {
         offset = offset_ptr->offset;
      }
      offset_ptr = offset_ptr->next;
   }

   return offset;
}

int maketilemap(const char *xml_fn, const char *json_fn, const char *layer0_fn, const char *layer1_fn) {
   FILE *json_fp;
   FILE *ofp;

   int address;
   uint8_t odata[2];
   xmlDocPtr doc;
   xmlNodePtr xml_map_tree = NULL;
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

   tileset_t *tileset;
   xmlNodePtr xml_node;
   int firstgid;
   xmlChar *csv;
   int row;
   int column;
   unsigned int gid;
   int index;
   int offset;

   doc = xmlReadFile(xml_fn, NULL, 0);
   if (doc == NULL) {
      printf("Failed to parse %s as XML\n", xml_fn);
   }

   xml_map_tree = xmlDocGetRootElement(doc);

   json_fp = fopen(json_fn, "r");
   if (json_fp == NULL) {
      printf("Error opening %s for reading\n", json_fn);
      return -1;
   }

   fread(json_buffer, MAX_JSON_SIZE, 1, json_fp);
	fclose(json_fp);
   parsed_json = json_tokener_parse(json_buffer);

   if (parsed_json == NULL) {
      printf("Failed to parse %s as JSON\n", json_fn);
   }

   json_object_object_get_ex(parsed_json,"map",&map);

   if (map == NULL) {
      printf("%s does not have a \"map\" value\n", json_fn);
      return -1;
   }

   if (strcmp(json_object_get_string(map), xml_fn) != 0) {
      printf("Warning: JSON map value (%s) does not match XML filename (%s)\n",
         json_object_get_string(map), xml_fn);
   }

   json_object_object_get_ex(parsed_json,"layers",&layers);

   if (layers == NULL) {
      printf("%s does not have a \"layers\" value\n", json_fn);
      return -1;
   }

   if (json_object_get_type(layers) != json_type_array) {
      printf("\"layers\" value in %s is not an array\n", json_fn);
      return -1;
   }

   layer0 = json_object_array_get_idx(layers,0);
   layer1 = json_object_array_get_idx(layers,1);

   if (parse_layer_json(layer0, &l0_tiles, &l0_offsets) < 0) {
      printf("Error parsing layer 0 JSON\n");
      return -1;
   }

   if (parse_layer_json(layer1, &l1_tiles, &l1_offsets) < 0) {
      printf("Error parsing layer 1 JSON\n");
      return -1;
   }

   printf("Parsing %s...\n", xml_fn);

   xml_node = xml_map_tree->children;

   if (strcmp(xml_node->name,"text") == 0) {
      xml_node = xml_node->next;
   }

   while ((xml_node != NULL) && (strcmp(xml_node->name,"tileset") == 0)) {
      firstgid = atoi(xmlGetProp(xml_node,"firstgid"));
      tileset = l0_tiles;
      while ((tileset != NULL) && (strcmp(tileset->set, xmlGetProp(xml_node,"source")) != 0)) {
         tileset = tileset->next;
      }
      if (tileset == NULL) {
         tileset = l1_tiles;
         while ((tileset != NULL) && (strcmp(tileset->set, xmlGetProp(xml_node,"source")) != 0)) {
            tileset = tileset->next;
         }
      }
      if (tileset == NULL) {
         printf("XML tileset %s not found in JSON\n", xmlGetProp(xml_node,"source"));
         return -1;
      }
      tileset->firstgid = firstgid;

      xml_node = xml_node->next;
      if (strcmp(xml_node->name,"text") == 0) {
         xml_node = xml_node->next;
      }

      if (strcmp(xml_node->name,"tileset") == 0) {
         tileset->lastgid = atoi(xmlGetProp(xml_node,"firstgid")) - 1;
      } else {
         tileset->lastgid = MAX_GID;
      }
   }

   // start with layer 0

   if ((xml_node == NULL) || (strcmp(xml_node->name,"layer") != 0)) {
      printf("Layer 0 not found in %s\n", xml_fn);
      return -1;
   }

   ofp = fopen(layer0_fn, "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", layer0_fn);
      return -1;
   }

   // set default load address to 0x0000
   address = 0x0000;

   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);

   xml_node = xml_node->children;
   if (strcmp(xml_node->name,"text") == 0) {
      xml_node = xml_node->next;
   }
   xml_node = xml_node->children;
   csv = strtok(xml_node->content," ,\r\n");

   for (row = 0; row < L0_ROWS; row++) {
      // skip dummy row created for alignment
      for (column = 0; column < L0_COLUMNS*2-1; column++) {
         strtok(NULL," ,\r\n");
      }
      for (column = 0; column < L0_COLUMNS; column++) {
         csv = strtok(NULL," ,\r\n");
         gid = atoi(csv);
         index = gid2index(gid & 0x3FF,l0_tiles);
         offset = index2offset(index,l0_offsets);
         odata[0] = index & 0xFF;
         odata[1] = (offset << 4) | ((gid & 0x80000000) >> 29) | ((gid & 0x40000000) >> 27) | ((index & 0x300) >> 8);
         fwrite(odata,1,2,ofp);
         // skip dummy column created for alignment
         strtok(NULL," ,\r\n");
      }
      // get the first entry in the next dummy row
      strtok(NULL," ,\r\n");
   }

   fclose(ofp);

   // then layer 1

   xml_node = xml_node->parent->parent->next;
   if (strcmp(xml_node->name,"text") == 0) {
      xml_node = xml_node->next;
   }

   if ((xml_node == NULL) || (strcmp(xml_node->name,"layer") != 0)) {
      printf("Layer 1 not found in %s\n", xml_fn);
      return -1;
   }

   ofp = fopen(layer1_fn, "wb");
   if (ofp == NULL) {
      printf("Error opening %s for writing\n", layer1_fn);
      return -1;
   }

   // set default load address to 0x0000
   address = 0x0000;

   odata[0] = (uint8_t) (address & 0x00FF);
   odata[1] = (uint8_t) ((address & 0xFF00) >> 8);
   fwrite(odata,1,2,ofp);

   xml_node = xml_node->children;
   if (strcmp(xml_node->name,"text") == 0) {
      xml_node = xml_node->next;
   }
   xml_node = xml_node->children;
   csv = strtok(xml_node->content, " ,\r\n");

   for (row = 0; row < L1_ROWS; row++) {
      for (column = 0; column < L1_COLUMNS; column++) {
         gid = atoi(csv);
         index = gid2index(gid & 0x3FF,l1_tiles);
         offset = index2offset(index,l1_offsets);
         odata[0] = index & 0xFF;
         odata[1] = (offset << 4) | ((gid & 0x80000000) >> 29) | ((gid & 0x40000000) >> 27) | ((index & 0x300) >> 8);
         fwrite(odata,1,2,ofp);
         // get next token
         csv = strtok(NULL," ,\r\n");
      }
   }


   fclose(ofp);

   xmlFreeDoc(doc);

   return 0;
}

#ifdef STANDALONE
void main(int argc, char **argv) {
   if (argc < 5) {
      printf("Usage: %s [tilemap XML input] [layer JSON input] [layer 0 binary output] [layer 1 binary output]\n", argv[0]);
      return;
   }

   maketilemap(argv[1], argv[2], argv[3], argv[4]);
}
#endif
