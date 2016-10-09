//
//  FileCheck.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 10/6/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import Foundation
#if os(Linux)
  import Glibc

  typealias NSRegularExpression = RegularExpression
#else
  import Darwin
#endif

/// `FileCheckOptions` enumerates a set of options that can modify the behavior
/// of the file check verification process.
public struct FileCheckOptions : OptionSet {
	/// Retrieves the raw value of this option set.
	public let rawValue : UInt64

	/// Convert from a value of `RawValue`, succeeding unconditionally.
	public init(rawValue : UInt64) {
		self.rawValue = rawValue
	}

	/// Do not treat all horizontal whitespace as equivalent.
	public static let strictWhitespace = FileCheckOptions(rawValue: 1 << 0)
	/// Add an implicit negative check with this pattern to every positive
	/// check. This can be used to ensure that no instances of this pattern
	/// occur which are not matched by a positive pattern.
	public static let implicitCheckNot = FileCheckOptions(rawValue: 1 << 1)
	/// Allow the input file to be empty. This is useful when making checks that
	/// some error message does not occur, for example.
	public static let allowEmptyInput = FileCheckOptions(rawValue: 1 << 2)
	/// Require all positive matches to cover an entire input line.  Allows
	/// leading and trailing whitespace if `.strictWhitespace` is not also
	/// passed.
	public static let matchFullLines = FileCheckOptions(rawValue: 1 << 3)
}

/// `FileCheckFD` represents the standard output streams `FileCheck` is capable
/// of overriding to gather output.
public enum FileCheckFD {
	/// Standard output.
	case stdout
	/// Standard error.
	case stderr
	/// A custom output stream.
	case custom(fileno: Int32, ptr: UnsafeMutablePointer<FILE>)

	/// Retrieve the file descriptor for this output stream.
	var fileno : Int32 {
		switch self {
		case .stdout:
			return STDOUT_FILENO
		case .stderr:
			return STDERR_FILENO
		case let .custom(fileno: fd, ptr: _):
			return fd
		}
	}

	/// Retrieve the FILE pointer for this stream.
	var filePtr : UnsafeMutablePointer<FILE>! {
		switch self {
		case .stdout:
		#if os(Linux)
			return Glibc.stdout
		#else
			return Darwin.stdout
		#endif
		case .stderr:
		#if os(Linux)
			return Glibc.stderr
		#else
			return Darwin.stderr
		#endif
		case let .custom(fileno: _, ptr: ptr):
			return ptr
		}
	}
}

/// Reads from the given output stream and runs a file verification procedure
/// by comparing the output to a specified result.
///
/// FileCheck requires total access to whatever input stream is being used.  As
/// such it will override printing to said stream until the given block has 
/// finished executing.
///
/// - parameter FD: The file descriptor to override and read from.
/// - parameter prefixes: Specifies one or more prefixes to match. By default
///   these patterns are prefixed with "CHECK:".
/// - parameter file: The file to check against.  Defaults to the file that
///   containing the call to `fileCheckOutput`.
/// - parameter options: Optional arguments to modify the behavior of the check.
/// - parameter blocK: The block in which output will be emitted to the given
///   file descriptor.
public func fileCheckOutput(of FD : FileCheckFD = .stdout, withPrefixes prefixes : [String] = ["CHECK"], against file : String = #file, options: FileCheckOptions = [], block : () -> ()) -> Bool {
	guard let validPrefixes = validateCheckPrefixes(prefixes) else {
		print("Supplied check-prefix is invalid! Prefixes must be unique and ",
		      "start with a letter and contain only alphanumeric characters, ",
		      "hyphens and underscores")
		return false
	}
	guard let PrefixRE = try? NSRegularExpression(pattern: validPrefixes.joined(separator: "|"), options: []) else {
		print("Unable to combine check-prefix strings into a prefix regular ",
		      "expression! This is likely a bug in FileCheck's verification of ",
		      "the check-prefix strings. Regular expression parsing failed.")
		return false
	}

	let input = overrideFDAndCollectOutput(file: FD, of: block)
	if (input.isEmpty && !options.contains(.allowEmptyInput)) {
		print("FileCheck error: input from file descriptor \(FD) is empty.\n")
		return false
	}

	guard let contents = try? String(contentsOfFile: file, encoding: .utf8) else {
		return false
	}
	let buf = contents.cString(using: .utf8)?.withUnsafeBufferPointer { buffer in
		return readCheckStrings(in: buffer, withPrefixes: validPrefixes, options: options, PrefixRE)
	}
	guard let checkStrings = buf else {
		return false
	}
	return check(input: input, against: checkStrings)
}

private func overrideFDAndCollectOutput(file : FileCheckFD, of block : () -> ()) -> String {
  fflush(stdout)
  let oldFd = dup(file.fileno)

  let template = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.XXXXXX")
  return template.withUnsafeFileSystemRepresentation { buffer in
    guard let buffer = buffer else {
      return ""
    }

   	let newFd = mkstemp(UnsafeMutablePointer(mutating: buffer))
    guard newFd != -1 else {
      return ""
    }

    dup2(newFd, file.fileno)

    block()

    close(newFd)
    fflush(file.filePtr)


    dup2(oldFd, file.fileno)
    close(oldFd)

    let url = URL(fileURLWithFileSystemRepresentation: buffer, isDirectory: false, relativeTo: nil)
    guard let s = try? String(contentsOf: url) else {
      return ""
    }
    return s
  }
}

func validateCheckPrefixes(_ prefixes : [String]) -> [String]? {
	let validator = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_-]*$", options: [])

	for prefix in prefixes {
		// Reject empty prefixes.
		if prefix.isEmpty {
			return nil
		}

		let range = NSRange(
			location: 0,
			length: prefix.distance(from: prefix.startIndex, to: prefix.endIndex)
		)
		if validator.matches(in: prefix, options: [], range: range).isEmpty {
			return nil
		}
	}

	return [String](Set<String>(prefixes))
}

extension CChar {
	fileprivate var isPartOfWord : Bool {
		return isalnum(Int32(self)) != 0 || UInt8(self) == "-".utf8.first! || UInt8(self) == "_".utf8.first!
	}
}

private func findCheckType(in buf : UnsafeBufferPointer<CChar>, with prefix : String) -> CheckType {
	let nextChar = UInt8(buf[prefix.utf8.count])

	// Verify that the : is present after the prefix.
	if nextChar == ":".utf8.first! {
		return .plain
	}
	if nextChar != "-".utf8.first! {
		return .none
	}

	let rest = String(
		bytesNoCopy: UnsafeMutableRawPointer(
			mutating: buf.baseAddress!.advanced(by: prefix.utf8.count + 1)
		),
		length: buf.count - (prefix.utf8.count + 1),
		encoding: .utf8,
		freeWhenDone: false
	)!
	if rest.hasPrefix("NEXT:") {
		return .next
	}

	if rest.hasPrefix("SAME:") {
		return .same
	}

	if rest.hasPrefix("NOT:") {
		return .not
	}

	if rest.hasPrefix("DAG:") {
		return .dag
	}

	if rest.hasPrefix("LABEL:") {
		return .label
	}

	// You can't combine -NOT with another suffix.
	let badNotPrefixes = [
		"DAG-NOT:",
		"NOT-DAG:",
		"NEXT-NOT:",
		"NOT-NEXT:",
		"SAME-NOT:",
		"NOT-SAME:",
	]
	if badNotPrefixes.reduce(false, { (acc, s) in acc || rest.hasPrefix(s) }) {
		return .badNot
	}

	return .none
}

extension UnsafeBufferPointer {
	fileprivate func substr(_ Start : Int, _ Size : Int) -> UnsafeBufferPointer<Element> {
		return UnsafeBufferPointer<Element>(start: self.baseAddress!.advanced(by: Start), count: Size)
	}

	fileprivate func dropFront(_ n : Int) -> UnsafeBufferPointer<Element> {
		precondition(n < self.count)
		return UnsafeBufferPointer<Element>(start: self.baseAddress!.advanced(by: n), count: self.count - n)
	}
}

func substring(in buffer : UnsafeBufferPointer<CChar>, with range : NSRange) -> String {
	precondition(range.location + range.length <= buffer.count)
	let ptr = buffer.substr(range.location, range.length)
	return String(bytesNoCopy: UnsafeMutableRawPointer(mutating: ptr.baseAddress!), length: range.length, encoding: .utf8, freeWhenDone: false)!
}

private func findFirstMatch(in inbuffer : UnsafeBufferPointer<CChar>, among prefixes : [String], with RE : NSRegularExpression, startingAt startLine: Int) -> (String, CheckType, Int, UnsafeBufferPointer<CChar>) {
	var lineNumber = startLine
	var buffer = inbuffer

	while !buffer.isEmpty {
		let str = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress!), length: buffer.count, encoding: .utf8, freeWhenDone: false)!
		let matches = RE.matches(in: str, options: [], range: NSRange(location: 0, length: buffer.count))
		guard let prefix = matches.first else {
			return ("", .none, lineNumber, buffer)
		}
		let skippedPrefix = buffer.substr(0, prefix.range.location)
		let prefixStr = substring(in: buffer, with: prefix.range)

		buffer = buffer.dropFront(prefix.range.location)
		lineNumber += skippedPrefix.filter({ c in UInt8(c) == "\n".utf8.first! }).count
		// Check that the matched prefix isn't a suffix of some other check-like
		// word.
		// FIXME: This is a very ad-hoc check. it would be better handled in some
		// other way. Among other things it seems hard to distinguish between
		// intentional and unintentional uses of this feature.
		if skippedPrefix.isEmpty || !skippedPrefix.last!.isPartOfWord {
			// Now extract the type.
			let CheckTy = findCheckType(in: buffer, with: prefixStr)


			// If we've found a valid check type for this prefix, we're done.
			if CheckTy != .none {
				return (prefixStr, CheckTy, lineNumber, buffer)
			}
		}
		// If we didn't successfully find a prefix, we need to skip this invalid
		// prefix and continue scanning. We directly skip the prefix that was
		// matched and any additional parts of that check-like word.
		// From the given position, find the next character after the word.
		var loc = prefix.range.length
		while loc < buffer.count && buffer[loc].isPartOfWord {
			loc += 1
		}
		buffer = buffer.dropFront(loc)
	}

	return ("", .none, lineNumber, buffer)
}


private func readCheckStrings(in buf : UnsafeBufferPointer<CChar>, withPrefixes prefixes : [String], options: FileCheckOptions, _ RE : NSRegularExpression) -> [CheckString] {
	// Keeps track of the line on which CheckPrefix instances are found.
	var lineNumber = 1

	//  std::vector<Pattern> DagNotMatches = ImplicitNegativeChecks
	var dagNotMatches = [Pattern]()
	var contents = [CheckString]()

	var buffer = buf
	while true {
		// See if a prefix occurs in the memory buffer.
		let (usedPrefix, checkTy, ln, newBuffer) = findFirstMatch(in: buffer, among: prefixes, with: RE, startingAt: lineNumber)
		if usedPrefix.isEmpty {
			break
		}
		lineNumber = ln

		// Skip the buffer to the end.
		buffer = newBuffer.dropFront(usedPrefix.utf8.count + checkTy.size)

		// Complain about useful-looking but unsupported suffixes.
		if checkTy == .badNot {
			diagnose(.error, "unsupported -NOT combo on prefix '\(usedPrefix)'")
			return []
		}

		// Okay, we found the prefix, yay. Remember the rest of the line, but 
		// ignore leading whitespace.
		if !options.contains(.strictWhitespace) || !options.contains(.matchFullLines) {
			guard let idx = buffer.index(where: { c in UInt8(c) != " ".utf8.first! && UInt8(c) != "\t".utf8.first! }) else {
				return []
			}
			buffer = buffer.dropFront(idx)
		}

		// Scan ahead to the end of line.
		let EOL : Int = buffer.index(of: CChar("\n".utf8.first!)) ?? buffer.index(of: CChar("\r".utf8.first!))!

		// Remember the location of the start of the pattern, for diagnostics.
		let PatternLoc : SMLoc = SMLoc(fromPointer: buffer.baseAddress!)

		// Parse the pattern.
		let pat : Pattern = Pattern(checking: checkTy)
		let subBuffer = UnsafeBufferPointer<CChar>(start: buffer.baseAddress, count: EOL)
		if pat.parse(pattern: subBuffer, withPrefix: usedPrefix, at: lineNumber, options: options) {
			return []
		}

		// Verify that CHECK-LABEL lines do not define or use variables
		if (checkTy == .label) && pat.hasVariable {
			diagnose(.error, "found '\(usedPrefix)-LABEL:' with variable definition or use")
			return []
		}

		buffer = UnsafeBufferPointer<CChar>(
			start: buffer.baseAddress!.advanced(by: EOL),
			count: buffer.count - EOL
		)

		// Verify that CHECK-NEXT lines have at least one CHECK line before them.
		if (checkTy == .next || checkTy == .same) && contents.isEmpty {
			let type = (checkTy == .next) ? "NEXT" : "SAME"
			diagnose(.error, "found '\(usedPrefix)-\(type)' without previous '\(usedPrefix): line")
			return []
		}

		// Handle CHECK-DAG/-NOT.
		if checkTy == .dag || checkTy == .not {
			dagNotMatches.append(pat)
			continue
		}

		// Okay, add the string we captured to the output vector and move on.
		contents.append(CheckString(pattern: pat, prefix: usedPrefix, loc: PatternLoc))
//		std::swap(DagNotMatches, CheckStrings.back().DagNotStrings)
//		DagNotMatches = ImplicitNegativeChecks
	}

	// Add an EOF pattern for any trailing CHECK-DAG/-NOTs, and use the first
	// prefix as a filler for the error message.
//	if !DagNotMatches.isEmpty {
//		CheckStrings.emplace_back(Pattern(Check::CheckEOF), *CheckPrefixes.begin(),
//		                          SMLoc::getFromPointer(Buffer.data()))
//		std::swap(DagNotMatches, CheckStrings.back().DagNotStrings)
//	}

	if contents.isEmpty {
		print("error: no check strings found with prefix\(contents.count > 1 ? "es " : " ")")
		for prefix in prefixes {
			print("\(prefix):")
		}
		return []
	}

	return contents
}

/// Check the input to FileCheck provided in the \p Buffer against the \p
/// CheckStrings read from the check file.
///
/// Returns false if the input fails to satisfy the checks.
private func check(input b : String, against checkStrings : [CheckString]) -> Bool {
	var buffer = b
	var failedChecks = false

	// This holds all the current filecheck variables.
	var variableTable = [String:String]()

	var i = 0
	var j = 0
	var e = checkStrings.count
	while true {
		var checkRegion : String
		if j == e {
			checkRegion = buffer
		} else {
			let checkStr = checkStrings[j]
			if checkStr.pattern.type != .label {
				j += 1
				continue
			}

			// Scan to next CHECK-LABEL match, ignoring CHECK-NOT and CHECK-DAG
			guard let (matchLabelPos, matchLabelLen) = checkStr.check(buffer, true, variableTable) else {
				// Immediately bail of CHECK-LABEL fails, nothing else we can do.
				return false
			}

			checkRegion = buffer.substring(to: buffer.index(buffer.startIndex, offsetBy: matchLabelPos + matchLabelLen))
			buffer = buffer.substring(from: buffer.index(buffer.startIndex, offsetBy: matchLabelPos + matchLabelLen))
			j += 1
		}

		while i != j {
			defer { i += 1 }

			// Check each string within the scanned region, including a second check
			// of any final CHECK-LABEL (to verify CHECK-NOT and CHECK-DAG)
			guard let (matchPos, matchLen) = checkStrings[i].check(checkRegion, false, variableTable) else {
				failedChecks = true
				i = j
				break
			}

			checkRegion = checkRegion.substring(from: checkRegion.index(checkRegion.startIndex, offsetBy: matchPos + matchLen))
		}

		if j == e {
			break
		}
	}

	// Success if no checks failed.
	return !failedChecks
}


struct SMLoc {
	let unLoc : UnsafePointer<CChar>?

	init() {
		self.unLoc = nil
	}

	init(fromPointer: UnsafePointer<CChar>)  {
		self.unLoc = fromPointer
	}
}

enum CheckType {
	case none
	case plain
	case next
	case same
	case not
	case dag
	case label
	case badNot

	/// MatchEOF - When set, this pattern only matches the end of file. This is
	/// used for trailing CHECK-NOTs.
	case EOF

	// Get the size of the prefix extension.
	var size : Int {
		switch (self) {
		case .none:
			return 0
		case .badNot:
			return 0
		case .plain:
			return ":".utf8.count
		case .next:
			return "-NEXT:".utf8.count
		case .same:
			return "-SAME:".utf8.count
		case .not:
			return "-NOT:".utf8.count
		case .dag:
			return "-DAG:".utf8.count
		case .label:
			return "-LABEL:".utf8.count
		case .EOF:
			fatalError("Should not be using EOF size")
		}
	}
}

class Pattern {
	let patternLoc : SMLoc = SMLoc()

	let type : CheckType

	/// If non-empty, this pattern is a fixed string match with the specified
	/// fixed string.
	var fixedString : String = ""

	/// If non-empty, this is a regex pattern.
	var regExPattern : String = ""

	/// Contains the number of line this pattern is in.
	var lineNumber : Int = 0

	/// Entries in this vector map to uses of a variable in the pattern, e.g.
	/// "foo[[bar]]baz".  In this case, the regExPattern will contain "foobaz"
	/// and we'll get an entry in this vector that tells us to insert the value
	/// of bar at offset 3.
	var variableUses : Array<(String, Int)> = []

	/// Maps definitions of variables to their parenthesized capture numbers.
	/// E.g. for the pattern "foo[[bar:.*]]baz", VariableDefs will map "bar" to 1.
	var variableDefs : Dictionary<String, Int> = [:]

	var hasVariable : Bool {
		return !(variableUses.isEmpty && self.variableDefs.isEmpty)
	}

	init(checking ty : CheckType) {
		self.type = ty
	}

	private func addBackrefToRegEx(_ backRef : Int) {
		assert(backRef >= 1 && backRef <= 9, "Invalid backref number")
		let Backref = "\\\(backRef)"
		self.regExPattern += Backref
	}

	/// - returns: Returns a value on success or nil on a syntax error.
	private func evaluateExpression(_ e : String) -> String? {
		var expr = e
		// The only supported expression is @LINE([\+-]\d+)?
		if !expr.hasPrefix("@LINE") {
			return nil
		}
		expr = expr.substring(from: expr.index(expr.startIndex, offsetBy: "@LINE".utf8.count))
		guard let firstC = expr.utf8.first else {
			return "\(self.lineNumber)"
		}

		if firstC == "+".utf8.first! {
			expr = expr.substring(from: expr.index(after: expr.startIndex))
		} else if firstC != "-".utf8.first! {
			return nil
		}

		guard let offset = Int(expr, radix: 10) else {
			return nil
		}
		return "\(self.lineNumber + offset)"
	}

	/// Matches the pattern string against the input buffer.
	///
	/// This returns the position that is matched or npos if there is no match. If
	/// there is a match, the size of the matched string is returned in \p
	/// MatchLen.
	///
	/// The \p VariableTable StringMap provides the current values of filecheck
	/// variables and is updated if this match defines new values.
	func match(_ buffer : String, _ variableTable : [String:String]) -> (Int, Int)? {
		var matchLen : Int = 0
		// If this is the EOF pattern, match it immediately.
		if self.type == .EOF {
			matchLen = 0
			return (buffer.utf8.count, matchLen)
		}

		// If this is a fixed string pattern, just match it now.
		if !self.fixedString.isEmpty {
			matchLen = self.fixedString.utf8.count
			if let b = buffer.range(of: self.fixedString)?.lowerBound {
				return (buffer.distance(from: buffer.startIndex, to: b), matchLen)
			}
			return nil
		}

		// Regex match.

		// If there are variable uses, we need to create a temporary string with the
		// actual value.
		var regExToMatch = self.regExPattern
		if !variableUses.isEmpty {
			var insertOffset = 0
			for (v, offset) in variableUses {
				var value : String = ""

				if v.utf8.first! == "@".utf8.first! {
					guard let v = self.evaluateExpression(v) else {
						return nil
					}
					value = v
				} else {
					guard let val = variableTable[v] else {
						return nil
					}

					// Look up the value and escape it so that we can put it into the regex.
					value += NSRegularExpression.escapedPattern(for: val)
				}

				// Plop it into the regex at the adjusted offset.
				regExToMatch.insert(contentsOf: value.characters, at: regExToMatch.index(regExToMatch.startIndex, offsetBy: offset + insertOffset))
				insertOffset += value.utf8.count
			}
		}

		// Match the newly constructed regex.
		guard let r = try? NSRegularExpression(pattern: regExToMatch, options: []) else {
			return nil
		}
		let matchInfo = r.matches(in: buffer, options: [], range: NSRange(location: 0, length: buffer.utf8.count))

		// Successful regex match.
		assert(!matchInfo.isEmpty, "Didn't get any match")
		let fullMatch = matchInfo.first!

		// If this defines any variables, remember their values.
		for (_, index) in self.variableDefs {
			assert(index < matchInfo.count, "Internal paren error")
//			VariableTable[VariableDef.0] = MatchInfo[VariableDef.second]
		}

		matchLen = fullMatch.range.length
		return (fullMatch.range.location, matchLen)
	}

	/// Finds the closing sequence of a regex variable usage or definition.
	///
	/// \p Str has to point in the beginning of the definition (right after the
	/// opening sequence). Returns the offset of the closing sequence within Str,
	/// or npos if it was not found.
	private func findRegexVarEnd(_ regVar : String) -> Int? {
		var string = regVar
		// Offset keeps track of the current offset within the input Str
		var offset = 0
		// [...] Nesting depth
		var bracketDepth = 0

		while !string.isEmpty {
			if string.hasPrefix("]]") && bracketDepth == 0 {
				return offset
			}
			if string.utf8.first! == "\\".utf8.first! {
				// Backslash escapes the next char within regexes, so skip them both.
				string = string.substring(from: string.index(string.startIndex, offsetBy: 2))
				offset += 2
			} else {
				switch (string.utf8.first!) {
				case "[".utf8.first!:
					bracketDepth += 1
				case "]".utf8.first!:
					if bracketDepth == 0 {
						diagnose(.error, "missing closing \"]\" for regex variable")
						exit(1)
					}
					bracketDepth -= 1
				default:
					break
				}
				string = string.substring(from: string.index(after: string.startIndex))
				offset += 1
			}
		}

		return nil
	}

	private func addRegExToRegEx(_ RS : String, _ cur : Int) -> (Bool, Int) {
		do {
			let r = try NSRegularExpression(pattern: RS, options: [])
			self.regExPattern += RS
			return (false, cur + r.numberOfCaptureGroups)
		} catch let e {
			diagnose(.error, "invalid regex: \(e)")
			return (true, cur)
		}
	}

	/// Parses the given string into the Pattern.
	///
	/// \p Prefix provides which prefix is being matched, \p SM provides the
	/// SourceMgr used for error reports, and \p LineNumber is the line number in
	/// the input file from which the pattern string was read. Returns true in
	/// case of an error, false otherwise.
	func parse(pattern : UnsafeBufferPointer<CChar>, withPrefix prefix : String, at lineNumber : Int, options: FileCheckOptions) -> Bool {
		func mino(_ l : String.Index?, _ r : String.Index?) -> String.Index? {
			if l == nil && r == nil {
				return nil
			} else if l == nil && r != nil {
				return r
			} else if l != nil && r == nil {
				return l
			}
			return min(l!, r!)
		}


		self.lineNumber = lineNumber
		var patternStr = substring(in: pattern, with: NSRange(location: 0, length: pattern.count))
		//		let patternLoc = SMLoc(fromPointer: pat.baseAddress!)

		// Check that there is something on the line.
		if patternStr.isEmpty {
			diagnose(.error, "found empty check string with prefix '\(prefix):'")
			return true
		}

		// Check to see if this is a fixed string, or if it has regex pieces.
		if !options.contains(.matchFullLines) &&
			(patternStr.utf8.count < 2 ||
				(patternStr.range(of: "{{") == nil
					&&
				 patternStr.range(of: "[[") == nil))
		{
			self.fixedString = patternStr
			return false
		}

		if options.contains(.matchFullLines) {
			regExPattern += "^"
			if !options.contains(.strictWhitespace) {
				regExPattern += " *"
			}
		}

		// Paren value #0 is for the fully matched string.  Any new
		// parenthesized values add from there.
		var curParen = 1

		// Otherwise, there is at least one regex piece.  Build up the regex pattern
		// by escaping scary characters in fixed strings, building up one big regex.
		while !patternStr.isEmpty {
			// RegEx matches.
			if patternStr.range(of: "{{")?.lowerBound == patternStr.startIndex {
				// This is the start of a regex match.  Scan for the }}.
				guard let End = patternStr.range(of: "}}") else {
					diagnose(.error, "found start of regex string with no end '}}'")
					return true
				}

				// Enclose {{}} patterns in parens just like [[]] even though we're not
				// capturing the result for any purpose.  This is required in case the
				// expression contains an alternation like: CHECK:  abc{{x|z}}def.  We
				// want this to turn into: "abc(x|z)def" not "abcx|zdef".
				regExPattern += "("
				curParen += 1

				let (res, paren) = self.addRegExToRegEx(patternStr.substring(from: patternStr.index(patternStr.startIndex, offsetBy: 2)), curParen)
				curParen = paren
				if res {
					return true
				}
				regExPattern += ")"

				patternStr = patternStr.substring(from: patternStr.index(End.lowerBound, offsetBy: 2))
				continue
			}

			// Named RegEx matches.  These are of two forms: [[foo:.*]] which matches .*
			// (or some other regex) and assigns it to the FileCheck variable 'foo'. The
			// second form is [[foo]] which is a reference to foo.  The variable name
			// itself must be of the form "[a-zA-Z_][0-9a-zA-Z_]*", otherwise we reject
			// it.  This is to catch some common errors.
			if patternStr.hasPrefix("[[") {
				// Find the closing bracket pair ending the match.  End is going to be an
				// offset relative to the beginning of the match string.
				guard let end = self.findRegexVarEnd(patternStr.substring(from: patternStr.index(patternStr.startIndex, offsetBy: 2))) else {
					diagnose(.error, "invalid named regex reference, no ]] found")
					return true
				}

				let matchStr = patternStr.substring(
					with: Range<String.Index>(
						uncheckedBounds: (
							patternStr.index(patternStr.startIndex, offsetBy: 2),
							patternStr.index(patternStr.startIndex, offsetBy: end)
						)
					)
				)
				patternStr = patternStr.substring(from: patternStr.index(patternStr.startIndex, offsetBy: end + 4))

				// Get the regex name (e.g. "foo").
				let nameEnd = matchStr.range(of: ":")
				let name : String
				if let end = nameEnd?.lowerBound {
					name = matchStr.substring(to: end)
				} else {
					name = ""
				}

				if name.isEmpty {
					diagnose(.error, "invalid name in named regex: empty name")
					return true
				}

				// Verify that the name/expression is well formed. FileCheck currently
				// supports @LINE, @LINE+number, @LINE-number expressions. The check here
				// is relaxed, more strict check is performed in \c EvaluateExpression.
				var isExpression = false
				for (i, c) in name.utf8.enumerated() {
					if i == 0 && c == "@".utf8.first! {
						if nameEnd == nil {
							diagnose(.error, "invalid name in named regex definition")
							return true
						}
						isExpression = true
						continue
					}
					if (c != "_".utf8.first! && isalnum(Int32(c)) == 0 &&
						(!isExpression || (c != "+".utf8.first! && c != "-".utf8.first!))) {
						diagnose(.error, "invalid name in named regex")
						return true
					}
				}

				// Name can't start with a digit.
				if isdigit(Int32(name.utf8.first!)) != 0 {
					diagnose(.error, "invalid name in named regex")
					return true
				}

				// Handle [[foo]].
				guard let ne = nameEnd else {
					// Handle variables that were defined earlier on the same line by
					// emitting a backreference.
					if let VarParenNum = self.variableDefs[name] {
						if VarParenNum < 1 || VarParenNum > 9 {
							diagnose(.error, "Can't back-reference more than 9 variables")
							return true
						}
						self.addBackrefToRegEx(VarParenNum)
					} else {
						variableUses.append((name, regExPattern.utf8.count))
					}
					continue
				}

				// Handle [[foo:.*]].
				self.variableDefs[name] = curParen
				regExPattern += "("
				curParen += 1

				let (res, paren) = self.addRegExToRegEx(matchStr.substring(from: matchStr.index(after: ne.lowerBound)), curParen)
				curParen = paren
				if res {
					return true
				}

				regExPattern += ")"
			}

			// Handle fixed string matches.
			// Find the end, which is the start of the next regex.
			let fixedMatchEnd = mino(patternStr.range(of: "{{")?.lowerBound, patternStr.range(of: "[[")?.lowerBound)
			self.regExPattern += NSRegularExpression.escapedPattern(for: patternStr.substring(to: fixedMatchEnd!))
			patternStr = patternStr.substring(from: fixedMatchEnd!)
		}

		if options.contains(.matchFullLines) {
			if !options.contains(.strictWhitespace) {
				regExPattern += " *"
				regExPattern += "$"
			}
		}
		return false
	}
}

/// Count the number of newlines in the specified range.
func countNumNewlinesBetween(_ r : String) -> (Int, String.Index?) {
	var range = r
	var NumNewLines = 0
	var firstNewLine : String.Index? = nil
	while true {
		// Scan for newline.
		guard let EOL = range.range(of: "\n")?.lowerBound ?? range.range(of: "\r")?.lowerBound else {
			return (NumNewLines, firstNewLine)
		}
		range = range.substring(from: EOL)
		if range.isEmpty {
			return (NumNewLines, firstNewLine)
		}

		NumNewLines += 1

		// Handle \n\r and \r\n as a single newline.
//		if Range.utf8.count > 1 && (Range.utf8[1] == '\n' || Range[1] == '\r') && (Range[0] != Range[1]) {
//			Range = Range.substr(1)
//		}
		range = range.substring(from: range.index(after: range.startIndex))

		if NumNewLines == 1 {
			firstNewLine = range.startIndex
		}
	}
}

/// CheckString - This is a check that we found in the input file.
struct CheckString {
	/// Pat - The pattern to match.
	let pattern : Pattern

	/// Prefix - Which prefix name this check matched.
	let prefix : String

	/// Loc - The location in the match file that the check string was specified.
	let loc : SMLoc

	/// DagNotStrings - These are all of the strings that are disallowed from
	/// occurring between this match string and the previous one (or start of
	/// file).
	let dagNotStrings : Array<Pattern> = []

	/// Match check string and its "not strings" and/or "dag strings".
	func check(_ buffer : String, _ isLabelScanMode : Bool,  _ variableTable : [String:String]) -> (Int, Int)? {
		var lastPos = 0

		// IsLabelScanMode is true when we are scanning forward to find CHECK-LABEL
		// bounds we have not processed variable definitions within the bounded block
		// yet so cannot handle any final CHECK-DAG yetthis is handled when going
		// over the block again (including the last CHECK-LABEL) in normal mode.
		if !isLabelScanMode {
			// Match "dag strings" (with mixed "not strings" if any).
			guard let lp = self.checkDAG(buffer, variableTable) else {
				return nil
			}
			lastPos = lp
		}

		// Match itself from the last position after matching CHECK-DAG.
		let matchBuffer = buffer.substring(from: buffer.index(buffer.startIndex, offsetBy: lastPos))
		guard let (matchPos, matchLen) = self.pattern.match(matchBuffer, variableTable) else {
//			PrintCheckFailed(*this, MatchBuffer, VariableTable)
			return nil
		}

		// Similar to the above, in "label-scan mode" we can't yet handle CHECK-NEXT
		// or CHECK-NOT
		if !isLabelScanMode {
			let skippedRegion = buffer.substring(
				with: Range<String.Index>(
					uncheckedBounds: (
						buffer.index(buffer.startIndex, offsetBy: lastPos),
						buffer.index(buffer.startIndex, offsetBy: matchPos)
					)
				)
			)

			// If this check is a "CHECK-NEXT", verify that the previous match was on
			// the previous line (i.e. that there is one newline between them).
			if self.checkNext(skippedRegion) {
				return nil
			}

			// If this check is a "CHECK-SAME", verify that the previous match was on
			// the same line (i.e. that there is no newline between them).
			if self.checkSame(skippedRegion) {
				return nil
			}

			// If this match had "not strings", verify that they don't exist in the
			// skipped region.
			if self.checkNot(skippedRegion, [], variableTable) {
				return nil
			}
		}

		return (lastPos + matchPos, matchLen)
	}

	/// Verify there is no newline in the given buffer.
	func checkSame(_ Buffer : String) -> Bool {
		if self.pattern.type != .same {
			return false
		}

		// Count the number of newlines between the previous match and this one.
//	  assert(Buffer.data() !=
//				 SM.getMemoryBuffer(SM.FindBufferContainingLoc(
//										SMLoc::getFromPointer(Buffer.data())))
//					 ->getBufferStart() &&
//			 "CHECK-SAME can't be the first check in a file")

		let (numNewLines, _ /*firstNewLine*/) = countNumNewlinesBetween(Buffer)
		if numNewLines != 0 {
			diagnose(.error, self.prefix + "-SAME: is not on the same line as the previous match")
			diagnose(.note, "'next' match was here")
			diagnose(.note, "previous match ended here")
			return true
		}

		return false
	}

	/// Verify there is a single line in the given buffer.
	func checkNext(_ Buffer : String) -> Bool {
		if self.pattern.type != .next {
			return false
		}

		// Count the number of newlines between the previous match and this one.
//	  assert(Buffer.data() !=
//				 SM.getMemoryBuffer(SM.FindBufferContainingLoc(
//										SMLoc::getFromPointer(Buffer.data())))
//					 ->getBufferStart(), "CHECK-NEXT can't be the first check in a file")

		let (numNewLines, _ /*firstNewLine*/) = countNumNewlinesBetween(Buffer)
		if numNewLines == 0 {
			diagnose(.error, prefix + "-NEXT: is on the same line as previous match")
			diagnose(.note, "'next' match was here")
			diagnose(.note, "previous match ended here")
			return true
		}

		if numNewLines != 1 {
			diagnose(.error, prefix + "-NEXT: is not on the line after the previous match")
			diagnose(.note, "'next' match was here")
			diagnose(.note, "previous match ended here")
			diagnose(.note, "non-matching line after previous match is here")
			return true
		}

		return false
	}

	/// Verify there's no "not strings" in the given buffer.
	func checkNot(_ Buffer : String, _ NotStrings : [Pattern], _ VariableTable : [String:String]) -> Bool {
		for Pat in NotStrings {
			assert(Pat.type == .not, "Expect CHECK-NOT!")

			guard let (_, _)/*(Pos, MatchLen)*/ = Pat.match(Buffer, VariableTable) else {
				continue
			}

			diagnose(.error, self.prefix + "-NOT: string occurred!")
			diagnose(.note, self.prefix + "-NOT: pattern specified here")
			return true
		}

		return false
	}

	/// Match "dag strings" and their mixed "not strings".
	func checkDAG(_ buffer : String, _ variableTable : [String:String]) -> Int? {
		var notStrings = [Pattern]()
		if dagNotStrings.isEmpty {
			return 0
		}

		var lastPos = 0
		var startPos = lastPos

		for pattern in self.dagNotStrings {
			assert((pattern.type == .dag || pattern.type == .not), "Invalid CHECK-DAG or CHECK-NOT!")

			if pattern.type == .not {
				notStrings.append(pattern)
				continue
			}

			assert((pattern.type == .dag), "Expect CHECK-DAG!")

			// CHECK-DAG always matches from the start.
			let matchBuffer = buffer.substring(from: buffer.index(buffer.startIndex, offsetBy: startPos))
			// With a group of CHECK-DAGs, a single mismatching means the match on
			// that group of CHECK-DAGs fails immediately.
			guard let t = pattern.match(matchBuffer, variableTable) else {
//				PrintCheckFailed(SM, Pat.getLoc(), Pat, MatchBuffer, VariableTable)
				return nil
			}
			var matchPos = t.0
			let matchLen = t.1

			// Re-calc it as the offset relative to the start of the original string.
			matchPos += startPos

			if !notStrings.isEmpty {
				if matchPos < lastPos {
					// Reordered?
					diagnose(.error, prefix + "-DAG: found a match of CHECK-DAG reordering across a CHECK-NOT")
					diagnose(.note, prefix + "-DAG: the farthest match of CHECK-DAG is found here")
					diagnose(.note, prefix + "-NOT: the crossed pattern specified here")
					diagnose(.note, prefix + "-DAG: the reordered pattern specified here")
					return nil
				}
				// All subsequent CHECK-DAGs should be matched from the farthest
				// position of all precedent CHECK-DAGs (including this one.)
				startPos = lastPos
				// If there's CHECK-NOTs between two CHECK-DAGs or from CHECK to
				// CHECK-DAG, verify that there's no 'not' strings occurred in that
				// region.
				let skippedRegion = buffer.substring(
					with: Range<String.Index>(
						uncheckedBounds: (
							buffer.index(buffer.startIndex, offsetBy: lastPos),
							buffer.index(buffer.startIndex, offsetBy: matchPos)
						)
					)
				)
				if self.checkNot(skippedRegion, notStrings, variableTable) {
					return nil
				}
				// Clear "not strings".
				notStrings.removeAll()
			}
			
			// Update the last position with CHECK-DAG matches.
			lastPos = max(matchPos + matchLen, lastPos)
		}
		
		return lastPos
	}
}

enum DiagnosticKind {
	case error
	case warning
	case note
}

func diagnose(_ kind : DiagnosticKind, _ message : String) {
	print(message)
}
