package ge.devtool.samples.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Language
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.PointerEventPass
import androidx.compose.ui.input.pointer.changedToDownIgnoreConsumed
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigationevent.NavigationEventInfo
import androidx.navigationevent.compose.NavigationBackHandler
import androidx.navigationevent.compose.rememberNavigationEventState
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds

/** Launch argument the home screen shows: an Android string extra, an iOS launch argument (`-env staging`). */
const val SAMPLE_LAUNCH_ENV_KEY = "env"

/**
 * [launchEnv]: the app's [SAMPLE_LAUNCH_ENV_KEY] launch argument, null when it wasn't given.
 * [backendUrl]: base URL of `test-backend` for the Backend screen.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SampleApp(launchEnv: String? = null, backendUrl: String = IOS_DEFAULT_BACKEND_URL) {
    SampleTheme {
        // Display language, seeded from the OS-level per-app locale via
        // SampleLocaleController.current(). DEFAULT stays ENGLISH for any OS
        // locale other than Georgian, so existing English-asserting E2E flows /
        // Espresso parity tests keep passing. The displayed strings come from
        // the kept En/Ka tables (LocalSampleStrings); selecting a language also
        // mirrors the choice into the OS locale so it persists and the devtool's
        // flow-translation auto-detection (reading from the locale) observes it.
        var language by remember { mutableStateOf(SampleLocaleController.current()) }
        val strings = if (language == SampleLanguage.GEORGIAN) KaStrings else EnStrings

        // Push/pop navigation stack. Home is the bottom of the stack;
        // each cell tap pushes a screen and the TopAppBar's back arrow
        // pops it. Plain `mutableStateOf(list)` — Compose recomposes
        // whenever the reference changes, no nav library required.
        var stack by remember { mutableStateOf(listOf(SampleScreen.HOME)) }
        val current = stack.last()
        val navigate: (List<SampleScreen>) -> Unit = { next -> stack = next }
        val touchIndicators = remember { mutableStateListOf<SampleTouchIndicator>() }
        var nextTouchIndicatorId by remember { mutableStateOf(0L) }

        // System back (Android Back, the iOS swipe from the left edge) pops a screen like the
        // TopAppBar "Back" does. On the home grid it's disabled, so Android Back leaves the app.
        NavigationBackHandler(
            state = rememberNavigationEventState(NavigationEventInfo.None),
            isBackEnabled = stack.size > 1,
            onBackCompleted = { navigate(stack.dropLast(1)) },
        )

        CompositionLocalProvider(LocalSampleStrings provides strings) {
        Scaffold(
            modifier = Modifier
                .fillMaxSize()
                .testTag(TestTags.APP_ROOT)
                .pointerInput(Unit) {
                    coroutineScope {
                        awaitPointerEventScope {
                            while (true) {
                                val event = awaitPointerEvent(PointerEventPass.Initial)
                                event.changes
                                    .filter { it.changedToDownIgnoreConsumed() }
                                    .forEach { change ->
                                        val indicator = SampleTouchIndicator(nextTouchIndicatorId++, change.position)
                                        touchIndicators += indicator
                                        launch {
                                            delay(TOUCH_INDICATOR_DURATION_MS.milliseconds)
                                            touchIndicators.remove(indicator)
                                        }
                                    }
                            }
                        }
                    }
                }
                .drawWithContent {
                    drawContent()
                    touchIndicators.forEach { indicator ->
                        drawCircle(
                            color = TOUCH_INDICATOR_COLOR,
                            radius = TOUCH_INDICATOR_RADIUS.toPx(),
                            center = indicator.position
                        )
                    }
                },
            // `surfaceContainerLowest` ≈ iOS's `systemBackground` — a flat
            // off-white/dark-grey that lets the slightly elevated cards
            // pop. The default Scaffold background is `background`, which
            // sits at the same elevation as Cards' default container and
            // makes the grid feel like a single flat sheet.
            containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            current.title(strings),
                            style = MaterialTheme.typography.titleLarge,
                            modifier = Modifier.testTag(TestTags.NAV_TITLE),
                        )
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surfaceContainerLowest,
                        actionIconContentColor = MaterialTheme.colorScheme.primary,
                    ),
                    navigationIcon = {
                        if (stack.size > 1) {
                            // A chevron plus the visible "Back" text: flows tap the text or NAV_BACK.
                            TextButton(
                                onClick = { navigate(stack.dropLast(1)) },
                                contentPadding = PaddingValues(start = 4.dp, end = 10.dp),
                                modifier = Modifier.testTag(TestTags.NAV_BACK)
                            ) {
                                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = null, modifier = Modifier.size(26.dp))
                                Text(strings.back, fontWeight = FontWeight.SemiBold)
                            }
                        }
                    },
                    actions = {
                        LanguageChooser(
                            language = language,
                            strings = strings,
                            onSelect = { sel ->
                                // Live UI via the kept tables…
                                language = sel
                                // …plus OS persistence + detectability. On
                                // Android this recreates the activity; the new
                                // composition re-seeds from current(), so the
                                // state stays consistent (no crash/loop).
                                SampleLocaleController.apply(sel)
                            },
                        )
                    }
                )
            }
        ) { innerPadding ->
            Box(modifier = Modifier.fillMaxSize().padding(innerPadding)) {
                if (current == SampleScreen.HOME) {
                    HomeGrid(launchEnv, onSelect = { entry -> navigate(stack + entry) })
                } else {
                    ScreenContent(current, backendUrl)
                }
            }
        }
        }
    }
}

/**
 * Language chooser rendered in the TopAppBar `actions` slot (right corner).
 * An IconButton (globe) opens a DropdownMenu with English / Georgian; the
 * active language is checkmarked. Tinted via `MaterialTheme.colorScheme` to
 * match the existing TopAppBar icons. Test tags let flows drive it.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun LanguageChooser(
    language: SampleLanguage,
    strings: SampleStrings,
    onSelect: (SampleLanguage) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }
    IconButton(
        onClick = { expanded = true },
        modifier = Modifier.testTag(TestTags.ACTION_LANGUAGE),
    ) {
        Icon(
            imageVector = Icons.Filled.Language,
            contentDescription = strings.languageChooser,
            tint = MaterialTheme.colorScheme.primary,
        )
    }
    DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
        DropdownMenuItem(
            text = { Text(strings.languageEnglish) },
            onClick = {
                onSelect(SampleLanguage.ENGLISH)
                expanded = false
            },
            trailingIcon = {
                if (language == SampleLanguage.ENGLISH) {
                    Icon(Icons.Filled.Check, contentDescription = null)
                }
            },
            modifier = Modifier.testTag(TestTags.LANG_ENGLISH),
        )
        DropdownMenuItem(
            text = { Text(strings.languageGeorgian) },
            onClick = {
                onSelect(SampleLanguage.GEORGIAN)
                expanded = false
            },
            trailingIcon = {
                if (language == SampleLanguage.GEORGIAN) {
                    Icon(Icons.Filled.Check, contentDescription = null)
                }
            },
            modifier = Modifier.testTag(TestTags.LANG_GEORGIAN),
        )
    }
}

private const val TOUCH_INDICATOR_DURATION_MS = 450L
private val TOUCH_INDICATOR_RADIUS = 24.dp
private val TOUCH_INDICATOR_COLOR = SampleAccents.brand.copy(alpha = 0.45f)

@Composable
private fun HomeGrid(launchEnv: String?, onSelect: (SampleScreen) -> Unit) {
    val strings = LocalSampleStrings.current
    LazyVerticalGrid(
        columns = GridCells.Adaptive(140.dp),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier.fillMaxSize().testTag(TestTags.HOME_GRID)
    ) {
        if (launchEnv != null) {
            item(span = { GridItemSpan(maxLineSpan) }) {
                Text("Launch env: $launchEnv", modifier = Modifier.testTag(TestTags.HOME_LAUNCH_ENV))
            }
        }
        itemsIndexed(SampleScreen.entries.filter { it != SampleScreen.HOME }) { index, screen ->
            HomeTile(screen, index, onClick = { onSelect(screen) })
        }
    }
}

/** A home tile: the screen's icon on a tinted badge above its title, on a white rounded card. */
@Composable
private fun HomeTile(screen: SampleScreen, index: Int, onClick: () -> Unit) {
    val strings = LocalSampleStrings.current
    val (tint, badge) = SampleAccents.tileTints[index % SampleAccents.tileTints.size]
    Card(
        onClick = onClick,
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerHigh),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant),
        modifier = Modifier
            .fillMaxSize()
            .height(140.dp)
            .testTag(screen.tag)
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Box(
                modifier = Modifier.size(52.dp).background(badge, CircleShape),
                contentAlignment = Alignment.Center,
            ) {
                Icon(imageVector = screen.icon, contentDescription = null, tint = tint, modifier = Modifier.size(26.dp))
            }
            Box(modifier = Modifier.height(12.dp))
            Text(
                text = screen.title(strings),
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.SemiBold,
            )
        }
    }
}

@Composable
private fun ScreenContent(screen: SampleScreen, backendUrl: String) {
    when (screen) {
        SampleScreen.HOME -> Unit
        SampleScreen.LOGIN -> LoginScreen()
        SampleScreen.REGISTRATION -> RegistrationScreen()
        SampleScreen.LIST -> ListScreen()
        SampleScreen.GRID -> GridScreen()
        SampleScreen.SHOWCASE -> ShowcaseScreen()
        SampleScreen.SEARCH -> SearchScreen()
        SampleScreen.CHECKOUT -> CheckoutScreen()
        SampleScreen.PROFILE -> ProfileScreen()
        SampleScreen.PINCH -> PinchScreen()
        SampleScreen.MODALS -> ModalScreen()
        SampleScreen.DRAG_DROP -> DragDropScreen()
        SampleScreen.NETWORK -> NetworkScreen()
        SampleScreen.FILES -> FilesScreen()
        SampleScreen.APP_FILES -> AppFilesScreen()
        SampleScreen.WEBVIEW -> WebViewScreen()
        SampleScreen.STRESS -> StressScreen()
        SampleScreen.BACKEND -> BackendScreen(backendUrl)
    }
}

