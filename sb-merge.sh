#!/usr/bin/env bash

jeff_words=$(curl -H "apikey:xxxxx" --form "file=@jeff.jpg"  https://api.ocr.space/Parse/Image | jq '.ParsedResults[0].ParsedText')
charles_words=$(curl -H "apikey:xxxxx" --form "file=@charles.jpg"  https://api.ocr.space/Parse/Image | jq '.ParsedResults[0].ParsedText')
#echo $words

# Replace the \r\n literals with semicolons
jeff_words=$(sed 's/\\r\\n/;/g' <<< $jeff_words)
charles_words=$(sed 's/\\r\\n/;/g' <<< $charles_words)

# Strip off the leading and trailing quotes
jeff_words=$(sed 's/\"//g' <<< $jeff_words)
charles_words=$(sed 's/\"//g' <<< $charles_words)

declare -A jeff_array
declare -A charles_array

# Tokenize the words
IFS=';'     
read -ra j_tokens <<< "$jeff_words"  
for i in "${j_tokens[@]}"; do  
    jeff_array[$i]=0
done

IFS=';'     
read -ra c_tokens <<< "$charles_words"  
for i in "${c_tokens[@]}"; do  
    charles_array[$i]=0
done

declare -a jeff_misses
declare -a charles_misses

for jeff_word in "${!jeff_array[@]}"; do 
    if [ -z ${charles_array[$jeff_word]+_} ]; then
        charles_misses+=($jeff_word);
    fi
done

for charles_word in "${!charles_array[@]}"; do 
    if [ -z ${jeff_array[$charles_word]+_} ]; then
        jeff_misses+=($charles_word);
    fi
done

echo -n "Charles misses: "
for key in "${charles_misses[@]}"; do echo -n "$key "; done
echo " "
echo -n "J&D misses: "
for key in "${jeff_misses[@]}"; do echo -n "$key "; done




