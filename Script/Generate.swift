// Generates Smile's emoji data from Unicode's emoji-test.txt.
//
// Usage, from the repository root:
//
//     swift Script/Generate.swift
//
// To update to a new Emoji version, replace Script/Data/emoji-test.txt with
// https://unicode.org/Public/emoji/latest/emoji-test.txt and run the script again.
//
// Inputs:
// - Script/Data/emoji-test.txt: every RGI emoji, with its group, Emoji version and name.
// - Script/Data/gemoji-aliases.tsv: the `:shortcode:` aliases Smile has always used.
//
// Outputs:
// - Sources/EmojiData.swift: categories, Emoji versions and skin tone variants.
// - Sources/Emoji.swift: `emojiList`, the gemoji aliases plus aliases made from the
//   Unicode names of emoji gemoji doesn't cover.

import Foundation

struct Entry {
  let group: String
  let emoji: String
  let version: String
  let name: String

  var isToned: Bool { emoji.unicodeScalars.contains { skinToneModifiers.contains($0.value) } }
}

let skinToneModifiers: ClosedRange<UInt32> = 0x1F3FB...0x1F3FF

/// Unicode groups in emoji-test.txt order, mapped to `EmojiCategory` cases.
let categoryCases: [(group: String, name: String)] = [
  ("Smileys & Emotion", "smileyAndEmotion"),
  ("People & Body", "peopleAndBody"),
  ("Animals & Nature", "animalsAndNature"),
  ("Food & Drink", "foodAndDrink"),
  ("Travel & Places", "travelAndPlaces"),
  ("Activities", "activities"),
  ("Objects", "objects"),
  ("Symbols", "symbols"),
  ("Flags", "flags"),
]

func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("error: \(message)\n".utf8))
  exit(1)
}

/// Lookup key that ignores variation selectors, so "☺" and "☺️" match.
func key(_ emoji: String) -> String {
  String(String.UnicodeScalarView(emoji.unicodeScalars.filter { $0.value != 0xFE0E && $0.value != 0xFE0F }))
}

func read(_ path: String) -> String {
  guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { fail("Can't read \(path)") }
  return text
}

func write(_ text: String, to path: String) {
  do { try text.write(toFile: path, atomically: true, encoding: .utf8) } catch { fail("Can't write \(path): \(error)") }
}

/// Turns a Unicode name into a gemoji-style alias: "flag: Curaçao" → "flag_curacao".
func alias(fromName name: String) -> String {
  let folded = name
    .replacingOccurrences(of: "’", with: "")
    .replacingOccurrences(of: "&", with: " and ")
    .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
  var cleaned = ""
  for scalar in folded.unicodeScalars {
    let isWordScalar = scalar.isASCII && CharacterSet.alphanumerics.contains(scalar)
    cleaned.append(isWordScalar ? Character(scalar) : " ")
  }
  return cleaned.split(separator: " ").joined(separator: "_")
}

// MARK: - Parse emoji-test.txt

var dataVersion = ""
var group = ""
var entries = [Entry]()

for line in read("Script/Data/emoji-test.txt").split(separator: "\n") {
  if line.hasPrefix("# Version: ") { dataVersion = line.dropFirst(11).trimmingCharacters(in: .whitespaces); continue }
  if line.hasPrefix("# group: ") { group = String(line.dropFirst(9)); continue }
  if line.hasPrefix("#") { continue }

  // 1F600 ; fully-qualified # 😀 E1.0 grinning face
  let fields = line.split(separator: ";", maxSplits: 1)
  guard fields.count == 2, let hash = fields[1].firstIndex(of: "#") else { continue }
  guard fields[1][..<hash].trimmingCharacters(in: .whitespaces) == "fully-qualified" else { continue }

  let scalars = fields[0].split(separator: " ").compactMap { UInt32($0, radix: 16).flatMap(Unicode.Scalar.init) }
  let comment = fields[1][fields[1].index(after: hash)...].trimmingCharacters(in: .whitespaces)
  let tokens = comment.split(separator: " ", maxSplits: 2)
  guard !scalars.isEmpty, tokens.count == 3, tokens[1].hasPrefix("E") else { fail("Can't parse: \(line)") }

  entries.append(Entry(
    group: group,
    emoji: String(String.UnicodeScalarView(scalars)),
    version: String(tokens[1].dropFirst()),
    name: String(tokens[2])
  ))
}

guard !dataVersion.isEmpty, !entries.isEmpty else { fail("emoji-test.txt has no version or entries") }
let knownGroups = Set(categoryCases.map { $0.group } + ["Component"])
if let unknown = entries.first(where: { !knownGroups.contains($0.group) }) {
  fail("Unknown group \"\(unknown.group)\". Add it to EmojiCategory and categoryCases.")
}

/// Untoned emoji shown in categories, in Unicode order.
let bases = entries.filter { !$0.isToned && $0.group != "Component" }
let baseByKey = Dictionary(bases.map { (key($0.emoji), $0.emoji) }, uniquingKeysWith: { first, _ in first })
guard baseByKey.count == bases.count else { fail("Duplicate base emoji") }

// MARK: - Skin tone variants

/// Same-tone variants: every modifier in the sequence is the same tone (🏻, 🏼, 🏽, 🏾 or 🏿).
var variantSlots = [String: [String?]]()
for entry in entries where entry.isToned {
  let tones = Set(entry.emoji.unicodeScalars.map { $0.value }.filter { skinToneModifiers.contains($0) })
  guard tones.count == 1, let tone = tones.first else { continue }
  let untoned = String(String.UnicodeScalarView(entry.emoji.unicodeScalars.filter { !skinToneModifiers.contains($0.value) }))
  guard let base = baseByKey[key(untoned)] else { continue }
  var slots = variantSlots[base] ?? Array(repeating: nil, count: 5)
  let index = Int(tone - skinToneModifiers.lowerBound)
  if let existing = slots[index], existing != entry.emoji { fail("Two variants of \(base) for one tone: \(existing), \(entry.emoji)") }
  slots[index] = entry.emoji
  variantSlots[base] = slots
}
let variantLines: [String] = bases.compactMap { base in
  guard let slots = variantSlots[base.emoji] else { return nil }
  let variants = slots.compactMap { $0 }
  guard variants.count == 5 else { fail("\(base.emoji) is missing skin tone variants") }
  return ([base.emoji] + variants).joined(separator: " ")
}

// MARK: - Versions

var emojisByVersion = [String: [String]]()
for entry in entries { emojisByVersion[entry.version, default: []].append(entry.emoji) }
let versions = emojisByVersion.keys.sorted { Double($0)! < Double($1)! }

// MARK: - Aliases

let fullyQualifiedByKey = Dictionary(entries.map { (key($0.emoji), $0.emoji) }, uniquingKeysWith: { first, _ in first })
var aliases = [(alias: String, emoji: String)]()
for line in read("Script/Data/gemoji-aliases.tsv").split(separator: "\n") where !line.hasPrefix("#") {
  let fields = line.split(separator: "\t")
  guard fields.count == 2 else { fail("Bad alias line: \(line)") }
  let emoji = String(fields[1])
  aliases.append((String(fields[0]), fullyQualifiedByKey[key(emoji)] ?? emoji))
}
let gemojiCount = aliases.count
var usedAliases = Set(aliases.map { $0.alias })
let aliasedKeys = Set(aliases.map { key($0.emoji) })
var skippedAliases = [String]()
for base in bases where !aliasedKeys.contains(key(base.emoji)) {
  let name = alias(fromName: base.name)
  guard !name.isEmpty, !usedAliases.contains(name) else { skippedAliases.append("\(base.emoji) \(name)"); continue }
  usedAliases.insert(name)
  aliases.append((name, base.emoji))
}

// MARK: - Write Sources/EmojiData.swift

func quoted(_ emojis: [String]) -> String { emojis.map { "\"\($0)\"" }.joined(separator: ",") }

var data = """
// Generated by Script/Generate.swift from Unicode's emoji-test.txt. Do not edit.

/// The Emoji version of Smile's bundled Unicode data.
public let emojiDataVersion: Double = \(dataVersion)

/// Every fully-qualified emoji in Unicode order, without skin tone variants or components.
public let emojiCategories: [EmojiCategory: [String]] = [

"""
for category in categoryCases {
  data += "  .\(category.name):\n    [\(quoted(bases.filter { $0.group == category.group }.map { $0.emoji }))],\n"
}
data += """
]

/// Fully-qualified emoji, skin tone variants included, by the Emoji version that added them.
let emojiVersionData: [(version: Double, emojis: String)] = [

"""
for version in versions {
  data += "  (\(version), \"\(emojisByVersion[version]!.joined(separator: " "))\"),\n"
}
data += """
]

/// An emoji followed by its 🏻 🏼 🏽 🏾 🏿 variants, space separated.
let skinToneVariantData: [String] = [

"""
for line in variantLines { data += "  \"\(line)\",\n" }
data += "]\n"
write(data, to: "Sources/EmojiData.swift")

// MARK: - Write Sources/Emoji.swift

var list = """
// Generated by Script/Generate.swift. Do not edit.
// Aliases from Script/Data/gemoji-aliases.tsv, then aliases made from the Unicode names
// (Emoji \(dataVersion)) of emoji gemoji doesn't cover.

public let emojiList: [String: String] = [

"""
for (index, entry) in aliases.enumerated() {
  if index == gemojiCount { list += "  // From Unicode names\n" }
  list += "  \"\(entry.alias)\": \"\(entry.emoji)\",\n"
}
list += "]\n"
write(list, to: "Sources/Emoji.swift")

print("Emoji \(dataVersion): \(bases.count) emoji in \(categoryCases.count) categories, \(entries.count - bases.count) toned or components")
print("Skin tone variants for \(variantLines.count) emoji")
print("Aliases: \(gemojiCount) from gemoji, \(aliases.count - gemojiCount) from Unicode names")
if !skippedAliases.isEmpty { print("Skipped aliases (name taken): \(skippedAliases.joined(separator: ", "))") }
