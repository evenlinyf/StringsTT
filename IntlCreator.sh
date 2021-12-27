#!/bin/bash

createDate=`date +%Y-%m-%d_%H:%M`
projPath="../"
echo $projPath

stringFilePath="$projPath/projName/zh-Hans.lproj/Localizable.strings"

#如果存在这个字符， 就会解析
tagString=";"

intlPath="$projPath/wuwu"
intlFileName="Intl"
intlSwiftFilePath="$intlPath/$intlFileName.swift"

#判断swift文件是否存在
if [ ! -d $intlPath ]; then
	echo "文件夹路径错误"
else
	echo "存放swift文件的文件夹已存在"
	cd $intlPath
fi

rm *.swift

if [ ! -f $intlSwiftFilePath ]; then
	echo "swift 文件已删除， 正在重新创建"
	cat >$intlSwiftFilePath<<EOF
//
//  Intl.swift
//  wuwu
//
//  Created by IntlCreator shell script on $createDate.
//

import UIKit

struct Intl {
	
	static func string(_ string: String) -> String {
		return NSLocalizedString(string, comment: "")
	}

	static func strings(_ strings: String...) -> String {
		let result = strings.reduce("", +)
		return result
	}
}
EOF
	echo "swift intl file created 🎉🎉🎉"
else
	echo "swift file already exist"
fi

cat >>$intlSwiftFilePath<<EOF
extension Intl {

EOF

#逐行解析strings文件
if [ ! -x "$stringFilePath" ]; then
	
	cat $stringFilePath | while read intlLine; do
		#筛选出包含分号的一行
		result=$(echo $intlLine | grep "${tagString}")
		if [[ "$result" != "" ]]; then
			
#			echo $intlLine
			#取出 Intl key
			#清空所有的空格
			clearWhiteSpaceResult=${intlLine//" "/""}
			intlKey=${clearWhiteSpaceResult/=*}
#			echo $intlKey
			#向Intl.swift 拼接类属性
			cat >>$intlSwiftFilePath<<EOF
	/// $intlLine
	static var $intlKey: String{ get { return Intl.string("$intlKey") } }
EOF
		fi
		
	done
fi

cat >>$intlSwiftFilePath<<EOF

}
EOF
echo "Intl Class 文件创建成功 🎉🎉🎉 "
open $intlSwiftFilePath
