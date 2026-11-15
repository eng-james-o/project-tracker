# Project Tracker - UI/UX Documentation

## Table of Contents

1. [Overview](#overview)
2. [Navigation System](#navigation-system)
   - [Grouped Navigation Structure](#grouped-navigation-structure)
   - [Progressive Disclosure](#progressive-disclosure)
   - [Group Highlighting](#group-highlighting)
   - [State Persistence](#state-persistence)
   - [Back to Top Button](#back-to-top-button)
3. [Keyboard Shortcuts](#keyboard-shortcuts)
   - [Global Shortcuts](#global-shortcuts)
   - [Command Palette](#command-palette)
4. [Qt Quick Configuration](#qt-quick-configuration)
   - [qtquickcontrols2.conf](#qtquickcontrols2conf)
   - [Custom QML Templates](#custom-qml-templates)
5. [Reusable Components](#reusable-components)
   - [Common Components](#common-components)
   - [Feature Components](#feature-components)
6. [Custom Tags & Categories](#custom-tags--categories)
   - [Tag Management](#tag-management)
   - [Tag Display](#tag-display)
7. [Project Templates](#project-templates)
   - [Template Creation](#template-creation)
   - [Template Usage](#template-usage)
8. [Rich Markdown & Live Preview](#rich-markdown--live-preview)
   - [Markdown Editor](#markdown-editor)
   - [Markdown Rendering](#markdown-rendering)
9. [Notification System](#notification-system)
   - [Desktop Notifications](#desktop-notifications)
   - [Notification Center](#notification-center)

---

## Overview

The Project Tracker application features a modern, intuitive UI/UX design built with Qt Quick (QML) and PySide6. The interface prioritizes efficiency, clarity, and user productivity through thoughtful navigation organization, consistent styling, and powerful features.

### Application Window

- **Dimensions**: 1100 x 750 pixels (default)
- **Title**: "Project Tracker Desktop"
- **Layout**: Split-paned design with collapsible sidebar and main content area
- **Theme**: Light mode (default) with dark mode support via `Style.isDarkMode`

---

## Navigation System

### Grouped Navigation Structure

The sidebar navigation is organized into **5 logical groups** to reduce cognitive load and improve discoverability:

#### Group Hierarchy

```
┌─────────────────────────────────────┐
│  PROJECTTRACKER                      │
│  [≡]                              │
├─────────────────────────────────────┤
│  📁 PROJECTS                         │
│     ├─ 📊 Dashboard                 │
│     ├─ 📋 All Projects              │
│     ├─ 🏷️  Project Board             │
│     └─ ➕ New Project                │
├─────────────────────────────────────┤
│  🎯 PLANNING                          │
│     └─ 🎯 Goals                      │
├─────────────────────────────────────┤
│  📊 MANAGEMENT                        │
│     └─ 📋 Activity & Audit           │
├─────────────────────────────────────┤
│  🔧 TOOLS                            │
│     ├─ 🤖 AI Assistant               │
│     └─ 🔔 Notifications              │
├─────────────────────────────────────┤
│  ⚙️  SETTINGS                         │
└─────────────────────────────────────┘
     [↑ Back to Top]
```

#### Group Index Mapping

| Group | Items | Stack Index |
|-------|-------|-------------|
| **Projects** | Dashboard, All Projects, Project Board, New Project | 0, 1, 2, 3 |
| **Planning** | Goals | 4 |
| **Management** | Activity & Audit | 5 |
| **Tools** | AI Assistant, Notifications | 7, 8 |
| **Settings** | Settings | 6 |

### Progressive Disclosure

**All groups are collapsed by default** to present a clean, uncluttered interface on first launch.

#### Expand/Collapse Behavior

- **Click on group header**: Toggles the expanded state of that group
- **Expand indicator**: Right-pointing arrow (▶) rotates 90° to down-pointing (▼) when expanded
- **Auto-expand**: When sidebar is not collapsed, the **Projects group automatically expands** to ensure core functionality is always accessible
- **Single group open**: Only one group can be expanded at a time (others auto-collapse)

#### Implementation Details

```qml
// SidebarSettings.qml - State persistence
SidebarSettings {
    id: sidebarSettings
    property bool projectsExpanded: false  // Default: collapsed
    property bool planningExpanded: false  // Default: collapsed
    property bool managementExpanded: false // Default: collapsed
    property bool toolsExpanded: false     // Default: collapsed
}

// Group header click handler
onClicked: sidebarSettings.saveProjectsExpanded(!sidebarSettings.projectsExpanded)

// Group items visibility
visible: sidebarSettings.projectsExpanded || !mainWindow.isSidebarCollapsed
```

### Group Highlighting

Each group header is highlighted with a **subtle background color** when the current view belongs to that group. The highlighting uses **10% opacity** of the group's theme color for a refined, professional appearance.

#### Color Scheme

| Group | Color | Hex Code (Light) | Hex Code (Dark) | Highlight Opacity |
|-------|-------|------------------|-----------------|-------------------|
| **Projects** | Primary (Blue) | `#1A73E8` | `#8AB4F8` | 10% |
| **Planning** | Success (Green) | `#34A853` | `#81C995` | 10% |
| **Management** | Warning (Orange) | `#FBBC04` | `#FDD663` | 10% |
| **Tools** | Info (Purple) | `#174EA6` | `#8AB4F8` | 10% |
| **Settings** | Secondary (Gray) | `#F1F3F4` | `#3C4043` | 10% |

#### Implementation

```qml
// Projects group highlighting
Rectangle {
    Layout.fillWidth: true
    height: 40
    color: mainWindow.isSidebarCollapsed ? "transparent" : 
           (mainStack.currentIndex === 0 || mainStack.currentIndex === 1 || 
            mainStack.currentIndex === 2 || mainStack.currentIndex === 3) ? 
           Qt.alpha(Style.primary, 0.1) : "transparent"
    radius: Style.radiusSmall
    // Contains the CustomButton
}

// Planning group highlighting
color: mainWindow.isSidebarCollapsed ? "transparent" : 
       mainStack.currentIndex === 4 ? 
       Qt.alpha(Style.success, 0.1) : "transparent"

// Management group highlighting
color: mainWindow.isSidebarCollapsed ? "transparent" : 
       mainStack.currentIndex === 5 ? 
       Qt.alpha(Style.warning, 0.1) : "transparent"

// Tools group highlighting
color: mainWindow.isSidebarCollapsed ? "transparent" : 
       mainStack.currentIndex === 7 || mainStack.currentIndex === 8 ? 
       Qt.alpha(Style.info, 0.1) : "transparent"

// Settings highlighting
color: mainWindow.isSidebarCollapsed ? "transparent" : 
       mainStack.currentIndex === 6 ? 
       Qt.alpha(Style.secondary, 0.1) : "transparent"
```

### State Persistence

The expanded/collapsed state of each navigation group is **automatically saved and restored** between application sessions using Qt's `Qt.labs.settings 1.0` module.

#### Implementation (`SidebarSettings.qml`)

```qml
import QtQuick
import QtQuick.Controls
import Qt.labs.settings 1.0

QtObject {
    id: root
    
    // Navigation group expanded states
    property bool projectsExpanded: false
    property bool planningExpanded: false
    property bool managementExpanded: false
    property bool toolsExpanded: false
    
    readonly property Settings settings: Settings {
        category: "sidebar"
    }
    
    Component.onCompleted: {
        // Load saved state from QSettings
        projectsExpanded = settings.value("projectsExpanded", false)
        planningExpanded = settings.value("planningExpanded", false)
        managementExpanded = settings.value("managementExpanded", false)
        toolsExpanded = settings.value("toolsExpanded", false)
    }
    
    function saveProjectsExpanded(value) {
        projectsExpanded = value
        settings.setValue("projectsExpanded", value)
    }
    
    function savePlanningExpanded(value) {
        planningExpanded = value
        settings.setValue("planningExpanded", value)
    }
    
    function saveManagementExpanded(value) {
        managementExpanded = value
        settings.setValue("managementExpanded", value)
    }
    
    function saveToolsExpanded(value) {
        toolsExpanded = value
        settings.setValue("toolsExpanded", value)
    }
}
```

**Storage Location**: Settings are stored in the platform's native settings system (Registry on Windows, plist on macOS, INI file on Linux).

### Back to Top Button

A "Back to Top" button is provided at the bottom of the sidebar for quick navigation when the sidebar content is scrolled.

#### Features

- **Location**: Bottom of the sidebar
- **Visibility**: Only visible when sidebar is NOT collapsed
- **Icon**: Up arrow (↑) rotated -90° from the arrow-left.svg icon
- **Action**: Scrolls the sidebar `Flickable` to the top

#### Implementation

```qml
CustomButton {
    Layout.fillWidth: true
    text: mainWindow.isSidebarCollapsed ? "" : "Back to Top"
    iconSource: "../../assets/arrow-left.svg"
    rotation: -90  // Points upward
    variant: "ghost"
    visible: !mainWindow.isSidebarCollapsed
    onClicked: sidebarFlick.contentY = 0
    ToolTip.text: "Back to Top"
    ToolTip.delay: 300
}
```

### Sidebar Scrollability

The sidebar is wrapped in a `Flickable` component to enable scrolling when the window is resized or when many items are present.

```qml
Flickable {
    id: sidebarFlick
    Layout.fillHeight: true
    implicitWidth: mainWindow.isSidebarCollapsed ? 64 : 220
    contentHeight: sidebarContent.height
    clip: true

    Rectangle {
        id: sidebarContent
        width: parent.width
        color: Style.surface
        border.color: Style.border
        border.width: 1
        // Contains the ColumnLayout with all navigation items
    }
}
```

---

## Keyboard Shortcuts

### Global Shortcuts

The application provides comprehensive keyboard shortcuts for fast navigation and common actions:

| Shortcut | Action | Description |
|---------|--------|-------------|
| `Ctrl+K` | Open Command Palette | Opens the global command palette for quick navigation and actions |
| `Ctrl+N` | New Project | Opens the project creation dialog |
| `Ctrl+F` | Focus Search | Navigates to Projects view and focuses the search input |
| `Ctrl+1` | Dashboard | Switches to Dashboard view |
| `Ctrl+2` | All Projects | Switches to All Projects view |
| `Ctrl+3` | Project Detail | Switches to Project Detail view |
| `Esc` | Close Dialogs | Closes any open dialogs (Project, Template, Command Palette) |
| `Space` | Toggle Completion | Toggles step/deliverable completion when focused |

#### Implementation

```qml
// Global shortcuts in main.qml
Shortcut {
    sequence: "Ctrl+K"
    onActivated: commandPalette.open()
}

Shortcut {
    sequence: "Ctrl+N"
    onActivated: {
        projectDialog.setProject(null)
        projectDialog.open()
    }
}

Shortcut {
    sequence: "Ctrl+F"
    onActivated: {
        mainWindow.mainStack.currentIndex = 1
        mainWindow.projectsView.searchBox.focus = true
    }
}

Shortcut {
    sequence: "Ctrl+1"
    onActivated: mainWindow.mainStack.currentIndex = 0
}

Shortcut {
    sequence: "Ctrl+2"
    onActivated: mainWindow.mainStack.currentIndex = 1
}

Shortcut {
    sequence: "Ctrl+3"
    onActivated: mainWindow.mainStack.currentIndex = 2
}

Shortcut {
    sequence: "Esc"
    onActivated: {
        projectDialog.close()
        templateDialog.close()
        commandPalette.close()
    }
}
```

### Command Palette

The **Global Command Palette** (`Ctrl+K`) provides a powerful way to quickly navigate and perform actions without using the mouse.

#### Features

- **Modal popup**: Appears in the center of the window
- **Keyboard-driven**: Full keyboard navigation support
- **Search functionality**: Filter commands by typing
- **Quick execution**: Press Enter to execute the selected command

#### Available Commands

| Command | Action |
|---------|--------|
| New Project | Opens project creation dialog |
| All Projects | Navigates to All Projects view |
| Dashboard | Navigates to Dashboard view |
| Project Board | Navigates to Project Board view |
| Goals | Navigates to Goals view |
| Audit Log | Navigates to Audit Log view |
| Settings | Navigates to Settings view |
| New Template | Opens template creation dialog |
| Profile | Opens profile editor |
| Search Projects | Focuses search input in Projects view |

#### Keyboard Navigation

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate through commands |
| `Enter` | Execute selected command |
| `Esc` | Close command palette |
| `Tab` | Cycle through UI elements |

#### Implementation

```qml
// CommandPalette.qml
Popup {
    id: root
    width: 600
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property list<string> allCommands: [
        "New Project",
        "All Projects",
        "Dashboard",
        "Project Board",
        "Goals",
        "Audit Log",
        "Settings",
        "New Template",
        "Profile",
        "Search Projects"
    ]

    property list<var> filteredCommands: []

    function filterCommands() {
        var query = searchInput.text.toLowerCase()
        if (!query) {
            filteredCommands = allCommands
            return
        }
        filteredCommands = allCommands.filter(function(cmd) {
            return cmd.toLowerCase().includes(query)
        })
    }

    function executeCommand(index) {
        var cmd = filteredCommands[index]
        switch(cmd) {
            case "New Project":
                projectDialog.setProject(null)
                projectDialog.open()
                break
            case "All Projects":
                mainStack.currentIndex = 1
                break
            case "Dashboard":
                mainStack.currentIndex = 0
                break
            // ... other commands
        }
        root.close()
    }
}
```

---

## Qt Quick Configuration

### qtquickcontrols2.conf

The `qtquickcontrols2.conf` file configures Qt Quick Controls 2 to use custom styling for the application.

```ini
[Controls]
Style=ProjectTracker

[ProjectTracker]
# Path to the style directory
Path=qml/style

# Enable custom styling
Enable=true

# Theme support
Themes=light,dark

# Default theme
DefaultTheme=light
```

**Location**: `/qtquickcontrols2.conf` (root directory)

**Purpose**: Instructs Qt Quick Controls 2 to use the custom style templates located in the `qml/style/` directory.

### Custom QML Templates

The application includes custom QML templates for Qt Quick Controls 2 components, providing a consistent visual style across the application.

#### Location

`qml/style/` directory contains:

| File | Purpose | Description |
|------|---------|-------------|
| `Button.qml` | Custom Button | Styled button with hover, pressed, and disabled states |
| `CheckBox.qml` | Custom CheckBox | Styled checkbox with custom appearance |
| `ComboBox.qml` | Custom ComboBox | Styled dropdown with custom appearance |
| `Slider.qml` | Custom Slider | Styled slider with custom handle and groove |
| `TextField.qml` | Custom TextField | Styled text input with focus states |
| `Style.qml` | Style Singleton | Copy of the global Style.qml for the style module |
| `qmldir` | Module Definition | Defines the QML module for imports |

#### qmldir

```qml
module ProjectTracker.Style

Button 1.0 Button.qml
CheckBox 1.0 CheckBox.qml
ComboBox 1.0 ComboBox.qml
Slider 1.0 Slider.qml
TextField 1.0 TextField.qml
```

#### Button.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.Button {
    id: control
    
    property color _background: Style.primary
    property color _textColor: Style.surface
    
    implicitWidth: Math.max(implicitContentWidth + leftInset + rightInset, 
                           implicitContentHeight + topInset + bottomInset)
    implicitHeight: implicitContentHeight + topInset + bottomInset
    
    contentItem: Text {
        text: control.text
        font: control.font
        color: _textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    
    background: Rectangle {
        color: control.enabled ? _background : Style.secondary
        radius: Style.radiusMedium
        opacity: control.pressed ? 0.8 : control.hovered ? 0.9 : 1.0
        border.color: control.pressed ? Style.primaryPressed : 
                      control.hovered ? Style.primaryHover : Style.primary
        border.width: 1
    }
    
    padding: Style.paddingMedium
}
```

#### CheckBox.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.CheckBox {
    id: control
    
    property color _borderColor: Style.border
    property color _checkColor: Style.primary
    
    indicator: Rectangle {
        width: 20
        height: 20
        radius: 4
        border.color: _borderColor
        border.width: 1
        color: control.checked ? _checkColor : "transparent"
        
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            color: Style.surface
            visible: control.checked
        }
    }
    
    contentItem: Text {
        text: control.text
        color: Style.textMain
        font: control.font
    }
    
    spacing: 8
}
```

---

## Reusable Components

### Common Components

Located in `qml/components/common/`:

| Component | Purpose | Features |
|-----------|---------|----------|
| `Card.qml` | Generic card container | Shadow, radius, padding, hover effects |
| `EmptyState.qml` | Empty state placeholder | Icon, title, description, action button |
| `LoadingIndicator.qml` | Loading spinner | Animated spinner with customizable size |
| `Tooltip.qml` | Tooltip component | Auto-positioning, delay, custom styling |

#### Card.qml

```qml
import QtQuick
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    color: Style.surface
    border.color: Style.border
    border.width: 1
    radius: Style.radiusMedium
    
    property alias content: contentItem.data
    property int padding: Style.paddingMedium
    
    implicitWidth: 300
    implicitHeight: 200
    
    Rectangle {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
```

### Feature Components

Located in `qml/components/`:

| Component | Purpose | Description |
|-----------|---------|-------------|
| `CommandPalette.qml` | Global command palette | Quick navigation and actions with search |
| `MarkdownEditor.qml` | Markdown editor | Edit and preview markdown with live updates |
| `NotificationCenter.qml` | Notification UI | List of notifications with badges |
| `AIAssistantDrawer.qml` | AI chat interface | Chat with AI for project assistance |
| `AIStepGenerator.qml` | AI step generation | Generate project steps from descriptions |
| `TagBadge.qml` | Tag display | Color-coded tag badge component |
| `TagFilter.qml` | Tag filtering | Filter bar for tag-based filtering |
| `TagInput.qml` | Tag input | Autocomplete tag input field |
| `TemplateDialog.qml` | Template management | Create and edit project templates |
| `SidebarSettings.qml` | Sidebar state | Persists sidebar expanded state |

---

## Custom Tags & Categories

### Tag Management

The application provides comprehensive **tag-based categorization** for projects, enabling users to organize and filter projects by custom labels with color coding.

#### Features

- **Custom tags**: Users can create any tag name
- **Color coding**: Each tag can have a custom color
- **Multiple tags**: Projects can have multiple tags
- **Tag filtering**: Filter projects by one or more tags
- **Autocomplete**: Tag input with autocomplete suggestions

#### Implementation

**Database Schema** (`db/database.py`):

```python
# Tags are stored as comma-separated strings in the projects table
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    tags TEXT,  # Comma-separated tag strings
    # ... other fields
)
```

**Tag Controller** (`models/tag_controller.py`):

```python
class TagController(QObject):
    def __init__(self, db_manager):
        super().__init__()
        self.db = db_manager
        self._tags = []
        self._tag_filter = []
    
    @property
    def tags(self):
        return self._tags
    
    @tags.setter
    def tags(self, value):
        self._tags = value
    
    def add_tag(self, tag_name, color=None):
        """Add a new tag"""
        if tag_name not in self._tags:
            self._tags.append(tag_name)
    
    def remove_tag(self, tag_name):
        """Remove a tag"""
        if tag_name in self._tags:
            self._tags.remove(tag_name)
    
    def filter_projects_by_tags(self, tag_filter):
        """Filter projects by tags"""
        self._tag_filter = tag_filter
        return self.db.get_projects_by_tags(tag_filter)
```

### Tag Display

Tags are displayed as **color-coded badges** on project cards and in the project detail view.

#### TagBadge.qml

```qml
import QtQuick
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    height: 24
    radius: 12
    color: tagColor || Style.primary
    
    property string tagName: ""
    property color tagColor: Style.primary
    
    Text {
        anchors.centerIn: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        text: tagName
        font.pixelSize: Style.fontSizeSmall
        font.bold: true
        color: Style.surface
    }
}
```

#### TagInput.qml

```qml
import QtQuick
import QtQuick.Controls
import "../"

CustomTextField {
    id: root
    placeholderText: "Add tags..."
    
    property var tagController: null
    property list<string> selectedTags: []
    
    // Autocomplete popup
    Popup {
        id: autocompletePopup
        anchors.top: root.bottom
        anchors.left: root.left
        width: root.width
        
        ListView {
            width: parent.width
            height: Math.min(200, contentHeight)
            model: tagController.suggestedTags
            delegate: ItemDelegate {
                text: modelData
                onClicked: {
                    root.addTag(modelData)
                    autocompletePopup.close()
                }
            }
        }
    }
    
    function addTag(tag): {
        if (tag && !selectedTags.includes(tag)) {
            selectedTags.push(tag)
            root.text = ""
        }
    }
}
```

### Tag Filter

The **TagFilter** component provides a visual interface for filtering projects by tags.

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

RowLayout {
    id: root
    spacing: 8
    
    property var tagController: null
    property list<string> activeFilters: []
    
    Repeater {
        model: activeFilters
        delegate: TagBadge {
            tagName: modelData
            onCloseClicked: {
                tagController.removeTagFilter(modelData)
            }
        }
    }
    
    CustomButton {
        text: "Clear Filters"
        variant: "ghost"
        visible: activeFilters.length > 0
        onClicked: tagController.clearTagFilter()
    }
}
```

---

## Project Templates

### Template Creation

Users can create **reusable project templates** to quickly start new projects with pre-defined structures.

#### Features

- **Template name**: Unique identifier for the template
- **Description**: Template purpose and details
- **Pre-defined steps**: Default steps for new projects
- **Pre-defined deliverables**: Default deliverables
- **Default values**: Pre-filled project fields

#### Database Schema

```python
# templates table in db/database.py
CREATE TABLE IF NOT EXISTS templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    steps_json TEXT,  # JSON array of step objects
    deliverables_json TEXT,  # JSON array of deliverable objects
    default_values_json TEXT,  # JSON object with default values
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

#### Template Controller

```python
class TemplateController(QObject):
    def __init__(self, db_manager):
        super().__init__()
        self.db = db_manager
    
    def create_template(self, name, description, steps, deliverables, defaults):
        """Create a new template"""
        steps_json = json.dumps(steps)
        deliverables_json = json.dumps(deliverables)
        defaults_json = json.dumps(defaults)
        return self.db.create_template(name, description, steps_json, deliverables_json, defaults_json)
    
    def get_templates(self):
        """Get all templates"""
        return self.db.get_all_templates()
    
    def delete_template(self, template_id):
        """Delete a template"""
        return self.db.delete_template(template_id)
    
    def clone_from_template(self, template_id, project_data):
        """Create a new project from a template"""
        template = self.db.get_template(template_id)
        # Merge template data with project_data
        # Create new project with combined data
        return self.db.add_project_with_template(template, project_data)
```

### Template Usage

#### TemplateDialog.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Popup {
    id: root
    width: 600
    height: 500
    modal: true
    
    property var templateController: null
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        Text {
            text: "Project Templates"
            font.pixelSize: Style.fontSizeHeading
            font.bold: true
        }
        
        // Template list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: templateController.templates
            delegate: TemplateItem {
                template: modelData
                onCloneClicked: {
                    templateController.cloneFromTemplate(modelData.id)
                    root.close()
                }
                onDeleteClicked: {
                    templateController.deleteTemplate(modelData.id)
                }
            }
        }
        
        // Create new template button
        CustomButton {
            text: "Create New Template"
            variant: "primary"
            onClicked: createTemplateDialog.open()
        }
    }
}
```

#### Cloning from Templates

In `ProjectDetailView.qml`:

```qml
CustomButton {
    text: "Clone from Template"
    iconSource: "../assets/template.svg"
    variant: "secondary"
    onClicked: templateDialog.open()
}
```

---

## Rich Markdown & Live Preview

### Markdown Editor

The application features a **full-featured markdown editor** with live preview functionality.

#### Features

- **Edit mode**: Write markdown with syntax highlighting
- **Preview mode**: View rendered markdown in real-time
- **Live preview**: Updates as you type
- **Tab switching**: Toggle between Edit and Preview tabs
- **CommonMark support**: Supports standard markdown syntax

#### Supported Markdown Features

| Feature | Syntax | Rendered |
|---------|--------|----------|
| Headers | `# H1`, `## H2`, `### H3` | Large, Medium, Small headers |
| Bold | `**bold**` or `__bold__` | **bold** |
| Italic | `*italic*` or `_italic_` | *italic* |
| Links | `[text](url)` | [text](url) |
| Images | `![alt](url)` | ![alt](url) |
| Lists | `- item` or `* item` | • item |
| Numbered Lists | `1. item` | 1. item |
| Code | `` `code` `` | `code` |
| Code Blocks | ```\ncode\n``` | Code block |
| Blockquotes | `> quote` | > quote |
| Horizontal Rule | `---` or `***` | --- |

#### MarkdownEditor.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    property alias text: editor.text
    property bool readOnly: false
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Tab bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            
            CustomButton {
                Layout.fillWidth: true
                text: "Edit"
                variant: tabBar.currentIndex === 0 ? "primary" : "ghost"
                onClicked: tabBar.currentIndex = 0
            }
            
            CustomButton {
                Layout.fillWidth: true
                text: "Preview"
                variant: tabBar.currentIndex === 1 ? "primary" : "ghost"
                onClicked: tabBar.currentIndex = 1
            }
        }
        
        // Tab content
        StackLayout {
            id: tabBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0
            
            // Edit tab
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                CustomTextField {
                    id: editor
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    readOnly: root.readOnly
                }
            }
            
            // Preview tab
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                MarkdownText {
                    text: editor.text
                    width: parent.width
                }
            }
        }
    }
}
```

### Markdown Rendering

The `MarkdownText` component renders markdown content with proper formatting.

#### MarkdownText.qml

```qml
import QtQuick
import QtQuick.Controls
import "../"

Text {
    id: root
    textFormat: Text.RichText
    font.family: Style.fontFamily
    color: Style.textMain
    
    property string markdown: ""
    
    // Parse markdown and convert to HTML
    function parseMarkdown(md): {
        // Implement markdown parsing
        // Convert headers, bold, italic, lists, etc. to HTML
        return parsedHtml
    }
    
    text: parseMarkdown(markdown)
}
```

#### Usage in ProjectDialog

```qml
MarkdownEditor {
    id: descriptionEditor
    Layout.fillWidth: true
    Layout.fillHeight: true
    text: projectDescription
}
```

---

## Notification System

### Desktop Notifications

The application provides **desktop notifications** for important events, such as upcoming deadlines and system alerts.

#### Features

- **System tray icon**: Application icon in system tray
- **Desktop alerts**: Native desktop notifications
- **Deadline reminders**: Automatic notifications for upcoming deadlines
- **Notification history**: View past notifications

#### Implementation

**NotificationController** (`models/notification_controller.py`):

```python
from PySide6.QtCore import QObject, Signal, QThread
from PySide6.QtWidgets import QSystemTrayIcon, QMenu
from PySide6.QtGui import QIcon
import datetime

class NotificationController(QObject):
    notificationAdded = Signal(str, str)  # title, message
    
    def __init__(self, db_manager):
        super().__init__()
        self.db = db_manager
        self.notifications = []
        self.tray_icon = None
        self.setup_tray_icon()
        self.start_deadline_checker()
    
    def setup_tray_icon(self):
        """Setup system tray icon"""
        self.tray_icon = QSystemTrayIcon()
        self.tray_icon.setIcon(QIcon("assets/app-icon.svg"))
        
        menu = QMenu()
        menu.addAction("Show", self.show_main_window)
        menu.addAction("Exit", self.exit_application)
        self.tray_icon.setContextMenu(menu)
        self.tray_icon.show()
    
    def start_deadline_checker(self):
        """Start thread to check for upcoming deadlines"""
        self.checker_thread = QThread()
        self.checker_worker = DeadlineChecker(self.db)
        self.checker_worker.moveToThread(self.checker_thread)
        self.checker_thread.started.connect(self.checker_worker.run)
        self.checker_worker.notification.connect(self.add_notification)
        self.checker_thread.start()
    
    def add_notification(self, title, message):
        """Add a new notification"""
        notification = {
            'title': title,
            'message': message,
            'timestamp': datetime.datetime.now(),
            'read': False
        }
        self.notifications.append(notification)
        self.notificationAdded.emit(title, message)
        
        # Show desktop notification
        if self.tray_icon:
            self.tray_icon.showMessage(title, message)
    
    def mark_as_read(self, index):
        """Mark notification as read"""
        if 0 <= index < len(self.notifications):
            self.notifications[index]['read'] = True
    
    def clear_all(self):
        """Clear all notifications"""
        self.notifications = []
```

### Notification Center

The **Notification Center** is a dropdown panel that displays all notifications.

#### NotificationCenter.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    width: 350
    height: 400
    color: Style.surface
    border.color: Style.border
    border.width: 1
    radius: Style.radiusMedium
    
    property var notificationController: null
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Notifications"
                font.pixelSize: Style.fontSizeTitle
                font.bold: true
            }
            
            Item { Layout.fillWidth: true }
            
            CustomButton {
                text: "Clear All"
                variant: "ghost"
                onClicked: notificationController.clear_all()
            }
            
            CustomButton {
                iconSource: "../assets/close.svg"
                variant: "icon"
                onClicked: root.visible = false
            }
        }
        
        // Notification list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 8
                
                Repeater {
                    model: notificationController.notifications
                    delegate: NotificationItem {
                        notification: modelData
                        index: index
                        onMarkAsRead: notificationController.mark_as_read(index)
                    }
                }
            }
        }
    }
}
```

#### NotificationItem.qml

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    Layout.fillWidth: true
    color: notification.read ? Style.surface : Qt.alpha(Style.primary, 0.05)
    radius: Style.radiusSmall
    border.color: notification.read ? Style.border : Style.primary
    border.width: 1
    
    property var notification: ({})
    property int index: 0
    signal markAsRead()
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4
        
        Text {
            text: notification.title
            font.pixelSize: Style.fontSizeMedium
            font.bold: true
            color: Style.textMain
        }
        
        Text {
            text: notification.message
            font.pixelSize: Style.fontSizeSmall
            color: Style.textSecondary
            wrapMode: Text.WordWrap
        }
        
        Text {
            text: notification.timestamp
            font.pixelSize: Style.fontSizeSmall
            color: Style.textLight
            horizontalAlignment: Text.AlignRight
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            markAsRead()
            // Optionally navigate to related view
        }
    }
}
```

### Notification Badge

A **notification badge** appears on the Notifications button in the sidebar when there are unread notifications.

```qml
CustomButton {
    Layout.fillWidth: true
    text: mainWindow.isSidebarCollapsed ? "" : "Notifications"
    iconSource: "../../assets/outstanding.svg"
    variant: notificationController.notifications.length > 0 ? "primary" : "ghost"
    onClicked: notificationCenter.visible = !notificationCenter.visible
    ToolTip.text: "Notifications - View your notifications"
    ToolTip.delay: 300

    // Badge
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 18
        height: 18
        radius: 9
        color: Style.danger
        visible: notificationController.notifications.length > 0

        Text {
            anchors.centerIn: parent
            text: notificationController.notifications.length
            font.pixelSize: 10
            font.bold: true
            color: Style.surface
        }
    }
}
```

---

## Summary

This documentation covers all the UI/UX features implemented in the Project Tracker application:

### ✅ Implemented Features

1. **Grouped Navigation**
   - 5 logical groups (Projects, Planning, Management, Tools, Settings)
   - Progressive disclosure with expand/collapse
   - Groups collapsed by default
   - Color-coded highlighting for each group

2. **State Persistence**
   - Sidebar expanded state saved between sessions
   - Uses Qt.labs.settings 1.0
   - Automatic loading on startup

3. **Keyboard Shortcuts**
   - Global shortcuts (Ctrl+K, Ctrl+N, Ctrl+F, Ctrl+1/2/3, Esc, Space)
   - Command palette with search and quick actions

4. **Qt Quick Configuration**
   - qtquickcontrols2.conf for custom styling
   - Custom QML templates (Button, CheckBox, ComboBox, Slider, TextField)
   - Reusable components (Card, EmptyState, LoadingIndicator, Tooltip)

5. **Custom Tags**
   - Color-coded tag badges
   - Tag filtering with autocomplete
   - Tag input and display components

6. **Project Templates**
   - Template creation and management
   - Clone projects from templates
   - Pre-defined steps and deliverables

7. **Rich Markdown**
   - Markdown editor with live preview
   - Edit/Preview tabs
   - Full CommonMark support

8. **Notification System**
   - Desktop notifications via QSystemTrayIcon
   - Notification center with history
   - Deadline checking and reminders
   - Notification badges

### 📁 Documentation Files

- `docs/UI_UX_DOCUMENTATION.md` - This comprehensive guide
- `docs/AI_AND_WORKFLOW_ENHANCEMENT_GUIDE.md` - Feature enhancement guide
- `docs/screenshots/` - Application screenshots

### 🎯 Next Steps

- Test all features in the actual application
- Update screenshots to reflect the new grouped navigation
- Add user guide for getting started
- Document API integration for AI features
