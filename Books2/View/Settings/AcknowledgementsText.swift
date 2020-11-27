//
//  AcknowledgementsText.swift
//  Books2
//
//  Created by 外園玲央 on 2020/10/27.
//  Copyright © 2020 Reo Hokazono. All rights reserved.
//

import SwiftUI

struct LicenseText: View {
	
	var contentsText = ""
	
	init() {
		guard let path = Bundle.main.path(forResource: "acknowledgements", ofType: "txt") else { return }
		guard let text = try? String(contentsOfFile: path) else { return }
		contentsText = text
	}
	
    var body: some View {
		ScrollView(content: {
			Text(contentsText)
				.font(.body)
		})
		.padding(.horizontal)
		.navigationBarTitle("著作権情報")
    }
}

struct LicenseText_Previews: PreviewProvider {
    static var previews: some View {
        LicenseText()
    }
}
