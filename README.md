# Smile

❤️ Support my apps ❤️ 

- [Push Hero - pure Swift native macOS application to test push notifications](https://onmyway133.com/pushhero)
- [PastePal - Pasteboard, note and shortcut manager](https://onmyway133.com/pastepal)
- [Quick Check - smart todo manager](https://onmyway133.com/quickcheck)
- [Alias - App and file shortcut manager](https://onmyway133.com/alias)
- [My other apps](https://onmyway133.com/apps/)

❤️❤️😇😍🤘❤️❤️

Emoji in Swift. For reference, go to https://github.com/onmyway133/emoji

[![CI Status](http://img.shields.io/travis/onmyway133/Smile.svg?style=flat)](https://travis-ci.org/onmyway133/Smile)
[![Version](https://img.shields.io/cocoapods/v/Smile.svg?style=flat)](http://cocoadocs.org/docsets/Smile)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Smile.svg?style=flat)](http://cocoadocs.org/docsets/Smile)
[![Platform](https://img.shields.io/cocoapods/p/Smile.svg?style=flat)](http://cocoadocs.org/docsets/Smile)
![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg)

![](Screenshots/Banner.png)

## Features

- [x] Support emoji sequences
- [x] Handle skin tones, marks, genders, variation selectors
- [x] Support new iOS emojis

### List

#### List all emojis

```swift
Smile.list()
emojiList
emojiCategories
```

### Emoji

#### Check if a character is emoji

```swift
Smile.isEmoji(character: "🎉") // true
```

#### Check if a string contains any emoji

```swift
Smile.containsEmoji(string: "🎈 and 🎁") // true
```

#### Count number of emoji characters in a string

```swift
Smile.countEmoji("🎈 and 🎁") // 2
```

#### Count number of non-emoji characters in a string

```swift
Smile.countNonEmoji("🎈 and 🎁") // 5
```

#### Check if a string contains only a single emoji

```swift
Smile.isSingleEmoji("🎈 and 🎁") // false
Smile.isSingleEmoji("👨‍") // true
Smile.isSingleEmoji("👩🏽‍🧑‍") // false
Smile.isSingleEmoji("just plain text") // false
```

#### Check if a string contains only emojis

```swift
Smile.isEmojiOnly("🎈 and 🎁") // false
Smile.isEmojiOnly("👨‍") // true
Smile.isEmojiOnly("👩🏽‍🧑‍") // true
Smile.isEmojiOnly("just plain text") // false
```

#### Get emoji from unicode values

```swift
XCTAssertEqual(Smile.emoji(unicodeValues: [0x1F47B]), "👻")
XCTAssertEqual(Smile.emoji(unicodeValues: [0x0001F468, 0x200D, 0x2708]), "👨‍✈")
```

#### Unmodify an emoji

```swift
Smile.unmodify(emoji: "👨🏿") // 👨
```

### Name

#### Show standard name of an emoji

```swift
Smile.name(emoji: "🇳🇴") // ["REGIONAL INDICATOR SYMBOL LETTER N", "REGIONAL INDICATOR SYMBOL LETTER O"])
```

#### Search emoji by keywords

```swift
Smile.emojis(keywords: ["GRINNING"]) // 😁, 😸
```

### Flag

#### Search emoji flag by country code

```swift
Smile.emoji(countryCode: "no") // 🇳🇴
```

### Alias

#### Search emoji by alias

Emoji data is from https://github.com/github/gemoji/blob/master/db/emoji.json

```swift
Smile.emoji(alias: "japanese_castle") // 🏯
```

#### Find alias by emoji

```swift
Smile.alias(emoji: "🏯") // japanese_castle
```

#### Replace alias within a string

```swift
Smile.replaceAlias(string: ":santa: is coming to :european_castle:") // 🎅 is coming to 🏰
```

### Category

#### Find category of emoji

Categories follow the groups and order of Unicode's [emoji-test.txt](https://unicode.org/Public/emoji/latest/emoji-test.txt).

```swift
Smile.category(emoji: "😁") // .smileyAndEmotion
```

### Version

#### Find the Emoji version that added an emoji

```swift
Smile.version(emoji: "🫩")   // 16.0
Smile.version(emoji: "🙂‍↔️") // 15.1
Smile.version(emoji: "👯🏿")  // 17.0, toned forms can be newer than their base (👯 is 0.6)
Smile.emojiDataVersion       // 18.0, the version of the bundled data
```

#### List the emojis an Emoji version added

```swift
Smile.emojis(version: 16.0) // [🫩, 🫆, 🪾, 🫜, 🪉, 🪏, 🫟, 🇨🇶]
Smile.emojiVersions         // [0.6, 0.7, 1.0, 2.0, 3.0, 4.0, 5.0, 11.0 … 18.0]
```

#### Find the Unicode version an Emoji version is based on

Emoji versions only follow Unicode's from 11.0 on.

```swift
Smile.unicodeVersion(emojiVersion: 3.0)  // 9.0
Smile.unicodeVersion(emojiVersion: 13.1) // 13.0, 13.1 only added sequences
Smile.unicodeVersion(emojiVersion: 16.0) // 16.0
```

#### Newest Emoji version the system emoji font can draw

```swift
Smile.systemEmojiVersion // 16.0 on iOS 18.4 – 26.3, 17.0 from iOS 26.4
Smile.appleEmojiReleases // [("14.2", 13.0) … ("18.4", 16.0), ("26.4", 17.0)], the iOS release of each set
```

### Skin tone

#### Apply or remove a skin tone

Variants come from Unicode's data, so multi-person emoji tone both people and families stay unchanged.

```swift
"👋".applyingSkinTone(Smile.Sequence.SkinTone.dark)       // 👋🏿
"🧑‍🤝‍🧑".applyingSkinTone(Smile.Sequence.SkinTone.dark)   // 🧑🏿‍🤝‍🧑🏿
"👨‍👩‍👧".applyingSkinTone(Smile.Sequence.SkinTone.dark)   // 👨‍👩‍👧, no toned form
"✌🏿".strippingSkinTone()                                  // ✌️
Smile.skinToneVariants(emoji: "👍")                         // [👍🏻, 👍🏼, 👍🏽, 👍🏾, 👍🏿]
```

### Manipulation

#### Extract all emojis within a string

```swift
Smile.extractEmojis(string: "Find 🔑and🔎") // 🔑🔎
```

#### Remove all emojis within a string

```swift
Smile.removeEmojis(string: "Find 🔑and🔎") // Find and
```

#### Assemble

```swift
Smile.assemble(emojis: ["👨", "🏫") // 👨‍🏫
Smile.assemble(emojis: ["👨", "👩", "👧", "👦"] // 👨‍👩‍👧‍👦
```

#### Disassemble

```swift
Smile.disassemble(emoji: "👨‍🏫") // [👨, 🏫]
```

## Script

The emoji data in `Sources/EmojiData.swift` and `Sources/Emoji.swift` is generated. To update to a new Emoji version, replace `Script/Data/emoji-test.txt` with the [latest emoji-test.txt](https://unicode.org/Public/emoji/latest/emoji-test.txt), then run this from the repository root:

```sh
swift Script/Generate.swift
```

Aliases come from `Script/Data/gemoji-aliases.tsv` ([gemoji](https://github.com/github/gemoji)). Emoji without a gemoji alias get one made from their Unicode name, like `face_with_bags_under_eyes`.

## Installation

**Smile** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Smile'
```

**Smile** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "onmyway133/Smile"
```

## Author

Khoa Pham, onmyway133@gmail.com

## Contributing

We would love you to contribute to **Smile**, check the [CONTRIBUTING](https://github.com/onmyway133/Smile/blob/master/CONTRIBUTING.md) file for more info.

## License

**Smile** is available under the MIT license. See the [LICENSE](https://github.com/onmyway133/Smile/blob/master/LICENSE.md) file for more info.

## Apps Using Smile

- [BIGOJI - Send Big Emoji Stickers on iMessage](https://apps.apple.com/app/apple-store/id1610956296?pt=118038397&ct=smile&mt=8)
