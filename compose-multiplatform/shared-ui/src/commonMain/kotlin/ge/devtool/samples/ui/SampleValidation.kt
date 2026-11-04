package ge.devtool.samples.ui

internal fun String.isValidEmail(): Boolean {
    val atIndex = indexOf('@')
    val dotIndex = lastIndexOf('.')
    return atIndex > 0 && dotIndex > atIndex + 1 && dotIndex < lastIndex && none { it.isWhitespace() }
}

