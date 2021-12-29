# IntlCreator
Create Intl Class for Swift with stringsFile

## 1. Add a fast lane like below

put IntlCreator.sh in the fastlane directory

```
    lane :intl do
        sh "bash ./IntlCreator.sh"
    end
```

## 2. Correct the path in the IntlCreator.sh for Intl.swift and Localizable.strings

```
projPath="./"

stringFilePath="$projPath/Localizable.strings"

#指定Intl.swift 存放的路径
intlPath="$projPath"
intlFileName="Intl"
intlSwiftFilePath="$intlPath/$intlFileName.swift"
```

## 3. Change the Localizable.strings
 
International = "国际化";

InternationnalIn = "国际化在%@";

## 4. Excute 'fastlane intl' in the terminal

it will automatically create a Intl.swift file for you

``` swift
struct Intl {
    
    static func string(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }

    /// 国际化
    static let International: String = Intl.string("International")
    /// 国际化在%@
    static func InternationnalIn(_ arg: CVarArg) -> String {
        return String(format: Intl.string("InternationnalIn"), arg)
    }

}

```

You can use it like this

```

Intl.International

Intl.InternationalIn("China")

```

