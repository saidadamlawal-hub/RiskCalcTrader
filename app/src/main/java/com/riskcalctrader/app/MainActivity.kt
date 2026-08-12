package com.riskcalctrader.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = darkColorScheme()) {
                Surface(modifier = Modifier.fillMaxSize().background(Color.Black)) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("RiskCalc Trader", style = MaterialTheme.typography.headlineMedium)
                        Spacer(modifier = Modifier.height(20.dp))
                        
                        var balance by remember { mutableStateOf("") }
                        OutlinedTextField(
                            value = balance,
                            onValueChange = { balance = it },
                            label = { Text("Account Balance ($)") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        
                        Button(onClick = { /* Logic here */ }, modifier = Modifier.fillMaxWidth().padding(top = 16.dp)) {
                            Text("Calculate Risk")
                        }
                    }
                }
            }
        }
    }
}
