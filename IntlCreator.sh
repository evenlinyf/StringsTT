#!/bin/bash

stringFilePath="/Users/chenying/Documents/GitHub/IntlCreator/Localizable.strings"
markString=";"

if [ ! -x "$stringFilePath" ]; then
	
	cat $stringFilePath | while read intlLine; do
		
		result=$(echo $intlLine | grep "${markString}")
		if [[ "$result" != "" ]]; then
			echo  "Line: "$intlLine
		fi
		
	done
fi