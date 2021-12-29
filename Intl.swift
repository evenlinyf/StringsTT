//
//  Intl.swift
//	https://github.com/evenlinyf/IntlCreator
//
//  Created by IntlCreator on 2021-12-29_18:05.
//

import UIKit

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
