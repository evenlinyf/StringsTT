# intlCreator
Create Intl Class for Swift with stringsFile

## 1. Add a fast lane like below

put this shell file in the fastlane directory

```
    lane :intl do
        sh "bash ./IntlCreator.sh"
    end
```

## 2. Correct the path in the creator for Intl.swift and Localizable.strings

## 3. Change the Localizable.strings
 
## 4. excute 'fastlane intl' in the terminal

it will automatically create a Intl.swift file for you

You can use it like this

```

Intl.International

Intl.InternationalIn("China")

```

