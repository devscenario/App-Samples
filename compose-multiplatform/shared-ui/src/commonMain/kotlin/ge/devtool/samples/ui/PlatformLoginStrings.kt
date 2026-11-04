package ge.devtool.samples.ui

import androidx.compose.runtime.Composable

/**
 * The login screen's strings as the platform serves them: Android loads them from its string
 * resources (`strings.xml`, per language), iOS uses the shared tables. Same texts on both.
 */
@Composable
internal expect fun platformLoginStrings(): LoginStrings
