import sqlite3
import os
from typing import List, Dict, Any, Optional
from datetime import datetime

class AuditDatabaseManager:
    def __init__(self, db_path: str = "audit_tracker.db", max_rows: int = 500):
        self.db_path = db_path
        self.max_rows = max_rows
        self._init_db()

    def get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS audit_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER,
                entity_type TEXT NOT NULL,
                entity_id INTEGER,
                action TEXT NOT NULL,
                details TEXT DEFAULT '',
                repeat_count INTEGER DEFAULT 1,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)
            conn.commit()

    def log_audit(self, project_id: Optional[int], entity_type: str, entity_id: Optional[int], action: str, details: str = ""):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()

            # Check if the most recent entry is identical for repeated modification compression
            cursor.execute("""
                SELECT id, details, repeat_count FROM audit_logs
                ORDER BY id DESC LIMIT 1
            """)
            last_entry = cursor.fetchone()

            if last_entry and last_entry['details'] == details:
                # Compress into single entry by incrementing repeat_count and updating timestamp
                new_count = last_entry['repeat_count'] + 1
                cursor.execute("""
                    UPDATE audit_logs
                    SET repeat_count = ?, timestamp = ?
                    WHERE id = ?
                """, (new_count, now, last_entry['id']))
            else:
                cursor.execute("""
                    INSERT INTO audit_logs (project_id, entity_type, entity_id, action, details, repeat_count, timestamp)
                    VALUES (?, ?, ?, ?, ?, 1, ?)
                """, (project_id, entity_type, entity_id, action, details, now))

            # Enforce max row cap
            cursor.execute("SELECT COUNT(*) FROM audit_logs")
            total_rows = cursor.fetchone()[0]
            if total_rows > self.max_rows:
                excess = total_rows - self.max_rows
                cursor.execute("""
                    DELETE FROM audit_logs
                    WHERE id IN (
                        SELECT id FROM audit_logs ORDER BY id ASC LIMIT ?
                    )
                """, (excess,))

            conn.commit()

    def get_audit_logs(self, project_id: Optional[int] = None, limit: int = 100) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            if project_id is not None:
                cursor.execute("""
                    SELECT * FROM audit_logs
                    WHERE project_id = ?
                    ORDER BY id DESC
                    LIMIT ?
                """, (project_id, limit))
            else:
                cursor.execute("""
                    SELECT * FROM audit_logs
                    ORDER BY id DESC
                    LIMIT ?
                """, (limit,))
            return [dict(r) for r in cursor.fetchall()]

    def set_max_rows(self, max_rows: int):
        self.max_rows = max_rows

    def clear_audit_logs(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM audit_logs")
            conn.commit()
