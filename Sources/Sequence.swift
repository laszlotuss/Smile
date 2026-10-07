//
//  Sequence.swift
//  Smile
//
//  Created by Khoa Pham on 24/02/2017.
//  Copyright © 2017 Fantageek. All rights reserved.
//

import Foundation

public struct Sequence {

  public struct Mark {
    public static let zeroWidthJoiner: String = emoji(unicodeValues: [0x200D])
    public static let presentationSelector: String = emoji(unicodeValues: [0xFE0F])
    public static let enclosingKeyCap: String = emoji(unicodeValues: [0x20E3])
  }

  public struct SkinTone {
    public static let light: String = "🏻"
    public static let mediumLight: String = "🏼"
    public static let medium: String = "🏽"
    public static let mediumDark: String = "🏾"
    public static let dark: String = "🏿"

    public static var all: [String] {
      [SkinTone.light, SkinTone.mediumLight, SkinTone.medium, SkinTone.mediumDark, SkinTone.dark]
    }
  }

  public struct Gender {
    public static let male: String = emoji(unicodeValues: [0x2642])
    public static let female: String = emoji(unicodeValues: [0x2640])
  }

  public struct VariationSelector {
    public static let start: String = emoji(unicodeValues: [0xFE00])
    public static let end: String = emoji(unicodeValues: [0xFE0F])

    public static var all: [String] =
      Array(start.unicodeScalars.first!.value...end.unicodeScalars.first!.value)
      .map({ emoji(unicodeValues: [Int($0)]) })
  }

  public static let all: [String] = [
    Mark.zeroWidthJoiner,
    Mark.presentationSelector,
    Mark.enclosingKeyCap
  ] + SkinTone.all + VariationSelector.all
}

public extension String {
  /// Returns the emoji with the given Fitzpatrick skin-tone modifier appended when this
  /// string is a single modifier-base emoji scalar; returns the receiver unchanged otherwise.
  func applyingSkinTone(_ tone: String) -> String {
    guard !tone.isEmpty,
          unicodeScalars.count == 1,
          unicodeScalars.first?.properties.isEmojiModifierBase == true else { return self }
    return self + tone
  }
}
