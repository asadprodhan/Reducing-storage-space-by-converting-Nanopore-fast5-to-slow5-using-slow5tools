#!/usr/bin/env bash

for x in *; do
    if [ -d "$x" ]; then
        slow5tools f2s "$x" -d "${x}_blow5"
    fi

done
