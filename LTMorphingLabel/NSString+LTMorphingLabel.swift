//
//  NSString+LTMorphingLabel.swift
//  https://github.com/lexrus/LTMorphingLabel
//
//  The MIT License (MIT)
//  Copyright (c) 2016 Lex Tang, http://lexrus.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files
//  (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation


public enum LTCharacterDiffType: Int, CustomDebugStringConvertible {
    
    case same = 0
    case add = 1
    case delete
    case move
    case moveAndAdd
    case replace
    
    public var debugDescription: String {
        switch self {
        case .same:
            return "Same"
        case .add:
            return "Add"
        case .delete:
            return "Delete"
        case .move:
            return "Move"
        case .moveAndAdd:
            return "MoveAndAdd"
        default:
            return "Replace"
        }
    }
    
}


public struct LTCharacterDiffResult: CustomDebugStringConvertible {
    
    public var diffType: LTCharacterDiffType = .add
    public var moveOffset: Int = 0
    public var skip: Bool = false
    
    public var debugDescription: String {
        switch diffType {
        case .same:
            return "The character is unchanged."
        case .add:
            return "A new character is ADDED."
        case .delete:
            return "The character is DELETED."
        case .move:
            return "The character is MOVED to \(moveOffset)."
        case .moveAndAdd:
            return "The character is MOVED to \(moveOffset) and a new character is ADDED."
        default:
            return "The character is REPLACED with a new character."
        }
    }
    
}


public func >> (lhs: String, rhs: String) -> [LTCharacterDiffResult] {
    
    let newChars = rhs.characters.enumerated()
    let lhsLength = lhs.characters.count
    let rhsLength = rhs.characters.count
    var skipIndexes = [Int]()
    let leftChars = Array(lhs.characters)
    
    let maxLength = max(lhsLength, rhsLength)
    var diffResults = Array(repeating: LTCharacterDiffResult(), count: maxLength)
    
    for i in 0..<maxLength {
        // If new string is longer than the original one
        if i > lhsLength - 1 {
            continue
        }
        
        let leftChar = leftChars[i]
        
        // Search left character in the new string
        var foundCharacterInRhs = false
        for (j, newChar) in newChars {
            if skipIndexes.contains(j) || leftChar != newChar {
                continue
            }

            skipIndexes.append(j)
            foundCharacterInRhs = true
            if i == j {
                // Character not changed
                diffResults[i].diffType = .same
            } else {
                // foundCharacterInRhs and move
                diffResults[i].diffType = .move
                if i <= rhsLength - 1 {
                    // Move to a new index and add a new character to new original place
                    diffResults[i].diffType = .moveAndAdd
                }
                diffResults[i].moveOffset = j - i
            }
            break
        }

        if !foundCharacterInRhs {
            if i < rhs.characters.count - 1 {
                diffResults[i].diffType = .replace
            } else {
                diffResults[i].diffType = .delete
            }
        }
    }
    
    var i = 0
    for result in diffResults {
        switch result.diffType {
        case .move, .moveAndAdd:
            diffResults[i + result.moveOffset].skip = true
        default:
            ()
        }
        i += 1
    }
    
    return diffResults
    
}
