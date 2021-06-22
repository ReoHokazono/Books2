//
//  ScannerView.swift
//  books
//
//  Created by 外園玲央 on 2020/04/19.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    
    @State var isRunning:Bool = false
    @State var isFlashOn = false
    @State var isNotAuthorized = false
    @Environment(\.openURL) var openURL
    
    var isbnCodeDetected:(_ isbn:String)->()
    var manualInput: () -> ()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if isRunning {
                CaptureView(
                    isRunning: $isRunning,
                    isFlashOn: $isFlashOn,
                    isNotAuthorized: $isNotAuthorized) { (isbn) in
                    self.isbnCodeDetected(isbn)
                }
                
//                GeometryReader(content: { geometry in
//                    Image("Cap")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                })

                
                if isNotAuthorized {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Spacer()
                            Text("カメラへのアクセスを許可してください")
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                                .padding(.top, 25)
                            Button("「設定」を開く") {
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                                openURL(settingsUrl)
                            }
                            .foregroundColor(.accentColor)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                HStack {
                    
                    Button(action: {
                        isFlashOn.toggle()
                    }, label: {
                        Image(systemName: isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 40, height: 40, alignment: .center)
                            .background(isFlashOn ? .accentColor : .systemGray2)
                            .cornerRadius(20)
                            .padding([.bottom, .trailing])
                            
                    })
                    
                    
                    Spacer()
                    Button(action: {
                        self.isRunning = false
                        self.isFlashOn = false
                    }, label: {
                        Text("完了")
                            .padding(.horizontal, 20)
                            .frame(height: 40, alignment: .center)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(20, style: .continuous)
                            .padding([.bottom, .leading])
                    })
                    
                    
                }
                .padding()
                
            } else {
                
                GeometryReader { geometry in
                    VStack {
                        Button(action: {
                            self.isRunning = true
                        }) {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 30))
                                Text("ISBNコードをスキャン")
                                    .fontWeight(.medium)
                            }
                            .padding(10)
                            .foregroundColor(.accentColor)
                            .background(.systemBackground)
                            .cornerRadius(15, style: .continuous)

                        }
                        Spacer()
                            .frame(height: 15)
                        Button("手動で入力") {
                            manualInput()
                        }
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundColor(.accentColor)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(.systemGray5)
                }
            }
        }
        .frame(height: 170)
        .cornerRadius(10, style: .continuous)
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 10)
        .onDisappear {
            self.isRunning = false
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView { (_) in
            
        } manualInput: {
            
        }

    }
}
