//
//  EmojiLookup.swift
//  Smile
//
//  Lookups over the tables generated from Unicode's emoji-test.txt (see Script/Generate.swift).
//

import Foundation

// MARK: - Version

/// The Emoji version (e.g. 15.1) that added `emoji`, from Unicode's emoji-test.txt.
///
/// Skin tone variants report when their toned form arrived: 👯 is 0.6, but 👯🏿 is 17.0.
/// Variation selectors are ignored, so "☺" and "☺️" match. Returns nil for anything that
/// isn't an emoji in the bundled data (see `emojiDataVersion`).
public func version(emoji: String) -> Double? {
  EmojiTables.versionByKey[emoji.smile_lookupKey]
}

/// Every Emoji version in the bundled data, oldest first: 0.6, 0.7, 1.0 … 18.0.
///
/// Emoji versions skip 6.0–10.0: after 5.0 they follow the Unicode version, starting at 11.0.
public var emojiVersions: [Double] {
  emojiVersionData.map { $0.version }
}

/// The emojis that Emoji `version` added, in Unicode order, or an empty array for an unknown version.
///
/// Includes the toned forms that arrived in that version, e.g. 🫸🏻 … 🫸🏿 in 15.0, or 👯🏻 in 17.0.
public func emojis(version: Double) -> [String] {
  EmojiTables.emojisByVersion[version] ?? []
}

/// The iOS release that added each Emoji version to Apple Color Emoji, oldest first.
///
/// Matches `systemEmojiVersion`; update both when a new set ships.
public let appleEmojiReleases: [(iOS: String, emojiVersion: Double)] = [
  ("14.2", 13.0),
  ("14.5", 13.1),
  ("15.4", 14.0),
  ("16.4", 15.0),
  ("17.4", 15.1),
  ("18.4", 16.0),
  ("26.4", 17.0),
]

/// The newest Emoji version the system emoji font (Apple Color Emoji) can draw.
///
/// Apple ships each Emoji version in a point release, not with the major OS release.
/// Update this and `appleEmojiReleases` when a new set ships.
public var systemEmojiVersion: Double {
  if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, *) { return 17.0 }
  if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, *) { return 16.0 }
  if #available(iOS 17.4, macOS 14.4, tvOS 17.4, watchOS 10.4, *) { return 15.1 }
  if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) { return 15.0 }
  if #available(iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.5, *) { return 14.0 }
  if #available(iOS 14.5, macOS 11.3, tvOS 14.5, watchOS 7.4, *) { return 13.1 }
  if #available(iOS 14.2, macOS 11.1, tvOS 14.2, watchOS 7.1, *) { return 13.0 }
  return 12.1
}

// MARK: - Skin tone

/// The 🏻 🏼 🏽 🏾 🏿 variants of `emoji`, or an empty array when it has none.
///
/// Only same-tone variants are listed: both people in 🧑🏿‍🤝‍🧑🏿 or 👩🏿‍❤️‍👨🏿 share the tone.
/// Families (👨‍👩‍👧, 🧑‍🧑‍🧒) have no toned forms. A toned `emoji` returns its siblings.
public func skinToneVariants(emoji: String) -> [String] {
  EmojiTables.skinToneVariantsByKey[emoji.strippingSkinTone().smile_lookupKey] ?? []
}

// MARK: - Tables

/// Lazily built lookups. Swift initializes static stored properties once, thread-safely.
enum EmojiTables {

  /// Keys are emoji without variation selectors.
  static let versionByKey: [String: Double] = {
    var result = [String: Double](minimumCapacity: 4_096)
    for (version, emojis) in emojiVersionData {
      for emoji in emojis.split(separator: " ") {
        result[String(emoji).smile_lookupKey] = version
      }
    }
    return result
  }()

  static let emojisByVersion: [Double: [String]] = {
    var result = [Double: [String]](minimumCapacity: emojiVersionData.count)
    for (version, emojis) in emojiVersionData {
      result[version] = emojis.split(separator: " ").map(String.init)
    }
    return result
  }()

  /// The fully-qualified form of every emoji, keyed without variation selectors.
  static let fullyQualifiedByKey: [String: String] = {
    var result = [String: String](minimumCapacity: 4_096)
    for (_, emojis) in emojiVersionData {
      for emoji in emojis.split(separator: " ") {
        let emoji = String(emoji)
        result[emoji.smile_lookupKey] = emoji
      }
    }
    return result
  }()

  static let skinToneVariantsByKey: [String: [String]] = {
    var result = [String: [String]](minimumCapacity: skinToneVariantData.count)
    for line in skinToneVariantData {
      let emojis = line.split(separator: " ").map(String.init)
      guard let base = emojis.first, emojis.count == 6 else { continue }
      result[base.smile_lookupKey] = Array(emojis.dropFirst())
    }
    return result
  }()
}

extension String {

  /// The string without variation selectors (U+FE0E, U+FE0F), used as a lookup key.
  var smile_lookupKey: String {
    String(String.UnicodeScalarView(unicodeScalars.filter { $0.value != 0xFE0E && $0.value != 0xFE0F }))
  }
}
