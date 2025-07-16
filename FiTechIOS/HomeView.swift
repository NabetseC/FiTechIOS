//
//  HomeView.swift
//  Swift1
//
//  Created by esteban cubides on 6/25/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {

        ZStack{
            LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
            VStack{
                                    NavigationLink(destination: LessonScreen()){
                        StyleSquare(title: "Lesson 1",
                                    description: "Jab",
                                    backgroundColor: Color(red: 0.267, green: 0.208, blue: 0.384),
                                    size: 0.9)
                    }
                        StyleSquare(title: "Lesson 1",
                            description: "Jab",
                            backgroundColor: Color(red: 0.267, green: 0.208, blue: 0.384),
                            size: 0.9)

                }
            }
        }
    }
}
