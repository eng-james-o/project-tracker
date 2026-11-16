from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from db.database import DatabaseManager


class TagController(QObject):
    allTagsChanged = Signal()
    selectedTagsChanged = Signal()
    tagColorsChanged = Signal()

    def __init__(
        self,
        db: DatabaseManager,
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self._all_tags: List[str] = []
        self._selected_tags: List[str] = []
        self._tag_colors: Dict[str, str] = {}
        self._custom_tag_colors: Dict[str, str] = {}
        self._refresh_all_tags()

    @Slot()
    def _refresh_all_tags(self):
        self._all_tags = self.db.get_all_tags()
        self.allTagsChanged.emit()

    @Slot()
    def refresh_selected_tags(self):
        self.selectedTagsChanged.emit()

    @Property(list, notify=allTagsChanged)
    def allTags(self) -> List[str]:
        return self._all_tags

    @Property(list, notify=selectedTagsChanged)
    def selectedTags(self) -> List[str]:
        return self._selected_tags

    @Property(dict, notify=tagColorsChanged)
    def tagColors(self) -> Dict[str, str]:
        return self._tag_colors

    @Slot(str)
    def add_selected_tag(self, tag: str):
        if tag not in self._selected_tags:
            self._selected_tags.append(tag)
            self.selectedTagsChanged.emit()

    @Slot(str)
    def remove_selected_tag(self, tag: str):
        if tag in self._selected_tags:
            self._selected_tags.remove(tag)
            self.selectedTagsChanged.emit()

    @Slot()
    def clear_selected_tags(self):
        self._selected_tags = []
        self.selectedTagsChanged.emit()

    @Slot(str, str)
    def set_tag_color(self, tag: str, color: str):
        self._custom_tag_colors[tag] = color
        self._update_tag_colors()
        self.tagColorsChanged.emit()

    @Slot(str)
    def remove_tag_color(self, tag: str):
        if tag in self._custom_tag_colors:
            del self._custom_tag_colors[tag]
        self._update_tag_colors()
        self.tagColorsChanged.emit()

    def _update_tag_colors(self):
        # Generate consistent colors for tags
        colors = [
            "#1A73E8", "#34A853", "#FBBC04", "#EA4335",
            "#8AB4F8", "#81C995", "#FDD663", "#F28B82",
            "#673AB7", "#FF5722", "#009688", "#795548",
        ]
        for i, tag in enumerate(self._all_tags):
            if tag in self._custom_tag_colors:
                self._tag_colors[tag] = self._custom_tag_colors[tag]
            else:
                # Use consistent color based on tag name hash
                color_index = hash(tag) % len(colors)
                self._tag_colors[tag] = colors[color_index]

    @Slot(str, result=str)
    def get_tag_color(self, tag: str) -> str:
        if tag in self._tag_colors:
            return self._tag_colors[tag]
        # Default color for unknown tags
        return "#5F6368"

    @Slot(str, result=bool)
    def has_tag(self, tag: str) -> bool:
        return tag in self._all_tags

    @Slot(str, result=bool)
    def is_tag_selected(self, tag: str) -> bool:
        return tag in self._selected_tags

    @Slot(result=list)
    def get_filtered_projects_by_tags(self) -> List[Dict[str, Any]]:
        if not self._selected_tags:
            return []
        return self.db.get_projects_by_tags(self._selected_tags)
