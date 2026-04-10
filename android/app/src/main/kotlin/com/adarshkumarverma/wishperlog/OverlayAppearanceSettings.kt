package com.adarshkumarverma.wishperlog

import android.graphics.Color
import org.json.JSONObject

internal data class OverlayAppearanceSettings(
    val alpha: Float = 0.82f,
    val blurSigma: Float = 22.0f,
    val colorFill: String = "glass",
    val solidColor: Int = Color.parseColor("#1C1C2E"),
    val gradientStart: Int = Color.parseColor("#6366F1"),
    val gradientEnd: Int = Color.parseColor("#8B5CF6"),
    val borderStyle: String = "glow",
    val borderColor: Int = Color.parseColor("#6366F1"),
    val animation: String = "sizeGrow",
    val growScale: Float = 1.10f,
    val posX: Float = 0.88f,
    val posY: Float = 0.30f,
    val persistOnReboot: Boolean = true,
) {
    val growEnabled: Boolean
        get() = animation.equals("sizeGrow", ignoreCase = true)

    fun copyWith(
        alpha: Float? = null,
        growEnabled: Boolean? = null,
    ): OverlayAppearanceSettings {
        val nextAnimation = when (growEnabled) {
            true -> "sizeGrow"
            false -> "none"
            null -> animation
        }
        return copy(
            alpha = alpha ?: this.alpha,
            animation = nextAnimation,
        )
    }

    fun toJsonString(): String = JSONObject().apply {
        put("alpha", alpha.toDouble())
        put("blurSigma", blurSigma.toDouble())
        put("colorFill", colorFill)
        put("solidColor", solidColor)
        put("gradientStart", gradientStart)
        put("gradientEnd", gradientEnd)
        put("borderStyle", borderStyle)
        put("borderColor", borderColor)
        put("animation", animation)
        put("growScale", growScale.toDouble())
        put("posX", posX.toDouble())
        put("posY", posY.toDouble())
        put("persistOnReboot", persistOnReboot)
    }.toString()

    companion object {
        fun fromJson(raw: String?): OverlayAppearanceSettings {
            if (raw.isNullOrBlank()) return OverlayAppearanceSettings()
            return try {
                val json = JSONObject(raw)
                OverlayAppearanceSettings(
                    alpha = json.optDouble("alpha", 0.82).toFloat(),
                    blurSigma = json.optDouble("blurSigma", 22.0).toFloat(),
                    colorFill = json.optString("colorFill", "glass"),
                    solidColor = json.optInt("solidColor", Color.parseColor("#1C1C2E")),
                    gradientStart = json.optInt("gradientStart", Color.parseColor("#6366F1")),
                    gradientEnd = json.optInt("gradientEnd", Color.parseColor("#8B5CF6")),
                    borderStyle = json.optString("borderStyle", "glow"),
                    borderColor = json.optInt("borderColor", Color.parseColor("#6366F1")),
                    animation = json.optString("animation", "sizeGrow"),
                    growScale = json.optDouble("growScale", 1.10).toFloat(),
                    posX = json.optDouble("posX", 0.88).toFloat(),
                    posY = json.optDouble("posY", 0.30).toFloat(),
                    persistOnReboot = json.optBoolean("persistOnReboot", true),
                )
            } catch (_: Exception) {
                OverlayAppearanceSettings()
            }
        }

        fun legacy(alpha: Float, grow: Boolean): OverlayAppearanceSettings {
            return OverlayAppearanceSettings(
                alpha = alpha,
                animation = if (grow) "sizeGrow" else "none",
            )
        }
    }
}