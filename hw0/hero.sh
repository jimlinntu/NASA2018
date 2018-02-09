#!/bin/sh

# Part 1: Cave
CAVE_PATH='./nasa_land/cave/chest'
CAVE_PASSWD=$(cat $CAVE_PATH)
echo -e "cave: $CAVE_PASSWD"

# Part 2: Village
VILLAGE_PATH='./nasa_land/village/bookshelf/'
VILLAGE_PASSWD=$(ls -1 -S "${VILLAGE_PATH}" | awk 'NR==1' )
echo -e "village: ${VILLAGE_PASSWD}"

# Part 3: Shop
SHOP_PATH='./nasa_land/shop/'
corrected_list=$( cat "${SHOP_PATH}list" | sed 's/\<poison\>/potion/g' ) 
SHOP_PASSWD=$(printf "${corrected_list}" | "${SHOP_PATH}merchant" | awk 'END{print}' | rev |\
	cut -d' ' -f 1 |rev)
echo -e "shop: ${SHOP_PASSWD}"

# Part 4: Castle
CASTLE_PATH="./nasa_land/castle/"
CASTLE_PASSWD=$(printf "hit\n%0.s" {1..10000} | "${CASTLE_PATH}/boss" | awk 'END {print}' |rev | cut -d' ' -f 1 |rev)
echo -e "castle: ${CASTLE_PASSWD}"
exit 0
