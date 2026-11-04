package ge.devtool.samples.ui

/** App files screen strings. [SampleStrings.appFiles] picks the table for the active language. */
internal interface AppFilesStrings {
    val title: String
    val add: String
    val read: String
    val delete: String
    val missing: String
    val empty: String
    fun line(number: Int): String
}

/** English App files screen strings. */
internal object EnAppFilesStrings : AppFilesStrings {
    override val title = "App files"
    override val add = "Add line"
    override val read = "Read file"
    override val delete = "Delete file"
    override val missing = "No file"
    override val empty = "Empty file"
    override fun line(number: Int) = "Line $number"
}

/** Georgian App files screen strings. */
internal object KaAppFilesStrings : AppFilesStrings {
    override val title = "აპის ფაილები"
    override val add = "ხაზის დამატება"
    override val read = "ფაილის წაკითხვა"
    override val delete = "ფაილის წაშლა"
    override val missing = "ფაილი არ არის"
    override val empty = "ფაილი ცარიელია"
    override fun line(number: Int) = "ხაზი $number"
}
