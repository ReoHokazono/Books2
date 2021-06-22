//
//  AboutView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Form {
            
            HStack {
                Spacer()
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .width(120)
                    .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text("BookNote")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            
            Text("BookNoteは2020年12月から配信を開始しました。個人で開発しています。みなさまからのフィードバックをお待ちしています。")
                .font(.callout)
                .padding([.top, .bottom], 15)
                .lineSpacing(2)
            
            Button("Blog") {
                guard let url = URL(string: "https://note.com/hokazono_reo") else { return }
                openURL(url)
            }
            .foregroundColor(.primary)
            
            Button("Twitter") {
                guard let url = URL(string: "https://twitter.com/hkzn_fy") else { return }
                openURL(url)
            }
            .foregroundColor(.primary)
            
            HStack {
                Spacer()
                Text("©2020 Reo Hokazono")
                    .font(.caption)
                Spacer()
            }
            
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
