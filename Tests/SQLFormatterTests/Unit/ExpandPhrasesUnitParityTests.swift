import Foundation
import Testing

private enum PhraseNode {
  case text(String)
  case concatenation([PhraseNode])
  case mandatory([PhraseNode])
  case optional([PhraseNode])
}

private enum ExpandPhraseError: LocalizedError {
  case unbalancedParenthesis(text: String)
  case unexpectedCharacter(char: Character, text: String)

  var errorDescription: String? {
    switch self {
    case .unbalancedParenthesis(let text):
      return "Unbalanced parenthesis in: \(text)"
    case .unexpectedCharacter(let char, let text):
      return "Unexpected \(char) in: \(text)"
    }
  }
}

private func expandSinglePhrase(_ phrase: String) throws -> [String] {
  let characters = Array(phrase)
  let node = try parsePhrase(text: phrase, characters: characters)
  return buildCombinations(node).map(stripExtraWhitespace)
}

private func parsePhrase(text: String, characters: [Character]) throws -> PhraseNode {
  let (items, _) = try parseAlteration(
    text: text, characters: characters, index: 0, expectClosing: nil)
  return .mandatory(items)
}

private func parseAlteration(
  text: String,
  characters: [Character],
  index: Int,
  expectClosing: Character?
) throws -> ([PhraseNode], Int) {
  var alterations: [PhraseNode] = []
  var currentIndex = index

  while currentIndex < characters.count {
    let (term, newIndex) = try parseConcatenation(
      text: text,
      characters: characters,
      index: currentIndex
    )
    alterations.append(term)
    currentIndex = newIndex

    if currentIndex >= characters.count {
      if expectClosing != nil {
        throw ExpandPhraseError.unbalancedParenthesis(text: text)
      }
      return (alterations, currentIndex)
    }

    let nextChar = characters[currentIndex]
    if nextChar == "|" {
      currentIndex += 1
      continue
    }
    if nextChar == "}" || nextChar == "]" {
      if expectClosing != nextChar {
        throw ExpandPhraseError.unbalancedParenthesis(text: text)
      }
      currentIndex += 1
      return (alterations, currentIndex)
    }
    if expectClosing == nil {
      throw ExpandPhraseError.unexpectedCharacter(char: nextChar, text: text)
    }
    throw ExpandPhraseError.unbalancedParenthesis(text: text)
  }

  if expectClosing != nil {
    throw ExpandPhraseError.unbalancedParenthesis(text: text)
  }

  return (alterations, currentIndex)
}

private func parseConcatenation(
  text: String,
  characters: [Character],
  index: Int
) throws -> (PhraseNode, Int) {
  var items: [PhraseNode] = []
  var currentIndex = index

  while true {
    let (term, newIndex) = try parseTerm(
      text: text,
      characters: characters,
      index: currentIndex
    )
    guard let term else {
      break
    }
    items.append(term)
    currentIndex = newIndex
  }

  if items.count == 1 {
    return (items[0], currentIndex)
  }

  return (.concatenation(items), currentIndex)
}

private func parseTerm(
  text: String,
  characters: [Character],
  index: Int
) throws -> (PhraseNode?, Int) {
  guard index < characters.count else {
    return (nil, index)
  }

  let char = characters[index]
  switch char {
  case "{":
    return try parseMandatoryBlock(text: text, characters: characters, index: index + 1)
  case "[":
    return try parseOptionalBlock(text: text, characters: characters, index: index + 1)
  case "|", "]", "}":
    return (nil, index)
  default:
    var currentIndex = index
    var word = ""
    while currentIndex < characters.count {
      let currentChar = characters[currentIndex]
      guard isWordCharacter(currentChar) else {
        break
      }
      word.append(currentChar)
      currentIndex += 1
    }
    guard !word.isEmpty else {
      return (nil, index)
    }
    return (.text(word), currentIndex)
  }
}

private func parseMandatoryBlock(
  text: String,
  characters: [Character],
  index: Int
) throws -> (PhraseNode, Int) {
  let (items, newIndex) = try parseAlteration(
    text: text,
    characters: characters,
    index: index,
    expectClosing: "}"
  )
  return (.mandatory(items), newIndex)
}

private func parseOptionalBlock(
  text: String,
  characters: [Character],
  index: Int
) throws -> (PhraseNode, Int) {
  let (items, newIndex) = try parseAlteration(
    text: text,
    characters: characters,
    index: index,
    expectClosing: "]"
  )
  return (.optional(items), newIndex)
}

private func isWordCharacter(_ character: Character) -> Bool {
  character == " " || character == "_" || character.isLetter || character.isNumber
}

private func buildCombinations(_ node: PhraseNode) -> [String] {
  switch node {
  case .text(let text):
    return [text]
  case .concatenation(let items):
    let nested = items.map(buildCombinations)
    return nested.reduce([""], stringCombinations)
  case .mandatory(let items):
    return items.flatMap(buildCombinations)
  case .optional(let items):
    return [""] + items.flatMap(buildCombinations)
  }
}

private func stringCombinations(_ xs: [String], _ ys: [String]) -> [String] {
  var results: [String] = []
  results.reserveCapacity(xs.count * ys.count)
  for x in xs {
    for y in ys {
      results.append(x + y)
    }
  }
  return results
}

private func stripExtraWhitespace(_ text: String) -> String {
  var value = ""
  var previousWasSpace = false
  for character in text {
    if character == " " {
      if previousWasSpace {
        continue
      }
      previousWasSpace = true
      value.append(" ")
    } else {
      previousWasSpace = false
      value.append(character)
    }
  }
  return value.trimmingCharacters(in: .whitespacesAndNewlines)
}

// Upstream: test/unit/expandPhrases.test.ts :: returns single item when no [optional blocks] found
@Test func parity_expandPhrases_returnsSingleItemWhenNoOptionalBlocks() throws {
  let result = try expandSinglePhrase("INSERT INTO")
  #expect(result == ["INSERT INTO"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands expression with one [optional block] at the end
@Test func parity_expandPhrases_handlesOptionalBlockAtEnd() throws {
  let result = try expandSinglePhrase("DROP TABLE [IF EXISTS]")
  #expect(result == ["DROP TABLE", "DROP TABLE IF EXISTS"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands expression with one [optional block] at the middle
@Test func parity_expandPhrases_handlesOptionalBlockInMiddle() throws {
  let result = try expandSinglePhrase("CREATE [TEMPORARY] TABLE")
  #expect(result == ["CREATE TABLE", "CREATE TEMPORARY TABLE"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands expression with one [optional block] at the start
@Test func parity_expandPhrases_handlesOptionalBlockAtStart() throws {
  let result = try expandSinglePhrase("[EXPLAIN] SELECT")
  #expect(result == ["SELECT", "EXPLAIN SELECT"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands multiple [optional] [blocks]
@Test func parity_expandPhrases_handlesMultipleOptionalBlocks() throws {
  let result = try expandSinglePhrase("CREATE [OR REPLACE] [MATERIALIZED] VIEW")
  #expect(
    result == [
      "CREATE VIEW",
      "CREATE MATERIALIZED VIEW",
      "CREATE OR REPLACE VIEW",
      "CREATE OR REPLACE MATERIALIZED VIEW",
    ])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands expression with optional [multi|choice|block]
@Test func parity_expandPhrases_handlesOptionalMultiChoiceBlock() throws {
  let result = try expandSinglePhrase("CREATE [TEMP|TEMPORARY|VIRTUAL] TABLE")
  #expect(
    result == [
      "CREATE TABLE",
      "CREATE TEMP TABLE",
      "CREATE TEMPORARY TABLE",
      "CREATE VIRTUAL TABLE",
    ])
}

// Upstream: test/unit/expandPhrases.test.ts :: removes braces around {mandatory} {block}
@Test func parity_expandPhrases_handlesMandatoryBlockWithoutChoices() throws {
  let result = try expandSinglePhrase("CREATE {TEMP} {TABLE}")
  #expect(result == ["CREATE TEMP TABLE"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands expression with mandatory {multi|choice|block}
@Test func parity_expandPhrases_handlesMandatoryMultiChoiceBlock() throws {
  let result = try expandSinglePhrase("CREATE {TEMP|TEMPORARY|VIRTUAL} TABLE")
  #expect(
    result == [
      "CREATE TEMP TABLE",
      "CREATE TEMPORARY TABLE",
      "CREATE VIRTUAL TABLE",
    ])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands nested []-block inside []-block
@Test func parity_expandPhrases_handlesNestedOptionalBlocks() throws {
  let result = try expandSinglePhrase("CREATE [[OR] REPLACE] TABLE")
  #expect(
    result == [
      "CREATE TABLE",
      "CREATE REPLACE TABLE",
      "CREATE OR REPLACE TABLE",
    ])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands nested {}-block inside {}-block
@Test func parity_expandPhrases_handlesNestedMandatoryBlocks() throws {
  let result = try expandSinglePhrase("CREATE {{OR} REPLACE} TABLE")
  #expect(result == ["CREATE OR REPLACE TABLE"])
}

// Upstream: test/unit/expandPhrases.test.ts :: expands nested {}-block inside []-block
@Test func parity_expandPhrases_handlesOptionalBlockWrappingMandatoryBlock() throws {
  let result = try expandSinglePhrase("FOR RS [USE AND KEEP {UPDATE | EXCLUSIVE} LOCKS]")
  #expect(
    result == [
      "FOR RS",
      "FOR RS USE AND KEEP UPDATE LOCKS",
      "FOR RS USE AND KEEP EXCLUSIVE LOCKS",
    ])
}

// Upstream: test/unit/expandPhrases.test.ts :: throws error when encountering unbalanced ][-braces
@Test func parity_expandPhrases_errorsOnUnbalancedSquareBraces() {
  for phrase in ["CREATE [TABLE", "CREATE TABLE]"] {
    do {
      _ = try expandSinglePhrase(phrase)
      Issue.record("Expected error for \(phrase)")
    } catch let error as ExpandPhraseError {
      #expect(error.localizedDescription == "Unbalanced parenthesis in: \(phrase)")
    } catch {
      Issue.record("Unexpected error \(error)")
    }
  }
}

// Upstream: test/unit/expandPhrases.test.ts :: throws error when encountering unbalanced }{-braces
@Test func parity_expandPhrases_errorsOnUnbalancedCurlyBraces() {
  for phrase in ["CREATE {TABLE", "CREATE TABLE}"] {
    do {
      _ = try expandSinglePhrase(phrase)
      Issue.record("Expected error for \(phrase)")
    } catch let error as ExpandPhraseError {
      #expect(error.localizedDescription == "Unbalanced parenthesis in: \(phrase)")
    } catch {
      Issue.record("Unexpected error \(error)")
    }
  }
}
