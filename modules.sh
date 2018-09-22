#!/bin/bash

for i in $@; do
	mod="/${i}.ko:"
	deps=$(grep "$mod" /usr/armv6j-hardfloat-linux-gnueabi/lib/modules/4.9.80+/modules.dep | cut -f2 -d:)
	deps=$(basename -a $deps 2>/dev/null | tac)
	result="$result $(echo "$deps" | sed 's/.ko//g') $i"
done

echo $result | tr ' ' '\n' | perl -ne 'print if ++$k{$_}==1'
