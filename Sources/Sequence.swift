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
          let lead = unicodeScalars.first,
          lead.properties.isEmojiModifierBase else { return self }
    let tail = unicodeScalars.dropFirst()
    switch tail.count {
    case 0:
      // Simple single-scalar modifier base — append tone.
      return self + tone
    case 1 where tail.first!.value == 0xFE0F:
      // Modifier base + variation selector (e.g. ✌️ = U+270C U+FE0F).
      // Drop the selector; the Fitzpatrick modifier takes its place.
      return String(lead) + tone
    default:
      // ZWJ sequence (e.g. 🧑‍🦱 = U+1F9D1 ZWJ U+1F9B1).
      // Skip an optional variation selector before the ZWJ, then insert tone.
      let afterLead = tail.first!.value == 0xFE0F ? tail.dropFirst() : tail[...]
      guard afterLead.first?.value == 0x200D else { return self }
      return String(lead) + tone + afterLead.map { String($0) }.joined()
    }
  }

  /// Returns the receiver with a trailing Fitzpatrick skin-tone modifier removed,
  /// or the receiver unchanged if no modifier is present.
  func strippingSkinTone() -> String {
    guard let tone = Sequence.SkinTone.all.first(where: { hasSuffix($0) }) else { return self }
    return String(dropLast(tone.count))
  }
}
