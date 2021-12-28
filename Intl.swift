//
//  Intl.swift
//  
//
//  Created by IntlCreator on 2021-12-28_13:20.
//

import UIKit

struct Intl {
	
	static func string(_ string: String) -> String {
		return NSLocalizedString(string, comment: "")
	}

	/// 国际化
	static var International: String = Intl.string("International")
	/// 国际化在%@
	static func InternationnalIn(_ arg: CVarArg) -> String {
		return String(format: Intl.string("InternationnalIn"), arg)
	}

}
