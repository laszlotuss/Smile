public enum EmojiCategory: Int, CaseIterable {
  case smileyAndEmotion, peopleAndBody, animalsAndNature, foodAndDrink, travelAndPlaces, activities, objects, symbols, flags
}

extension EmojiCategory: Identifiable {
  public var id: Int {
    rawValue
  }
}

extension EmojiCategory: CustomStringConvertible {
    public var description: String {
        switch self {
        case .smileyAndEmotion: return "Smileys & Emotion"
        case .peopleAndBody: return "People & Body"
        case .animalsAndNature: return "Animals & Nature"
        case .foodAndDrink: return "Food & Drink"
        case .travelAndPlaces: return "Travel & Places"
        case .activities: return "Activities"
        case .objects: return "Objects"
        case .symbols: return "Symbols"
        case .flags: return "Flags"
        }
    }
}

extension EmojiCategory: Comparable {
    public static func < (lhs: EmojiCategory, rhs: EmojiCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
