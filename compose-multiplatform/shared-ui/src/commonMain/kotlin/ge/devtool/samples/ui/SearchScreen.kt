package ge.devtool.samples.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp

@Composable
internal fun SearchScreen() {
    val strings = LocalSampleStrings.current
    val catalog = remember {
        listOf(
            CatalogItem("Wireless Headphones", "Audio", "$89.99"),
            CatalogItem("Noise Canceling Headphones", "Audio", "$129.99"),
            CatalogItem("USB-C Travel Charger", "Accessories", "$24.99"),
            CatalogItem("Fitness Watch", "Wearables", "$149.99"),
            CatalogItem("Laptop Backpack", "Travel", "$59.99")
        )
    }
    var query by remember { mutableStateOf("") }
    var submittedQuery by remember { mutableStateOf("") }
    val focusManager = LocalFocusManager.current
    val results = remember(submittedQuery) {
        if (submittedQuery.isBlank()) {
            catalog
        } else {
            catalog.filter { item ->
                item.name.contains(submittedQuery, ignoreCase = true) ||
                    item.category.contains(submittedQuery, ignoreCase = true)
            }
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(strings.searchTitle, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        OutlinedTextField(
            value = query,
            onValueChange = { query = it },
            label = { Text(strings.searchField) },
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
            keyboardActions = KeyboardActions(onSearch = {
                submittedQuery = query.trim()
                focusManager.clearFocus()
            }),
            modifier = Modifier.fillMaxWidth().testTag(TestTags.SEARCH_QUERY)
        )
        if (query.isNotBlank()) {
            Text(strings.searchQueryTyped(query), modifier = Modifier.testTag(TestTags.SEARCH_QUERY_PREVIEW))
        }
        Button(
            onClick = { submittedQuery = query.trim() },
            modifier = Modifier.fillMaxWidth().testTag(TestTags.SEARCH_SUBMIT)
        ) {
            Text(strings.searchRun)
        }
        Text(
            text = if (submittedQuery.isBlank()) {
                strings.searchFeatured(results.size)
            } else {
                strings.searchResults(submittedQuery, results.size)
            },
            modifier = Modifier.testTag(TestTags.SEARCH_STATUS)
        )
        LazyColumn(
            modifier = Modifier.weight(1f).fillMaxWidth().testTag(TestTags.SEARCH_RESULTS),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(results) { item ->
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(item.name, fontWeight = FontWeight.SemiBold)
                        Text(strings.searchCategory(item.category))
                        Text(strings.searchPrice(item.price))
                    }
                }
            }
        }
    }
}

