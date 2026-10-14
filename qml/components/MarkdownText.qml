import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Simple markdown renderer component
// Supports: # headers, **bold**, *italic*, `code`, - lists, > blockquotes
Text {
    id: root
    property string markdown: ""
    property color textColor: "#202124"
    property int fontSize: 13
    
    // This is a simplified markdown renderer
    // For full markdown support, consider using a proper markdown library
    text: root.parseMarkdown(root.markdown)
    color: root.textColor
    font.pixelSize: root.fontSize
    wrapMode: Text.Wrap
    
    function parseMarkdown(md) {
        if (!md) return ""
        
        // Simple replacements for basic markdown
        var result = md
        
        // Headers
        result = result.replace(/^#\s+(.*$)/gm, function(match, p1) {
            return "\n" + p1.toUpperCase() + "\n"
        })
        result = result.replace(/^##\s+(.*$)/gm, function(match, p1) {
            return "\n**" + p1 + "**\n"
        })
        result = result.replace(/^###\s+(.*$)/gm, function(match, p1) {
            return "\n*" + p1 + "*\n"
        })
        
        // Bold
        result = result.replace(/\*\*(.*?)\*\*/g, function(match, p1) {
            return "<b>" + p1 + "</b>"
        })
        
        // Italic
        result = result.replace(/\*(.*?)\*/g, function(match, p1) {
            return "<i>" + p1 + "</i>"
        })
        
        // Code blocks
        result = result.replace(/`(.*?)`/g, function(match, p1) {
            return "<code>" + p1 + "</code>"
        })
        
        // Lists
        result = result.replace(/^\s*-\s+(.*)/gm, function(match, p1) {
            return "  • " + p1
        })
        
        // Blockquotes
        result = result.replace(/^>\s+(.*)/gm, function(match, p1) {
            return "    " + p1
        })
        
        // Links
        result = result.replace(/\[(.*?)\]\((.*?)\)/g, function(match, p1, p2) {
            return p1 + " (" + p2 + ")"
        })
        
        // Horizontal rule
        result = result.replace(/^---/gm, "\n────────────────────────────\n")
        
        return result
    }
}
