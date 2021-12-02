//
//  CSVExportView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/13.
//

import SwiftUI

struct CSVExportView: View {
    
    @StateObject var csvExporter = CSVExporter()
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Button("エクスポート") {
                    csvExporter.export()
                }
                Spacer()
            }
        }
        .navigationBarTitle(Text("CSVファイルを出力"), displayMode: .inline)
        .sheet(item: $csvExporter.fileUrl) { (fileUrl)  in
            ActivityView(fileUrl: fileUrl)
        }
    }
}

struct CSVExportView_Previews: PreviewProvider {
    static var previews: some View {
        CSVExportView()
    }
}
