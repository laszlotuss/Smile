//
//  Tests.swift
//  Smile
//
//  Created by Khoa Pham on 05/06/16.
//  Copyright © 2016 Fantageek. All rights reserved.
//

import XCTest
import Smile

class Tests: XCTestCase {

  func testName() {
    XCTAssertEqual(Smile.name(emoji: "🇳🇴"), ["REGIONAL INDICATOR SYMBOL LETTER N", "REGIONAL INDICATOR SYMBOL LETTER O"])
  }

  func testKeywords() {
    XCTAssertEqual(Smile.emojis(keywords: ["GRINNING"]), ["😁", "😸"])
  }

  func testEmoji() {
    XCTAssertEqual(Smile.emoji(unicodeValues: [0x23F0]), "⏰")
    XCTAssertEqual(Smile.emoji(unicodeValues: [0x2600, 0xFE0F]), "☀️")
    XCTAssertEqual(Smile.emoji(unicodeValues: [0x1F47B]), "👻")
    XCTAssertEqual(Smile.emoji(unicodeValues: [0x1F517]), "🔗")
    XCTAssertEqual(Smile.emoji(unicodeValues: [0x0001F468, 0x200D, 0x2708]), "👨‍✈")
  }

  func testVisibleLength() {
    XCTAssertEqual("👨🏾‍🎓".unicodeScalars.count, 4)
    XCTAssertEqual("👨🏾‍🎓".count, 1)
  }

  func testUnmodify() {
    XCTAssertEqual(Smile.unmodify(emoji: "👨🏿"), "👨")
    XCTAssertEqual(Smile.unmodify(emoji: "👨🏾‍🎓"), "👨")
  }

  func testIsEmoji() {
    XCTAssertEqual(Smile.isEmoji(character: "🎉"), true)
    XCTAssertEqual(Smile.isEmoji(character: "👨‍✈️"), true)
    XCTAssertEqual(Smile.isEmoji(character: "☀️"), true)
    XCTAssertEqual(Smile.isEmoji(character: "a"), false)
    XCTAssertEqual(Smile.isEmoji(character: "1"), false)
  }

  func testContainsEmoji() {
    XCTAssertEqual(Smile.containsEmoji(string: "🎈 and 🎁"), true)
    XCTAssertEqual(Smile.containsEmoji(string: "👨‍✈️"), true)
    XCTAssertEqual(Smile.containsEmoji(string: "☀️"), true)
    XCTAssertEqual(Smile.containsEmoji(string: "just plain text"), false)
    XCTAssertEqual(Smile.containsEmoji(string: "1 2 3"), false)
  }

  func testList() {
    XCTAssertTrue(Smile.list().count > 0)
  }

  func testFlag() {
    XCTAssertEqual(Smile.emoji(countryCode: "no"), "🇳🇴")
  }

  func testCategory() {
    XCTAssertEqual(Smile.category(emoji: "😁"), .smileyAndEmotion)
  }

  func testAlias() {
    XCTAssertEqual(Smile.emoji(alias: "japanese_castle"), "🏯")
    XCTAssertEqual(Smile.alias(emoji: "🏯"), "japanese_castle")
    XCTAssertEqual(Smile.alias(emoji: "👨‍✈️"), "man_pilot")
  }

  func testReplaceAlias() {
    XCTAssertEqual(Smile.replaceAlias(string: ":construction_worker_man: is coming to :european_castle:"), "👷‍♂️ is coming to 🏰")
    XCTAssertEqual(Smile.replaceAlias(string: "Let's sing together: In the :circus_tent:, there are :dog:, :cat: and :super_unicorn:"), "Let's sing together: In the 🎪, there are 🐶, 🐱 and :super_unicorn:")
  }

  func testExtractEmoji() {
    XCTAssertEqual(Smile.extractEmojis(string: "Find 🔑and🔎"), "🔑🔎")
    XCTAssertEqual(Smile.extractEmojis(string: "Find ☀️and⚙️"), "☀️⚙️")
    XCTAssertEqual(Smile.extractEmojis(string: "Find the solos ⌨️ and ⭐️"), "⌨️⭐️")
    XCTAssertEqual(Smile.extractEmojis(string: "Find the 👨‍✈️👨‍🏫💂 and 👨‍💻"), "👨‍✈️👨‍🏫💂👨‍💻")
    XCTAssertEqual(Smile.extractEmojis(string: "⌚️"), "⌚️")
    XCTAssertEqual(Smile.extractEmojis(string: "Hello ⏰⌛️💳 and 🆙."), "⏰⌛️💳🆙")
  }

  func testRemoveEmoji() {
    XCTAssertEqual(Smile.removeEmojis(string: "Find 🔑and🔎"), "Find and")
    XCTAssertEqual(Smile.removeEmojis(string: "Remove the 👨‍🏫"), "Remove the ")
    XCTAssertEqual(Smile.removeEmojis(string: "🥑🦈🛴🤡🦋🥚🦐🦑👰🇬🇧🎅🤑👍🏿☔️☂️☃️☀️❗️💀☠️⚔️⚖️☁️"), "")
    XCTAssertEqual(Smile.removeEmojis(string: "⏰⌛️💳🆙"), "")

    // Variation selectors
    XCTAssertEqual(Smile.removeEmojis(string: "👨‍✈️⚔️"), "")
  }

  func testAssemble() {
    XCTAssertEqual(Smile.assemble(emojis: ["👍", Smile.Sequence.SkinTone.dark]), "👍🏿")
    XCTAssertEqual(Smile.assemble(emojis: ["👨", "🏫"]), "👨‍🏫")
    XCTAssertEqual(Smile.assemble(emojis: ["👨", "✈"]), "👨‍✈️")
    XCTAssertEqual(Smile.assemble(emojis: ["👨", "👩", "👧", "👦"]), "👨‍👩‍👧‍👦")
  }

  func testDisassemble() {
    XCTAssertEqual(Smile.disassemble(emoji: "👍🏿"), ["👍"])
    XCTAssertEqual(Smile.disassemble(emoji: "👨‍🏫"), ["👨", "🏫"])
    XCTAssertEqual(Smile.disassemble(emoji: "👨‍✈"), ["👨"])
  }

  func testApplyingSkinToneToOnePerson() {
    let dark = Smile.Sequence.SkinTone.dark
    XCTAssertEqual("\u{1F44B}".applyingSkinTone(dark), "\u{1F44B}\u{1F3FF}") // 👋
    XCTAssertEqual("\u{270C}\u{FE0F}".applyingSkinTone(dark), "\u{270C}\u{1F3FF}") // ✌️
    XCTAssertEqual("\u{1F469}\u{200D}\u{2695}\u{FE0F}".applyingSkinTone(dark),
                   "\u{1F469}\u{1F3FF}\u{200D}\u{2695}\u{FE0F}") // 👩‍⚕️
    XCTAssertEqual("\u{1F3CC}\u{FE0F}\u{200D}\u{2642}\u{FE0F}".applyingSkinTone(dark),
                   "\u{1F3CC}\u{1F3FF}\u{200D}\u{2642}\u{FE0F}") // 🏌️‍♂️
    XCTAssertEqual("\u{1F3C3}\u{200D}\u{2640}\u{FE0F}\u{200D}\u{27A1}\u{FE0F}".applyingSkinTone(dark),
                   "\u{1F3C3}\u{1F3FF}\u{200D}\u{2640}\u{FE0F}\u{200D}\u{27A1}\u{FE0F}") // 🏃‍♀️‍➡️
    XCTAssertEqual("\u{1F9D1}\u{200D}\u{1F9AF}\u{200D}\u{27A1}\u{FE0F}".applyingSkinTone(dark),
                   "\u{1F9D1}\u{1F3FF}\u{200D}\u{1F9AF}\u{200D}\u{27A1}\u{FE0F}") // 🧑‍🦯‍➡️
    XCTAssertEqual("\u{1F91D}".applyingSkinTone(dark), "\u{1F91D}\u{1F3FF}") // 🤝
    XCTAssertEqual("\u{1F46B}".applyingSkinTone(dark), "\u{1F46B}\u{1F3FF}") // 👫
  }

  func testApplyingSkinToneToTwoPeople() {
    let dark = Smile.Sequence.SkinTone.dark
    XCTAssertEqual("\u{1F9D1}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}".applyingSkinTone(dark),
                   "\u{1F9D1}\u{1F3FF}\u{200D}\u{1F91D}\u{200D}\u{1F9D1}\u{1F3FF}") // 🧑‍🤝‍🧑
    XCTAssertEqual("\u{1F469}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1F468}".applyingSkinTone(dark),
                   "\u{1F469}\u{1F3FF}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1F468}\u{1F3FF}") // 👩‍❤️‍👨
    XCTAssertEqual("\u{1F469}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1F48B}\u{200D}\u{1F468}".applyingSkinTone(dark),
                   "\u{1F469}\u{1F3FF}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1F48B}\u{200D}\u{1F468}\u{1F3FF}") // 👩‍❤️‍💋‍👨
  }

  func testApplyingSkinToneLeavesUntonableEmojis() {
    let dark = Smile.Sequence.SkinTone.dark
    let unchanged = [
      "\u{1F468}\u{200D}\u{1F466}", // 👨‍👦
      "\u{1F468}\u{200D}\u{1F468}\u{200D}\u{1F466}", // 👨‍👨‍👦
      "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{200D}\u{1F466}", // 👨‍👩‍👧‍👦
      "\u{1F9D1}\u{200D}\u{1F9D1}\u{200D}\u{1F9D2}", // 🧑‍🧑‍🧒
      "\u{1F46A}", // 👪
      "\u{1F600}", // 😀
      "\u{1F3F3}\u{FE0F}\u{200D}\u{1F308}", // 🏳️‍🌈
      "\u{1F441}\u{FE0F}\u{200D}\u{1F5E8}\u{FE0F}", // 👁️‍🗨️
      "\u{1F44B}\u{1F3FD}", // 👋🏽, already toned
    ]
    unchanged.forEach { XCTAssertEqual($0.applyingSkinTone(dark), $0) }
    XCTAssertEqual("\u{1F44B}".applyingSkinTone(""), "\u{1F44B}")
    XCTAssertEqual("\u{1F44B}".applyingSkinTone("a"), "\u{1F44B}")
  }

  func testVariationSelectors() {
    // emojis from iOS, macOS, Chrome has different variation selectors
    XCTAssertNotEqual("👨‍✈️", "👨‍✈")
    XCTAssertNotEqual("⚔", "⚔️")
  }
  
  @available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *)
  func testContainsEmojiNew(){
    XCTAssertEqual(Smile.containsEmoji("🎈 and 🎁"), true)
    XCTAssertEqual(Smile.containsEmoji("👨‍✈️"), true)
    XCTAssertEqual(Smile.containsEmoji("☀️"), true)
    XCTAssertEqual(Smile.containsEmoji("just plain text"), false)
    XCTAssertEqual(Smile.containsEmoji("1 2 3"), false)
    XCTAssertEqual(Smile.containsEmoji("*"), false)
  }
  
  @available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *)
  func testCountEmoji(){
    XCTAssertEqual(Smile.countEmoji("🎈 and 🎁"), 2)
    XCTAssertEqual(Smile.countEmoji("👨‍✈️"), 1)
    XCTAssertEqual(Smile.countEmoji("☀️*"), 1)
    XCTAssertEqual(Smile.countEmoji("just plain text"), 0)
    XCTAssertEqual(Smile.countEmoji("1 2 3"), 0)
  }
  
  @available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *)
  func testIsEmojiOnly(){
    XCTAssertEqual(Smile.isEmojiOnly("🎈 and 🎁"), false)
    XCTAssertEqual(Smile.isEmojiOnly("👨‍✈️"), true)
    XCTAssertEqual(Smile.isEmojiOnly("☀️"), true)
    XCTAssertEqual(Smile.isEmojiOnly("☀️*"), false)
    XCTAssertEqual(Smile.isEmojiOnly("👩🏽‍🎓🧑‍💻"), true)
    XCTAssertEqual(Smile.isEmojiOnly("just plain text"), false)
    XCTAssertEqual(Smile.isEmojiOnly("1 2 3"), false)
    XCTAssertEqual(Smile.isEmojiOnly("*"), false)
  }
  
  @available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *)
  func testIsSingleEmoji(){
    XCTAssertEqual(Smile.isSingleEmoji("🎈 and 🎁"), false)
    XCTAssertEqual(Smile.isSingleEmoji("👨‍✈️"), true)
    XCTAssertEqual(Smile.isSingleEmoji("☀️"), true)
    XCTAssertEqual(Smile.isSingleEmoji("☀️*"), false)
    XCTAssertEqual(Smile.isSingleEmoji("👩🏽‍🎓🧑‍💻"), false)
    XCTAssertEqual(Smile.isSingleEmoji("just plain text"), false)
    XCTAssertEqual(Smile.isSingleEmoji("1 2 3"), false)
    XCTAssertEqual(Smile.isSingleEmoji("*"), false)
  }
  
  @available(macOS 10.12.2, iOS 10.2, tvOS 10.1, watchOS 3.1.1, *)
  func testCountNonEmoji(){
    XCTAssertEqual(Smile.countNonEmoji("🎈 and 🎁"), 5)
    XCTAssertEqual(Smile.countNonEmoji("👨‍✈️"), 0)
    XCTAssertEqual(Smile.countNonEmoji("☀️"), 0)
    XCTAssertEqual(Smile.countNonEmoji("☀️*"), 1)
    XCTAssertEqual(Smile.countNonEmoji("👩🏽‍🎓🧑‍💻"), 0)
    XCTAssertEqual(Smile.countNonEmoji("just plain text"), 15)
    XCTAssertEqual(Smile.countNonEmoji("1 2 3"), 5)
    XCTAssertEqual(Smile.countNonEmoji("*"), 1)
  }
  
  
}
