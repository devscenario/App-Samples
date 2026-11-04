package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun ModalScreen() {
    val strings = LocalSampleStrings.current
    val scope = rememberCoroutineScope()
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

    var statusText by remember { mutableStateOf(strings.modals.statusNone) }
    var sheetMode by remember { mutableStateOf<SheetMode?>(null) }
    var showAlertDialog by remember { mutableStateOf(false) }
    var showFullscreenDialog by remember { mutableStateOf(false) }
    var showVerifySheet by remember { mutableStateOf(false) }
    var promoRequested by remember { mutableStateOf(false) }
    var showPromo by remember { mutableStateOf(false) }

    // The promo comes up on its own a moment after it is requested, like a server-driven one.
    LaunchedEffect(promoRequested) {
        if (!promoRequested) return@LaunchedEffect
        delay(PROMO_DELAY_MS)
        promoRequested = false
        showPromo = true
    }

    // Set by "Hide sheet" so its own status wins over the swipe-dismiss fallback below.
    var hidingWithAction by remember { mutableStateOf(false) }

    LaunchedEffect(sheetMode) {
        when (sheetMode) {
            SheetMode.PARTIAL -> {
                hidingWithAction = false
                sheetState.show()
                sheetState.partialExpand()
                statusText = strings.modals.statusPartialVisible
            }
            SheetMode.FULL -> {
                hidingWithAction = false
                sheetState.show()
                sheetState.expand()
                statusText = strings.modals.statusFullVisible
            }
            null -> return@LaunchedEffect
        }
        // On Android a swipe can settle the sheet hidden without calling onDismissRequest: its
        // empty window stays on top and eats the next touch. Once the sheet is hidden, it's dismissed.
        snapshotFlow { sheetState.isVisible }.first { !it }
        if (!hidingWithAction) {
            sheetMode = null
            statusText = strings.modals.statusSheetDismissed
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(strings.modals.title, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Text(strings.modals.intro, color = subtleText)

        SurfaceCard(modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    Button(
                        onClick = { sheetMode = SheetMode.PARTIAL },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_OPEN_PARTIAL_SHEET)
                    ) {
                        Text(strings.modals.partialSheet)
                    }
                    Button(
                        onClick = { sheetMode = SheetMode.FULL },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_OPEN_FULL_SHEET)
                    ) {
                        Text(strings.modals.fullSheet)
                    }
                }

                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    OutlinedButton(
                        onClick = {
                            showAlertDialog = true
                            statusText = strings.modals.statusAlertVisible
                        },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_OPEN_ALERT_DIALOG)
                    ) {
                        Text(strings.modals.alertDialog)
                    }
                    OutlinedButton(
                        onClick = {
                            showFullscreenDialog = true
                            statusText = strings.modals.statusFullscreenVisible
                        },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_OPEN_FULLSCREEN_DIALOG)
                    ) {
                        Text(strings.modals.fullscreenDialog)
                    }
                }

                OutlinedButton(
                    onClick = { showVerifySheet = true },
                    modifier = Modifier.fillMaxWidth().testTag(TestTags.MODALS_OPEN_VERIFY_SHEET)
                ) {
                    Text(strings.modals.codeSheet)
                }

                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    OutlinedButton(
                        onClick = { promoRequested = true },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_PROMO_SOON)
                    ) {
                        Text(strings.modals.promoSoon)
                    }
                    OutlinedButton(
                        onClick = { statusText = strings.modals.statusTargetTapped },
                        modifier = Modifier.weight(1f).testTag(TestTags.MODALS_PROMO_TARGET)
                    ) {
                        Text(strings.modals.promoTarget)
                    }
                }
            }
        }

        StatusPill(
            text = strings.modals.status(statusText),
            tone = PillTone.INFO,
            modifier = Modifier.testTag(TestTags.MODALS_STATUS),
        )
    }

    if (sheetMode != null) {
        ModalBottomSheet(
            onDismissRequest = {
                sheetMode = null
                statusText = strings.modals.statusSheetDismissed
            },
            sheetState = sheetState,
            modifier = Modifier.testTag(TestTags.MODALS_SHEET)
        ) {
            val isFullSheet = sheetMode == SheetMode.FULL
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(if (isFullSheet) Modifier.fillMaxSize() else Modifier.heightIn(min = 180.dp))
                    .padding(16.dp)
                    .then(if (isFullSheet) Modifier.verticalScroll(rememberScrollState()) else Modifier),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Text(strings.modals.bottomSheet, style = MaterialTheme.typography.titleLarge)
                Text(strings.modals.sheetIntro)
                if (isFullSheet) {
                    HorizontalDivider()
                    Text("Section 1 — Details", style = MaterialTheme.typography.titleMedium)
                    Text("This is a fully expanded bottom sheet. It contains enough content to fill the entire screen height.")
                    Text("Item A: Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    Text("Item B: Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                    Text("Item C: Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.")
                    HorizontalDivider()
                    Text("Section 2 — More Content", style = MaterialTheme.typography.titleMedium)
                    Text("Item D: Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.")
                    Text("Item E: Excepteur sint occaecat cupidatat non proident.")
                    Text("Item F: Sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    HorizontalDivider()
                    Text("Section 3 — Actions", style = MaterialTheme.typography.titleMedium)
                    Text("Item G: Curabitur pretium tincidunt lacus. Nulla gravida orci a odio.")
                    Text("Item H: Nullam varius, turpis molestie dictum semper, ipsum libero faucibus nulla.")
                    Text("Item I: Pellentesque ut neque. Pellentesque habitant morbi tristique senectus.")
                    HorizontalDivider()
                    Text("Section 4 — Summary", style = MaterialTheme.typography.titleMedium)
                    Text("Item J: Fusce fermentum. Nullam varius nulla gravida orci a odio.")
                    Text("Item K: Maecenas porttitor congue massa. Fusce posuere, magna sed pulvinar.")
                    Spacer(modifier = Modifier.height(8.dp))
                }
                TextButton(
                    onClick = {
                        hidingWithAction = true
                        scope.launch {
                            sheetState.hide()
                            sheetMode = null
                            statusText = strings.modals.statusSheetHidden
                        }
                    },
                    modifier = Modifier.testTag(TestTags.MODALS_SHEET_HIDE)
                ) {
                    Text(strings.modals.hideSheet)
                }
            }
        }
    }

    if (showVerifySheet) {
        VerifyCodeSheet(
            onVerify = { code ->
                showVerifySheet = false
                statusText = strings.modals.statusCodeVerified(code)
            },
            onDismiss = { showVerifySheet = false },
        )
    }

    if (showPromo) {
        PromoSheet(onClose = { showPromo = false })
    }

    if (showAlertDialog) {
        AlertDialog(
            onDismissRequest = {
                showAlertDialog = false
                statusText = strings.modals.statusAlertDismissed
            },
            title = { Text(strings.modals.alertTitle) },
            text = { Text(strings.modals.alertBody) },
            confirmButton = {
                TextButton(
                    onClick = {
                        showAlertDialog = false
                        statusText = strings.modals.statusAlertConfirmed
                    },
                    modifier = Modifier.testTag(TestTags.MODALS_ALERT_CONFIRM)
                ) {
                    Text(strings.modals.confirm)
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        showAlertDialog = false
                        statusText = strings.modals.statusAlertHidden
                    },
                    modifier = Modifier.testTag(TestTags.MODALS_ALERT_DISMISS)
                ) {
                    Text(strings.modals.dismiss)
                }
            }
        )
    }

    if (showFullscreenDialog) {
        Dialog(
            onDismissRequest = {
                showFullscreenDialog = false
                statusText = strings.modals.statusFullscreenDismissed
            }
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
                    .testTag(TestTags.MODALS_FULLSCREEN_DIALOG),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Text(strings.modals.fullscreenTitle, style = MaterialTheme.typography.titleLarge)
                Text(strings.modals.fullscreenBody)
                Button(
                    onClick = {
                        showFullscreenDialog = false
                        statusText = strings.modals.statusFullscreenHidden
                    },
                    modifier = Modifier.testTag(TestTags.MODALS_FULLSCREEN_CLOSE)
                ) {
                    Text(strings.modals.close)
                }
            }
        }
    }
}

private const val PROMO_DELAY_MS = 700L

private enum class SheetMode {
    PARTIAL,
    FULL
}
