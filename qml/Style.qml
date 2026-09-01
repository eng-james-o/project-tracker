pragma Singleton
import QtQuick

QtObject {
    property bool isDarkMode: false

    property color primary: isDarkMode ? "#8AB4F8" : "#1A73E8"
    property color primaryHover: isDarkMode ? "#AECBFA" : "#1765CC"
    property color primaryPressed: isDarkMode ? "#669DF6" : "#1557B0"
    
    property color secondary: isDarkMode ? "#3C4043" : "#F1F3F4"
    property color secondaryHover: isDarkMode ? "#5F6368" : "#E2E4E7"
    property color secondaryPressed: isDarkMode ? "#202124" : "#D0D0D0"
    property color secondaryBorder: isDarkMode ? "#5F6368" : "#DADCE0"
    
    property color background: isDarkMode ? "#202124" : "#F8F9FA"
    property color surface: isDarkMode ? "#292A2D" : "#FFFFFF"
    
    property color textMain: isDarkMode ? "#E8EAED" : "#202124"
    property color textSecondary: isDarkMode ? "#9AA0A6" : "#5F6368"
    property color textLight: isDarkMode ? "#80868B" : "#70757A"
    
    property color danger: isDarkMode ? "#F28B82" : "#EA4335"
    property color dangerHover: isDarkMode ? "#F6AEA9" : "#D93025"
    property color dangerPressed: isDarkMode ? "#EE675C" : "#B31412"

    property color ghostHover: isDarkMode ? "#3C4043" : "#F1F3F4"
    property color ghostPressed: isDarkMode ? "#5F6368" : "#E8EAED"

    property color iconHover: isDarkMode ? "#3C4043" : "#E8F0FE"
    property color iconPressed: isDarkMode ? "#5F6368" : "#D2E3FC"

    property color border: isDarkMode ? "#5F6368" : "#E0E0E0"

    property int radiusSmall: 4
    property int radiusMedium: 6
    property int radiusLarge: 8
    property int radiusXLarge: 10
}
