package ge.devtool.samples.ui

import androidx.compose.runtime.Composable

/** iOS `actual`: the shared table for the active language. */
@Composable
internal actual fun platformLoginStrings(): LoginStrings = LocalSampleStrings.current.login
