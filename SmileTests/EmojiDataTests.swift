//
//  EmojiDataTests.swift
//  Smile
//

import XCTest
import Smile

final class EmojiDataTests: XCTestCase {

  func testCategoriesFollowUnicode() {
    let all = EmojiCategory.allCases.flatMap { Smile.emojiCategories[$0] ?? [] }
    XCTAssertEqual(Smile.emojiCategories.count, EmojiCategory.allCases.count)
    XCTAssertEqual(Smile.emojiCategories[.smileyAndEmotion]?.first, "\u{1F600}") // 😀
    XCTAssertEqual(Set(all).count, all.count, "Every emoji belongs to one category once")
    XCTAssertTrue(all.allSatisfy { Smile.version(emoji: $0) != nil })
    XCTAssertFalse(all.contains { $0.unicodeScalars.contains { (0x1F3FB...0x1F3FF).contains($0.value) } },
                   "Categories hold untoned emoji only")
    XCTAssertTrue(all.contains("\u{1F642}\u{200D}\u{2194}\u{FE0F}")) // 🙂‍↔️ 15.1
    XCTAssertTrue(all.contains("\u{1FAE9}")) // 🫩 16.0
    XCTAssertTrue(all.contains("\u{1FAEA}")) // 🫪 17.0
  }

  func testVersion() {
    XCTAssertEqual(Smile.version(emoji: "\u{1F600}"), 1.0) // 😀
    XCTAssertEqual(Smile.version(emoji: "\u{263A}\u{FE0F}"), 0.6) // ☺️
    XCTAssertEqual(Smile.version(emoji: "\u{263A}"), 0.6) // ☺ without a variation selector
    XCTAssertEqual(Smile.version(emoji: "\u{1F642}\u{200D}\u{2194}\u{FE0F}"), 15.1) // 🙂‍↔️
    XCTAssertEqual(Smile.version(emoji: "\u{1F9D1}\u{200D}\u{1F9D1}\u{200D}\u{1F9D2}"), 15.1) // 🧑‍🧑‍🧒
    XCTAssertEqual(Smile.version(emoji: "\u{1FAE9}"), 16.0) // 🫩
    XCTAssertEqual(Smile.version(emoji: "\u{1F46F}"), 0.6) // 👯
    XCTAssertEqual(Smile.version(emoji: "\u{1F46F}\u{1F3FF}"), 17.0) // 👯🏿
    XCTAssertEqual(Smile.version(emoji: "\u{1F469}\u{1F3FF}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1F468}\u{1F3FF}"), 13.1) // 👩🏿‍❤️‍👨🏿
    XCTAssertNil(Smile.version(emoji: "a"))
    XCTAssertNil(Smile.version(emoji: "\u{1F468}\u{1F3FF}\u{200D}\u{1F468}\u{200D}\u{1F466}")) // 👨🏿‍👨‍👦 isn't an emoji
    XCTAssertEqual(Smile.emojiDataVersion, 18.0)
  }

  func testEmojisByVersion() {
    XCTAssertEqual(Smile.emojiVersions.first, 0.6)
    XCTAssertEqual(Smile.emojiVersions.last, Smile.emojiDataVersion)
    XCTAssertEqual(Smile.emojiVersions, Smile.emojiVersions.sorted())
    XCTAssertFalse(Smile.emojiVersions.contains(6.0), "Emoji versions jump from 5.0 to 11.0")

    let emoji16 = Smile.emojis(version: 16.0)
    XCTAssertEqual(emoji16.count, 8)
    XCTAssertEqual(emoji16.first, "\u{1FAE9}") // 🫩, Unicode order
    XCTAssertTrue(Smile.emojis(version: 15.0).contains("\u{1FAF8}\u{1F3FB}")) // 🫸🏻 arrived with 🫸
    XCTAssertTrue(Smile.emojis(version: 17.0).contains("\u{1F46F}\u{1F3FF}")) // 👯🏿, a newer tone on 👯
    XCTAssertEqual(Smile.emojis(version: 15.2), [])

    for version in Smile.emojiVersions {
      XCTAssertTrue(Smile.emojis(version: version).allSatisfy { Smile.version(emoji: $0) == version })
    }
  }

  func testUnicodeVersion() {
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 0.6), 6.0)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 2.0), 8.0)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 3.0), 9.0)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 5.0), 10.0)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 13.1), 13.0)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 15.1), 15.1)
    XCTAssertEqual(Smile.unicodeVersion(emojiVersion: 16.0), 16.0)
    XCTAssertNil(Smile.unicodeVersion(emojiVersion: 9.0), "Emoji 9.0 doesn't exist")

    // No emoji uses a character newer than its Emoji version's Unicode base.
    for version in Smile.emojiVersions {
      guard let unicode = Smile.unicodeVersion(emojiVersion: version) else { return XCTFail("\(version)") }
      for emoji in Smile.emojis(version: version) {
        for scalar in emoji.unicodeScalars {
          guard let age = scalar.properties.age else { continue } // newer than the OS's Unicode data
          XCTAssertLessThanOrEqual(Double(age.major) + Double(age.minor) / 10, unicode, "\(emoji) in Emoji \(version)")
        }
      }
    }
  }

  func testSystemEmojiVersion() {
    XCTAssertGreaterThanOrEqual(Smile.systemEmojiVersion, 12.1)
    XCTAssertLessThanOrEqual(Smile.systemEmojiVersion, Smile.emojiDataVersion)

    let releases = Smile.appleEmojiReleases.map { $0.emojiVersion }
    XCTAssertEqual(releases, releases.sorted())
    XCTAssertTrue(releases.allSatisfy { Smile.emojiVersions.contains($0) })
    XCTAssertTrue(releases.contains(Smile.systemEmojiVersion) || Smile.systemEmojiVersion < releases[0])
  }

  func testSkinToneVariants() {
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F44B}"), Smile.Sequence.SkinTone.all.map { "\u{1F44B}" + $0 }) // 👋
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F44B}\u{1F3FD}"), Smile.skinToneVariants(emoji: "\u{1F44B}"))
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F46F}").last, "\u{1F46F}\u{1F3FF}") // 👯 → 👯🏿
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F9D1}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}").last,
                   "\u{1F9D1}\u{1F3FF}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}\u{1F3FF}") // 🧑‍🤝‍🧑
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F468}\u{200D}\u{1F468}\u{200D}\u{1F466}"), []) // 👨‍👨‍👦
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F9D1}\u{200D}\u{1F9D1}\u{200D}\u{1F9D2}"), []) // 🧑‍🧑‍🧒
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F46A}"), []) // 👪
    XCTAssertEqual(Smile.skinToneVariants(emoji: "\u{1F600}"), []) // 😀
  }

  func testStrippingSkinTone() {
    XCTAssertEqual("\u{1F44B}\u{1F3FF}".strippingSkinTone(), "\u{1F44B}") // 👋🏿
    XCTAssertEqual("\u{270C}\u{1F3FF}".strippingSkinTone(), "\u{270C}\u{FE0F}") // ✌🏿 → ✌️
    XCTAssertEqual("\u{1F3CC}\u{1F3FF}\u{200D}\u{2642}\u{FE0F}".strippingSkinTone(),
                   "\u{1F3CC}\u{FE0F}\u{200D}\u{2642}\u{FE0F}") // 🏌🏿‍♂️ → 🏌️‍♂️
    XCTAssertEqual("\u{1F9D1}\u{1F3FB}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}\u{1F3FC}".strippingSkinTone(),
                   "\u{1F9D1}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}") // 🧑🏻‍🤝‍🧑🏼 → 🧑‍🤝‍🧑
    XCTAssertEqual("\u{1F600}".strippingSkinTone(), "\u{1F600}")
  }

  func testAliasesCoverEveryEmoji() {
    let aliased = Set(Smile.emojiList.values.map { $0.unicodeScalars.filter { $0.value != 0xFE0F }.map { $0.value } })
    let all = EmojiCategory.allCases.flatMap { Smile.emojiCategories[$0] ?? [] }
    let missing = all.filter { !aliased.contains($0.unicodeScalars.filter { $0.value != 0xFE0F }.map { $0.value }) }
    XCTAssertEqual(missing, [])
    XCTAssertEqual(Smile.emoji(alias: "face_with_bags_under_eyes"), "\u{1FAE9}") // 🫩
    XCTAssertEqual(Smile.emoji(alias: "japanese_castle"), "\u{1F3EF}") // 🏯
    XCTAssertTrue(Smile.emojiList.keys.allSatisfy { $0.range(of: "^[a-z0-9_+-]+$", options: .regularExpression) != nil })
  }
}
