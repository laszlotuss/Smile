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

Emoji data is from https://github.com/github/gemoji/blob/master/db/Category-Emoji.json

```swift
Smile.category(emoji: "😁") // people
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

Update emoji list by running

```js
node parser.js
```

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
