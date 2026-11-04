package ge.devtool.samples.android.regression

import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsNode
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.test.SemanticsMatcher
import java.text.Normalizer

/**
 * Text selectors with the Dev Scenario Android matcher's semantics: a .ds text selector
 * (`tap("Login")`, `assertVisible("…")`) matches a node whose text or content description
 * *contains* the target, case-insensitively, after NFC normalisation, invisible-character
 * stripping and whitespace collapsing. Among several matches the exact one wins, then a
 * clickable one, then a focusable one, then an enabled one, then the first in tree order.
 */
internal object TextSelectors {

    private val INVISIBLE = Regex("[\\u200B-\\u200F\\u202A-\\u202E\\u2060\\uFEFF]")
    private val WHITESPACE_RUN = Regex("\\s+")

    fun normalize(value: String): String {
        val nfc = Normalizer.normalize(value, Normalizer.Form.NFC)
        return WHITESPACE_RUN.replace(INVISIBLE.replace(nfc, ""), " ").trim()
    }

    /** Text, editable text and content description of a (merged) semantics node. */
    fun SemanticsNode.selectorTexts(): List<String> = buildList {
        config.getOrNull(SemanticsProperties.Text)?.forEach { add(it.text) }
        config.getOrNull(SemanticsProperties.EditableText)?.let { add(it.text) }
        config.getOrNull(SemanticsProperties.ContentDescription)?.let { addAll(it) }
    }.filter { it.isNotBlank() }

    fun containsTarget(value: String, target: String): Boolean {
        val needle = normalize(target)
        return needle.isNotEmpty() && normalize(value).contains(needle, ignoreCase = true)
    }

    /** `text: "…"` selector. */
    fun hasSelectorText(target: String): SemanticsMatcher =
        SemanticsMatcher("text contains \"$target\" (ignore case)") { node ->
            node.selectorTexts().any { containsTarget(it, target) }
        }

    /** `textRegex: "…"` selector: `containsMatchIn` on the text or content description. */
    fun hasTextMatching(pattern: String): SemanticsMatcher {
        val regex = Regex(pattern)
        return SemanticsMatcher("text matches /$pattern/") { node ->
            node.selectorTexts().any { regex.containsMatchIn(it) }
        }
    }

    /**
     * Index (into the matcher's node list) of the node a tap on [target] picks, or null when no
     * [eligible] node with a size matches.
     */
    fun pickIndex(
        nodes: List<SemanticsNode>,
        target: String?,
        eligible: (SemanticsNode) -> Boolean = { true },
    ): Int? = nodes.withIndex()
        .filter { (_, node) -> node.size.width > 0 && node.size.height > 0 && eligible(node) }
        .sortedWith(
            compareBy<IndexedValue<SemanticsNode>> { (_, node) -> if (target != null && node.isExact(target)) 0 else 1 }
                .thenBy { (_, node) -> if (node.config.contains(SemanticsActions.OnClick)) 0 else 1 }
                .thenBy { (_, node) -> if (node.config.contains(SemanticsProperties.Focused)) 0 else 1 }
                .thenBy { (_, node) -> if (node.config.contains(SemanticsProperties.Disabled)) 1 else 0 }
        )
        .firstOrNull()
        ?.index

    private fun SemanticsNode.isExact(target: String): Boolean {
        val needle = normalize(target)
        return selectorTexts().any { normalize(it).equals(needle, ignoreCase = true) }
    }
}
