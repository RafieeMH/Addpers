package com.mindful.android.utils

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/**
 * Stores the app language chosen in Flutter and applies it to native resources
 * (services, overlays, notifications, receivers, workers).
 */
object LocaleHelper {
    private const val PREFS_NAME = "mindful_locale_prefs"
    private const val KEY_LANGUAGE_CODE = "language_code"

    fun save(context: Context, languageCode: String) {
        if (languageCode.isEmpty()) return
        context.applicationContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LANGUAGE_CODE, languageCode)
            .apply()
    }

    fun applySavedLocale(context: Context?) {
        try {
            if (context == null) return
            val code = context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_LANGUAGE_CODE, null) ?: return
            applyLocale(context, code)
        } catch (_: Exception) {
        }
    }

    @Suppress("DEPRECATION")
    fun applyLocale(context: Context, languageCode: String) {
        if (languageCode.isEmpty()) return
        val locale = Locale(languageCode)
        Locale.setDefault(locale)

        val targets = listOf(context, context.applicationContext).distinct()
        for (ctx in targets) {
            val res = ctx.resources
            val config = Configuration(res.configuration)
            config.setLocale(locale)
            res.updateConfiguration(config, res.displayMetrics)
        }
    }
}
