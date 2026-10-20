import QtQuick
import QtQuick.Controls

// Singleton for handling clipboard operations
QtObject {
    id: clipboardHandler
    
    // Check if clipboard contains text that looks like a URL
    function isClipboardTextAUrl(): bool {
        if (typeof clipboardController === "undefined") {
            return false
        }
        var text = clipboardController.get_clipboard_text()
        
        if (!text || text.length === 0) {
            return false
        }
        
        // Simple URL detection regex
        var urlRegex = /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
        
        // Also check for URLs without protocol
        var simpleUrlRegex = /^(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
        
        return urlRegex.test(text) || simpleUrlRegex.test(text)
    }
    
    // Get clipboard text
    function getClipboardText(): string {
        if (typeof clipboardController === "undefined") {
            return ""
        }
        return clipboardController.get_clipboard_text()
    }
    
    // Check if clipboard has text
    function hasText(): bool {
        if (typeof clipboardController === "undefined") {
            return false
        }
        return clipboardController.has_text()
    }
    
    // Check if text is a valid URL
    function isValidUrl(text: string): bool {
        if (!text || text.length === 0) {
            return false
        }
        
        var urlRegex = /^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
        var simpleUrlRegex = /^(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/
        
        return urlRegex.test(text) || simpleUrlRegex.test(text)
    }
    
    // Format URL with protocol if missing
    function formatUrl(text: string): string {
        if (!text) return text
        
        // Add https:// if missing
        if (!text.startsWith("http://") && !text.startsWith("https://") && !text.startsWith("ftp://")) {
            if (text.startsWith("www.")) {
                return "https://" + text
            } else if (text.includes(".")) {
                return "https://" + text
            }
        }
        return text
    }
}
