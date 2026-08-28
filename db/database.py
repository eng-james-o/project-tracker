import sqlite3
import os
from typing import List, Dict, Any, Optional

class DatabaseManager:
    def __init__(self, db_path: str = "project_tracker.db"):
        self.db_path = db_path
        self._init_db()

    def get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn

    def _init_db(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                client_name TEXT DEFAULT '',
                client_email TEXT DEFAULT '',
                status TEXT DEFAULT 'active' CHECK(status IN ('active', 'paused', 'completed')),
                deadline TEXT DEFAULT '',
                description TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS steps (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                completed INTEGER DEFAULT 0,
                deadline TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS deliverables (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                completed INTEGER DEFAULT 0,
                deadline TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS resources (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                type TEXT NOT NULL CHECK(type IN ('link', 'document', 'folder', 'note')),
                title TEXT NOT NULL,
                path_or_content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)
            conn.commit()

    # --- Projects CRUD ---
    def add_project(self, title: str, client_name: str = "", client_email: str = "",
                    status: str = "active", deadline: str = "", description: str = "") -> int:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO projects (title, client_name, client_email, status, deadline, description)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (title, client_name, client_email, status, deadline, description))
            conn.commit()
            return cursor.lastrowid

    def get_projects(self, status_filter: Optional[str] = None, search: Optional[str] = None) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            query = "SELECT * FROM projects WHERE 1=1"
            params = []

            if status_filter and status_filter.lower() != "all":
                query += " AND status = ?"
                params.append(status_filter.lower())

            if search:
                query += " AND (title LIKE ? OR client_name LIKE ? OR description LIKE ?)"
                term = f"%{search}%"
                params.extend([term, term, term])

            query += " ORDER BY id DESC"
            cursor.execute(query, params)
            rows = cursor.fetchall()

            projects = []
            for row in rows:
                p = dict(row)
                p['steps_total'] = self._get_count(conn, "SELECT COUNT(*) FROM steps WHERE project_id = ?", (p['id'],))
                p['steps_completed'] = self._get_count(conn, "SELECT COUNT(*) FROM steps WHERE project_id = ? AND completed = 1", (p['id'],))
                projects.append(p)
            return projects

    def get_project_by_id(self, project_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM projects WHERE id = ?", (project_id,))
            row = cursor.fetchone()
            if not row:
                return None
            p = dict(row)
            p['steps'] = self.get_steps(project_id)
            p['deliverables'] = self.get_deliverables(project_id)
            p['resources'] = self.get_resources(project_id)
            return p

    def update_project(self, project_id: int, title: str, client_name: str, client_email: str,
                       status: str, deadline: str, description: str) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE projects
                SET title = ?, client_name = ?, client_email = ?, status = ?, deadline = ?, description = ?
                WHERE id = ?
            """, (title, client_name, client_email, status, deadline, description, project_id))
            conn.commit()
            return cursor.rowcount > 0

    def update_project_status(self, project_id: int, status: str) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE projects SET status = ? WHERE id = ?", (status, project_id))
            conn.commit()
            return cursor.rowcount > 0

    def delete_project(self, project_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM projects WHERE id = ?", (project_id,))
            conn.commit()
            return cursor.rowcount > 0

    # --- Steps CRUD ---
    def add_step(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO steps (project_id, title, deadline, completed)
                VALUES (?, ?, ?, ?)
            """, (project_id, title, deadline, 1 if completed else 0))
            conn.commit()
            return cursor.lastrowid

    def get_steps(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM steps WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def toggle_step_completion(self, step_id: int, completed: bool) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE steps SET completed = ? WHERE id = ?", (1 if completed else 0, step_id))
            conn.commit()
            return cursor.rowcount > 0

    def delete_step(self, step_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM steps WHERE id = ?", (step_id,))
            conn.commit()
            return cursor.rowcount > 0

    # --- Deliverables CRUD ---
    def add_deliverable(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO deliverables (project_id, title, deadline, completed)
                VALUES (?, ?, ?, ?)
            """, (project_id, title, deadline, 1 if completed else 0))
            conn.commit()
            return cursor.lastrowid

    def get_deliverables(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM deliverables WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def toggle_deliverable_completion(self, deliverable_id: int, completed: bool) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE deliverables SET completed = ? WHERE id = ?", (1 if completed else 0, deliverable_id))
            conn.commit()
            return cursor.rowcount > 0

    def delete_deliverable(self, deliverable_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM deliverables WHERE id = ?", (deliverable_id,))
            conn.commit()
            return cursor.rowcount > 0

    # --- Resources CRUD ---
    def add_resource(self, project_id: int, res_type: str, title: str, path_or_content: str) -> int:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO resources (project_id, type, title, path_or_content)
                VALUES (?, ?, ?, ?)
            """, (project_id, res_type, title, path_or_content))
            conn.commit()
            return cursor.lastrowid

    def get_resources(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM resources WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def delete_resource(self, resource_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM resources WHERE id = ?", (resource_id,))
            conn.commit()
            return cursor.rowcount > 0

    # --- Dashboard Queries ---
    def get_dashboard_stats(self) -> Dict[str, Any]:
        with self.get_connection() as conn:
            total_projects = self._get_count(conn, "SELECT COUNT(*) FROM projects")
            active_projects = self._get_count(conn, "SELECT COUNT(*) FROM projects WHERE status = 'active'")
            paused_projects = self._get_count(conn, "SELECT COUNT(*) FROM projects WHERE status = 'paused'")
            completed_projects = self._get_count(conn, "SELECT COUNT(*) FROM projects WHERE status = 'completed'")

            return {
                "total": total_projects,
                "active": active_projects,
                "paused": paused_projects,
                "completed": completed_projects
            }

    def get_upcoming_deadlines(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Returns projects, steps, and deliverables that have non-empty deadlines and are not completed."""
        with self.get_connection() as conn:
            cursor = conn.cursor()
            items = []

            # Project deadlines (active or paused)
            cursor.execute("""
                SELECT 'project' as item_type, id, title as item_title, title as project_title, deadline, status, id as project_id
                FROM projects
                WHERE status != 'completed' AND deadline IS NOT NULL AND deadline != ''
            """)
            for row in cursor.fetchall():
                items.append(dict(row))

            # Step deadlines (uncompleted)
            cursor.execute("""
                SELECT 'step' as item_type, s.id, s.title as item_title, p.title as project_title, s.deadline, p.status, p.id as project_id
                FROM steps s
                JOIN projects p ON s.project_id = p.id
                WHERE s.completed = 0 AND s.deadline IS NOT NULL AND s.deadline != '' AND p.status != 'completed'
            """)
            for row in cursor.fetchall():
                items.append(dict(row))

            # Deliverable deadlines (uncompleted)
            cursor.execute("""
                SELECT 'deliverable' as item_type, d.id, d.title as item_title, p.title as project_title, d.deadline, p.status, p.id as project_id
                FROM deliverables d
                JOIN projects p ON d.project_id = p.id
                WHERE d.completed = 0 AND d.deadline IS NOT NULL AND d.deadline != '' AND p.status != 'completed'
            """)
            for row in cursor.fetchall():
                items.append(dict(row))

            # Sort by deadline ASC
            items.sort(key=lambda x: x['deadline'])
            return items[:limit]

    def _get_count(self, conn: sqlite3.Connection, query: str, params: tuple = ()) -> int:
        cursor = conn.cursor()
        cursor.execute(query, params)
        res = cursor.fetchone()
        return res[0] if res else 0
