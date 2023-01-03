//
//  ContentMessageView.swift
//  Discussion_Poc
//
//  Created by Loïc MAZUC on 20/09/2022.
//

import SwiftUI

struct ContentMessageView: View {
    var message: Message
    
    var body: some View {
        VStack {
            Text(message.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
            HStack {
                if message.fromMe {
                    Spacer()
                }
                VStack(alignment: message.fromMe ? .trailing : .leading) {
                    Text(message.text)
                        .padding(10)
                        .foregroundColor(message.fromMe ? Color.white : Color.black)
                        .background(message.fromMe ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                    .cornerRadius(10)
                    HStack {
                        ForEach(0..<message.attachements) { _ in
                            Image(systemName: "leaf.circle.fill")
                                .foregroundColor(.purple)
                                .font(.system(size: CGFloat.random(in: 20...35)))
                        }
                    }
                }
                
                if !message.fromMe {
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
}
