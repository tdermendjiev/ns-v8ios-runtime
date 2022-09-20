//
//  SwiftMetadata.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 17.08.22.
//  Copyright © 2022 Progress. All rights reserved.
//

#include <stdio.h>
#include "SwiftMetadata.h"

namespace tns {

using namespace std;


vector<const SwiftMethodMeta*> SwiftBaseClassMeta::initializers(vector<const SwiftMethodMeta*>& container, KnownUnknownClassPair klasses) const {
    // search in instance methods
//    int16_t firstInitIndex = this->initializersStartIndex;
//    if (firstInitIndex != -1) {
        for (int i = 0; i < instanceMethods->count; i++) {
            const SwiftMethodMeta* method = instanceMethods.value()[i].valuePtr();
            if (!method->isInitializer()) {
                break;
            }

//            if (method->isAvailableInClasses(klasses, /*isStatic*/ false)) {
                container.push_back(method);
//            }
        }
//    }
    return container;
}

}
