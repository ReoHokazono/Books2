//
//  iCloudSettingsGuideView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/28.
//

import SwiftUI

struct iCloudSettingsGuideView: View {
    var body: some View {
        Form {
            Text("iCloud同期のオン／オフは「設定」から変更できます。")
                .font(.body)
                .fontWeight(.bold)
            Group {
                HStack {
                    Text("1.")
                    Text("「設定」>「[ユーザ名]」の順に選択します。")
                }
                HStack {
                    Text("2.")
                    Text("「iCloud」をタップします。")
                }
                HStack(alignment: .top) {
                    Text("3.")
                    Text("リストから、Keyplateを探し、iCloud同期のオン／オフを変更します。")
                }
            }
            .font(.footnote)
            
            Text("iCloud同期をオフにした場合、データはiCloud、ローカルの両方に保管されます。iCloud同期をオフにする場合、事前にCSVファイルをエクスポートすることをおすすめします。")
                .font(.footnote)
                .foregroundColor(.secondaryLabel)
            Image("iCloudGuide")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct iCloudSettingsGuideView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudSettingsGuideView()
    }
}
