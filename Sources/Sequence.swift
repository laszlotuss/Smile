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
  /// Returns the emoji with the given Fitzpatrick skin-tone modifier applied the way the RGI
  /// emoji sets define toned sequences; returns the receiver unchanged when it has no toned form.
  ///
  /// - One person (👋, ✌️, 👩‍⚕️, 🏃‍♀️‍➡️): the tone follows the lead person.
  /// - Two people joined by a connector (🧑‍🤝‍🧑, 👩‍❤️‍👨, 👩‍❤️‍💋‍👨): both people get the tone.
  /// - Families (👨‍👦, 👨‍👩‍👧, 🧑‍🧑‍🧒) have no toned forms. Toning only some members
  ///   breaks the sequence into separate glyphs, so they are returned unchanged.
  func applyingSkinTone(_ tone: String) -> String {
    guard let toneScalar = tone.unicodeScalars.first,
          tone.unicodeScalars.count == 1,
          toneScalar.properties.isEmojiModifier,
          !unicodeScalars.contains(where: { $0.properties.isEmojiModifier }) else { return self }

    let joiner: Unicode.Scalar = "\u{200D}"
    let components = unicodeScalars.split(separator: joiner, omittingEmptySubsequences: false)
    // 🤝 is a modifier base on its own, but stays untoned between two people (🧑🏿‍🤝‍🧑🏿).
    // 👪 is a modifier base in newer Unicode data, but has no toned RGI form.
    let people = components.indices.filter { index in
      guard let base = components[index].first,
            base.properties.isEmojiModifierBase,
            base.value != 0x1F46A else { return false }
      return components.count == 1 || base.value != 0x1F91D
    }
    guard people.first == 0,
          people.count == 1 || (people.count == 2 && components.count > 2) else { return self }

    var toned = String.UnicodeScalarView()
    for (index, component) in components.enumerated() {
      if index > 0 { toned.append(joiner) }
      guard people.contains(index), let base = component.first else {
        toned.append(contentsOf: component)
        continue
      }
      // The modifier replaces the emoji presentation selector (✌️ → ✌🏿, 🏌️‍♂️ → 🏌🏿‍♂️).
      toned.append(base)
      toned.append(toneScalar)
      toned.append(contentsOf: component.dropFirst().filter { $0.value != 0xFE0F })
    }
    return String(toned)
  }

  /// Returns the receiver with a trailing Fitzpatrick skin-tone modifier removed,
  /// or the receiver unchanged if no modifier is present.
  func strippingSkinTone() -> String {
    guard let tone = Sequence.SkinTone.all.first(where: { hasSuffix($0) }) else { return self }
    return String(dropLast(tone.count))
  }
}
