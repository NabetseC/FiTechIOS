
import Foundation
import SwiftUI

struct StyleSquare: View {
    var title : String
    var description : String
    var backgroundColor : Color
    var size : Double
    
    var body: some View {
            GeometryReader { geometry in
                let cardSize = geometry.size.width * size
                let cardHeight = geometry.size.height * 0.4
                VStack(alignment: .leading, spacing: 10){
                    Text(title).font(.system(size:32)).foregroundColor(.white)
                    Text(description).font(.system(size:64, weight: .bold)).foregroundColor(.white)
                }
                .padding()
                .frame(width: cardSize, height: cardHeight, alignment: .topLeading)
                .background(backgroundColor)
                .cornerRadius(36)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
            }
            .frame(height: UIScreen.main.bounds.width * 0.8)
        }
}
