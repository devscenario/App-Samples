package ge.devtool.samples.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * The sample app's look: one blue accent on soft neutral surfaces, rounded shapes and tighter
 * headings. Follows the system light/dark setting. Every screen reads colours from here, so the
 * Material components (fields, buttons, switches, sheets) pick the look up without per-screen code.
 */
@Composable
internal fun SampleTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) DarkSampleColors else LightSampleColors,
        shapes = SampleShapes,
        typography = SampleTypography,
        content = content,
    )
}

/** Colours a few screens use beyond the Material scheme (status, drop zones, swatches). */
internal object SampleAccents {
    val brand = Color(0xFF2F5BEA)
    val brandSoft = Color(0xFFE8EEFF)
    val success = Color(0xFF1E8E4E)
    val successSoft = Color(0xFFE5F5EC)
    val warning = Color(0xFFB86A00)
    val error = Color(0xFFD03A3A)
    val neutralSoft = Color(0xFFF1F3F8)
    val neutralLine = Color(0xFFD9DEEA)

    /** Icon badge colours on the home tiles, cycled by position. */
    val tileTints = listOf(
        Color(0xFF2F5BEA) to Color(0xFFE8EEFF),
        Color(0xFF7A4DE8) to Color(0xFFF0EAFF),
        Color(0xFF0E8A7A) to Color(0xFFE0F5F1),
        Color(0xFFD9541E) to Color(0xFFFFEDE4),
        Color(0xFFC2367A) to Color(0xFFFDE8F2),
        Color(0xFF2B7FC9) to Color(0xFFE3F1FC),
    )
}

private val LightSampleColors = lightColorScheme(
    primary = SampleAccents.brand,
    onPrimary = Color.White,
    primaryContainer = SampleAccents.brandSoft,
    onPrimaryContainer = Color(0xFF13286E),
    secondary = Color(0xFF5B6478),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFE6E9F2),
    onSecondaryContainer = Color(0xFF1C2233),
    background = Color(0xFFF6F7FB),
    onBackground = Color(0xFF0E1117),
    surface = Color(0xFFF6F7FB),
    onSurface = Color(0xFF0E1117),
    onSurfaceVariant = Color(0xFF5B6478),
    surfaceContainerLowest = Color(0xFFF6F7FB),
    surfaceContainerLow = Color.White,
    surfaceContainer = Color.White,
    surfaceContainerHigh = Color.White,
    surfaceContainerHighest = Color(0xFFECEFF5),
    outline = Color(0xFFC9CFDC),
    outlineVariant = Color(0xFFE3E7EF),
    error = SampleAccents.error,
)

private val DarkSampleColors = darkColorScheme(
    primary = Color(0xFF7C9CFF),
    onPrimary = Color(0xFF0B1A4D),
    primaryContainer = Color(0xFF1E2B57),
    onPrimaryContainer = Color(0xFFDCE4FF),
    secondary = Color(0xFFA7AFC2),
    secondaryContainer = Color(0xFF262B38),
    onSecondaryContainer = Color(0xFFE3E7F0),
    background = Color(0xFF0E1015),
    onBackground = Color(0xFFEDEFF4),
    surface = Color(0xFF0E1015),
    onSurface = Color(0xFFEDEFF4),
    onSurfaceVariant = Color(0xFFA7AFC2),
    surfaceContainerLowest = Color(0xFF0E1015),
    surfaceContainerLow = Color(0xFF171A21),
    surfaceContainer = Color(0xFF171A21),
    surfaceContainerHigh = Color(0xFF1C2029),
    surfaceContainerHighest = Color(0xFF242936),
    outline = Color(0xFF3A4152),
    outlineVariant = Color(0xFF2A303D),
    error = Color(0xFFFF8A80),
)

private val SampleShapes = Shapes(
    extraSmall = RoundedCornerShape(12.dp),
    small = RoundedCornerShape(12.dp),
    medium = RoundedCornerShape(18.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(28.dp),
)

private val SampleTypography = Typography().run {
    copy(
        headlineSmall = headlineSmall.tight(FontWeight.Bold),
        titleLarge = titleLarge.tight(FontWeight.SemiBold),
        titleMedium = titleMedium.copy(fontWeight = FontWeight.SemiBold),
        labelLarge = labelLarge.copy(fontWeight = FontWeight.SemiBold, fontSize = 15.sp),
    )
}

private fun TextStyle.tight(weight: FontWeight) = copy(fontWeight = weight, letterSpacing = (-0.3).sp)
