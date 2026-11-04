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
  /// The emoji in the given skin tone (one of `Sequence.SkinTone.all`), from Unicode's
  /// emoji-test.txt; the receiver unchanged when it has no toned form or `tone` isn't one.
  ///
  /// - One person (👋, ✌️, 👩‍⚕️, 🏃‍♀️‍➡️): the tone follows the person.
  /// - Two people (🧑‍🤝‍🧑, 👩‍❤️‍👨, 👩‍❤️‍💋‍👨): both people get the tone.
  /// - Families (👨‍👦, 👨‍👩‍👧, 🧑‍🧑‍🧒) have no toned forms, so they stay unchanged.
  /// - An already toned emoji switches to the new tone (👋🏽 → 👋🏿).
  ///
  /// Some toned forms are newer than their base (👯 is 0.6, 👯🏿 is 17.0), so check
  /// `Smile.version(emoji:)` of the result against what the font can draw.
  func applyingSkinTone(_ tone: String) -> String {
    guard let index = Sequence.SkinTone.all.firstIndex(of: tone) else { return self }
    let variants = Smile.skinToneVariants(emoji: self)
    return variants.isEmpty ? self : variants[index]
  }

  /// The emoji without skin tone modifiers, in its fully-qualified form
  /// (✌🏿 → ✌️, 🧑🏻‍🤝‍🧑🏼 → 🧑‍🤝‍🧑); the receiver unchanged when it has no modifier.
  func strippingSkinTone() -> String {
    let scalars = unicodeScalars.filter { !(0x1F3FB...0x1F3FF).contains($0.value) }
    guard scalars.count != unicodeScalars.count else { return self }
    let untoned = String(String.UnicodeScalarView(scalars))
    return EmojiTables.fullyQualifiedByKey[untoned.smile_lookupKey] ?? untoned
  }
}
