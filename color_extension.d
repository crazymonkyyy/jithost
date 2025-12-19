#!/usr/bin/env dmd
module color_extension;

import arsd.color;
import std.string;
import std.algorithm;
import std.array;

/**
 * Provides color-related extensions and utilities for JitHost
 */
class ColorExtension
{
    /**
     * Converts a CSS color string to a Color struct
     */
    static Color parseColor(string colorString)
    {
        return Color.fromString(colorString);
    }
    
    /**
     * Creates a gradient between two colors
     */
    static Color[] createGradient(Color startColor, Color endColor, int steps)
    {
        Color[] gradient = new Color[steps];
        
        for (int i = 0; i < steps; i++)
        {
            double ratio = i / cast(double)(steps - 1);
            
            ubyte r = cast(ubyte)(startColor.r + (endColor.r - startColor.r) * ratio);
            ubyte g = cast(ubyte)(startColor.g + (endColor.g - startColor.g) * ratio);
            ubyte b = cast(ubyte)(startColor.b + (endColor.b - startColor.b) * ratio);
            ubyte a = cast(ubyte)(startColor.a + (endColor.a - startColor.a) * ratio);
            
            gradient[i] = Color(r, g, b, a);
        }
        
        return gradient;
    }
    
    /**
     * Adjusts the brightness of a color
     * factor > 1.0 makes it brighter, factor < 1.0 makes it darker
     */
    static Color adjustBrightness(Color color, double factor)
    {
        double r = color.r * factor;
        double g = color.g * factor;
        double b = color.b * factor;
        double a = color.a;
        
        // Clamp values to valid range
        r = r < 0 ? 0 : (r > 255 ? 255 : r);
        g = g < 0 ? 0 : (g > 255 ? 255 : g);
        b = b < 0 ? 0 : (b > 255 ? 255 : b);
        a = a < 0 ? 0 : (a > 255 ? 255 : a);
        
        return Color(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b, cast(ubyte)a);
    }
    
    /**
     * Generates a complementary color (opposite on the color wheel)
     */
    static Color getComplementaryColor(Color color)
    {
        // Simple implementation: invert RGB values
        return Color(255 - color.r, 255 - color.g, 255 - color.b, color.a);
    }
    
    /**
     * Creates a CSS string for a color (either hex or rgba format)
     */
    static string toCssString(Color color, bool forceRgba = false)
    {
        if (color.a == 255 && !forceRgba)
        {
            return color.toCssString();  // Returns hex format when alpha is 255
        }
        else
        {
            return color.toCssString();  // Returns rgba format when alpha is not 255
        }
    }
    
    /**
     * Blends two colors together with a specified ratio
     */
    static Color blendColors(Color color1, Color color2, double ratio)
    {
        // Ensure ratio is between 0 and 1
        ratio = ratio < 0.0 ? 0.0 : (ratio > 1.0 ? 1.0 : ratio);
        
        ubyte r = cast(ubyte)(color1.r * (1.0 - ratio) + color2.r * ratio);
        ubyte g = cast(ubyte)(color1.g * (1.0 - ratio) + color2.g * ratio);
        ubyte b = cast(ubyte)(color1.b * (1.0 - ratio) + color2.b * ratio);
        ubyte a = cast(ubyte)(color1.a * (1.0 - ratio) + color2.a * ratio);
        
        return Color(r, g, b, a);
    }
    
    /**
     * Generates a color palette based on a base color
     */
    static Color[] generatePalette(Color baseColor, int numColors)
    {
        Color[] palette = new Color[numColors];
        
        // Create variations by slightly adjusting hue, saturation, and brightness
        for (int i = 0; i < numColors; i++)
        {
            double brightnessFactor = 0.5 + (i * 0.5 / (numColors - 1)); // From 0.5 to 1.0
            palette[i] = adjustBrightness(baseColor, brightnessFactor);
        }
        
        return palette;
    }
    
    /**
     * Calculates the contrast ratio between two colors (for accessibility)
     */
    static double getContrastRatio(Color color1, Color color2)
    {
        double lum1 = getRelativeLuminance(color1);
        double lum2 = getRelativeLuminance(color2);
        
        // Ensure lum1 is the lighter color
        if (lum1 < lum2)
        {
            double temp = lum1;
            lum1 = lum2;
            lum2 = temp;
        }
        
        return (lum1 + 0.05) / (lum2 + 0.05);
    }
    
    /**
     * Calculates the relative luminance of a color (for contrast calculations)
     */
    private static double getRelativeLuminance(Color color)
    {
        double r = color.r / 255.0;
        double g = color.g / 255.0;
        double b = color.b / 255.0;
        
        r = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
        g = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
        b = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
    
    /**
     * Simple power function for color calculations
     */
    private static double pow(double base, double exponent)
    {
        double result = 1.0;
        int exp = cast(int)exponent;
        
        // Only handle simple cases for this example
        if (exponent == 2.4)
        {
            for (int i = 0; i < 12; i++) // Approximate 2.4 with 12 iterations of 0.2
            {
                result *= base;
            }
            return result;
        }
        
        // For now, return base^exponent for integer exponents
        for (int i = 0; i < exp; i++)
        {
            result *= base;
        }
        
        return result;
    }
}

unittest
{
    // Test color parsing
    Color red = ColorExtension.parseColor("red");
    Color blue = ColorExtension.parseColor("#0000ff");
    Color green = ColorExtension.parseColor("rgb(0,255,0)");
    
    assert(red.r == 255 && red.g == 0 && red.b == 0);
    assert(blue.r == 0 && blue.g == 0 && blue.b == 255);
    assert(green.r == 0 && green.g == 255 && green.b == 0);
    
    // Test gradient creation
    Color[] gradient = ColorExtension.createGradient(red, blue, 3);
    assert(gradient.length == 3);
    assert(gradient[0].r == 255);  // Start with red
    assert(gradient[2].b == 255);  // End with blue
    
    // Test brightness adjustment
    Color darkRed = ColorExtension.adjustBrightness(red, 0.5);
    assert(darkRed.r == 127);  // Half brightness red
    
    // Test complementary color
    Color compColor = ColorExtension.getComplementaryColor(red);
    assert(compColor.r == 0 && compColor.g == 255 && compColor.b == 255);  // Cyan
    
    // Test color blending
    Color blended = ColorExtension.blendColors(red, blue, 0.5);
    assert(blended.r == 127 && blended.b == 127);  // Should be purple-ish
    
    // Test palette generation
    Color[] palette = ColorExtension.generatePalette(red, 5);
    assert(palette.length == 5);
    
    // Test contrast ratio
    double contrast = ColorExtension.getContrastRatio(red, blue);
    assert(contrast > 3.0);  // Red and blue should have good contrast
}