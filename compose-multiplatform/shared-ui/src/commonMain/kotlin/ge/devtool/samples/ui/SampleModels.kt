package ge.devtool.samples.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.FormatListBulleted
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.AttachFile
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Description
import androidx.compose.material.icons.filled.Gesture
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.OpenWith
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.PersonAdd
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.ShoppingBag
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.Tune
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Sample screens reachable from the home grid. `HOME` is the grid
 * itself (the bottom of the navigation stack); the others are detail
 * destinations pushed when their cell is tapped. `tag` mirrors the
 * cell `testTag` so cross-platform E2E flows resolve the same key
 * whether the screen is reached via a tab or a grid cell. `icon`
 * mirrors the iOS-native sample's `systemImage` so the home grid
 * looks roughly the same on either platform.
 */
internal enum class SampleScreen(
    val tag: String,
    val icon: ImageVector,
) {
    HOME(TestTags.APP_ROOT, Icons.Filled.Home),
    LOGIN(TestTags.TAB_LOGIN, Icons.Filled.AccountCircle),
    REGISTRATION(TestTags.TAB_REGISTRATION, Icons.Filled.PersonAdd),
    LIST(TestTags.TAB_LIST, Icons.AutoMirrored.Filled.FormatListBulleted),
    GRID(TestTags.TAB_GRID, Icons.Filled.GridView),
    SHOWCASE(TestTags.TAB_SHOWCASE, Icons.Filled.Tune),
    SEARCH(TestTags.TAB_SEARCH, Icons.Filled.Search),
    CHECKOUT(TestTags.TAB_CHECKOUT, Icons.Filled.ShoppingBag),
    PROFILE(TestTags.TAB_PROFILE, Icons.Filled.Person),
    PINCH(TestTags.TAB_PINCH, Icons.Filled.Gesture),
    MODALS(TestTags.TAB_MODALS, Icons.Filled.Layers),
    DRAG_DROP(TestTags.TAB_DRAG_DROP, Icons.Filled.OpenWith),
    NETWORK(TestTags.TAB_NETWORK, Icons.Filled.Cloud),
    FILES(TestTags.TAB_FILES, Icons.Filled.AttachFile),
    APP_FILES(TestTags.TAB_APP_FILES, Icons.Filled.Description),
    WEBVIEW(TestTags.TAB_WEBVIEW, Icons.Filled.Language),
    STRESS(TestTags.TAB_STRESS, Icons.Filled.Speed),
    BACKEND(TestTags.TAB_BACKEND, Icons.Filled.Storage),
}

/**
 * Resolves a screen's title from the active [SampleStrings] table. The enum
 * can't read a CompositionLocal directly, so the title is mapped here at the
 * call site (the enum keeps only its identity / tag / icon wiring).
 */
internal fun SampleScreen.title(strings: SampleStrings): String = when (this) {
    SampleScreen.HOME -> strings.titleHome
    SampleScreen.LOGIN -> strings.titleLogin
    SampleScreen.REGISTRATION -> strings.titleRegistration
    SampleScreen.LIST -> strings.titleList
    SampleScreen.GRID -> strings.titleGrid
    SampleScreen.SHOWCASE -> strings.titleShowcase
    SampleScreen.SEARCH -> strings.titleSearch
    SampleScreen.CHECKOUT -> strings.titleCheckout
    SampleScreen.PROFILE -> strings.titleProfile
    SampleScreen.PINCH -> strings.titlePinch
    SampleScreen.MODALS -> strings.titleModals
    SampleScreen.DRAG_DROP -> strings.titleDragDrop
    SampleScreen.NETWORK -> strings.titleNetwork
    SampleScreen.FILES -> strings.titleFiles
    SampleScreen.APP_FILES -> strings.appFiles.title
    SampleScreen.WEBVIEW -> strings.titleWebView
    SampleScreen.STRESS -> strings.stress.title
    SampleScreen.BACKEND -> strings.backend.title
}
internal data class SampleTouchIndicator(val id: Long, val position: Offset)
internal data class SampleOrderItem(val id: String, val customer: String, val total: String, val status: String)
internal data class SampleProductItem(val name: String, val price: String, val inventory: String)
internal data class CatalogItem(val name: String, val category: String, val price: String)

