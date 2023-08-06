//
//  OnFirstAppearViewModifier.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 8/6/23.
//

import Foundation
import SwiftUI

struct OnFirstAppearViewModier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !didAppear {
                perform?()
                didAppear = true
            }
        }
    }
}

extension View {
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModier(perform: perform))
    }
}
