package ge.devtool.samples.ui

/** Stress screen strings. [SampleStrings.stress] picks the table for the active language. */
internal interface StressStrings {
    val title: String
}

/** English stress screen strings. */
internal object EnStressStrings : StressStrings {
    override val title = "Stress"
}

/** Georgian stress screen strings. */
internal object KaStressStrings : StressStrings {
    override val title = "სტრესი"
}
