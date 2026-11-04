package ge.devtool.samples.android.regression

/**
 * The three step surfaces a unit uses: [ui] for the app's Compose window, [gesture] for swipes,
 * scrolls, pinches and drags, [system] for web content and the system file picker.
 */
internal class RegressionSteps(
    val ui: ComposeSteps,
    val gesture: GestureSteps,
    val system: SystemSteps,
)
