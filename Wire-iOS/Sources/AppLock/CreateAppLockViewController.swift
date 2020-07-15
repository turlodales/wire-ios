
// Wire
// Copyright (C) 2020 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

final class CreatePasscodeViewController: AuthenticationStepController {
    convenience init() {
        let description = CreatePasscodeStepDescription()
        
        self.init(description: description)
    }
}

final class CreatePasscodeStepDescription: AuthenticationStepDescription {
    let backButton: BackButtonDescription? = nil
        
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?
    
    init() {
//        backButton = BackButtonDescription()
        
        let passwordField = PasscodeFieldDescription()
        
        mainView = passwordField
        //TODO: text copy
        headline = "Create a Passcode".localized
        subtext = "It will unlock your app to use Wire."
        secondaryView = CreatePassphraseSecondaryView()
    }
    
}

final class CreatePassphraseSecondaryView: AuthenticationSecondaryViewDescription {
    
    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?
    
    init() {
        
        let createPasscodeButton = SolidButtonDescription(title: "Create passcode".localized(uppercased: true), //TODO:
                                                    accessibilityIdentifier: "create_passcode")
        views = [createPasscodeButton]
        
        // disable when init
        createPasscodeButton.button?.isEnabled = false
        
        //TODO:
//        button.valueSubmitted = valueSubmitted
    }
    
}
