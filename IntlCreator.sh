#!/bin/bash

createDate=`date +%Y-%m-%d_%H:%M`
projPath="./"

stringFilePath="$projPath/Localizable.strings"

#指定Intl.swift 存放的路径
intlPath="$projPath"
intlFileName="Intl"
intlSwiftFilePath="$intlPath/$intlFileName.swift"

#判断swift文件是否存在
if [ ! -d $intlPath ]; then
	echo "文件夹路径错误"
else
	echo "存放swift文件的文件夹已存在"
	cd $intlPath
fi

rm $intlFileName.swift

if [ ! -f $intlSwiftFilePath ]; then
	echo "Intl.swift deleted， recreating"
	cat >$intlSwiftFilePath<<EOF
//
//  Intl.swift
//  
//
//  Created by IntlCreator on $createDate.
//

import UIKit

struct Intl {
	
	static func string(_ string: String) -> String {
		return NSLocalizedString(string, comment: "")
	}

EOF
	echo "swift intl file created 🎉🎉🎉"
else
	echo "swift file already exist"
fi

#逐行解析strings文件
if [ ! -x "$stringFilePath" ]; then
	
	cat $stringFilePath | while read intlLine; do
		#筛选出包含分号的一行
		result=$(echo $intlLine | grep ";")
		if [[ "$result" != "" ]]; then
			
			#			echo $intlLine
			#取出 Intl key
			#清空所有的空格
			clearWhiteSpaceResult=${intlLine//" "/""}
			
			#截取=号左边的字符
			intlKey=${clearWhiteSpaceResult%=*}
			#			echo $intlKey
			
			#截取=号右边的字符
			intlValue=${clearWhiteSpaceResult#*=}
			comment=${intlValue//"\""/""}
			comment=${comment//";"/""}
			echo $comment
			if [[ $intlValue =~ "%" ]]; then
#				echo $intlValue
				#向Intl.swift 拼接类属性
				cat >>$intlSwiftFilePath<<EOF
	/// $comment
	static func $intlKey(_ arg: CVarArg) -> String {
		return String(format: Intl.string("$intlKey"), arg)
	}
EOF
			else
				#向Intl.swift 拼接类属性
				cat >>$intlSwiftFilePath<<EOF
	/// $comment
	static var $intlKey: String = Intl.string("$intlKey")
EOF
			fi
			

		fi
		
	done
fi

cat >>$intlSwiftFilePath<<EOF

}
EOF

echo "Intl.swift created succeeded 🎉🎉🎉"
open $intlSwiftFilePath
