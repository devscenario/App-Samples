import XCTest

/// A Dev Scenario selector as an XCUITest predicate, with the iOS driver's matching rules
/// (`WdaSelector.matches` in the WDA runner, `IosWdaHierarchyParser` on the host):
///
/// - A node's text is its label, else its title, else its value, else its placeholder.
/// - `text` is an exact match on that text; a plain .ds string (`tap("Login")`) is `text`.
/// - `id` matches the accessibility identifier, or the part after its last `/` or `.`.
/// - `textRegex` is a find (`containsMatchIn`), not a whole-string match.
/// - `containsText` (`assertContainsText`) is a case-insensitive substring of the text.
///
/// Queries run over `app.descendants(matching: .any)`, which never includes the application
/// element itself (the driver skips it too), and take the first match in hierarchy order.
enum RegressionSelector: CustomStringConvertible {
    case text(String)
    case id(String)
    case textRegex(String)
    case containsText(String)

    var predicate: NSPredicate {
        switch self {
        case let .text(text):
            return NSPredicate(
                format: "label == %@ OR (label == '' AND (title == %@ OR (title == '' AND " +
                    "(value == %@ OR ((value == nil OR value == '') AND placeholderValue == %@)))))",
                text, text, text, text
            )
        case let .id(id):
            return NSPredicate(
                format: "identifier == %@ OR identifier ENDSWITH %@ OR identifier ENDSWITH %@",
                id, "/" + id, "." + id
            )
        case let .textRegex(pattern):
            // MATCHES is a whole-string match; wrapping it makes it a find, like the driver.
            let find = "(?s).*(?:" + pattern + ").*"
            return NSPredicate(
                format: "label MATCHES %@ OR (label == '' AND (title MATCHES %@ OR (title == '' AND value MATCHES %@)))",
                find, find, find
            )
        case let .containsText(text):
            return NSPredicate(
                format: "label CONTAINS[c] %@ OR (label == '' AND (title CONTAINS[c] %@ OR (title == '' AND " +
                    "(value CONTAINS[c] %@ OR placeholderValue CONTAINS[c] %@))))",
                text, text, text, text
            )
        }
    }

    var description: String {
        switch self {
        case let .text(text): return "text \"\(text)\""
        case let .id(id): return "id \"\(id)\""
        case let .textRegex(pattern): return "textRegex \"\(pattern)\""
        case let .containsText(text): return "containsText \"\(text)\""
        }
    }
}
