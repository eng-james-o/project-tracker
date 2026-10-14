import sqlite3
import os
import json
from typing import List, Dict, Any, Optional
from datetime import datetime
from db.audit_database import AuditDatabaseManager

class DatabaseManager:
    def __init__(self, db_path: str = "project_tracker.db", audit_db_manager: Optional[AuditDatabaseManager] = None):
        self.db_path = db_path
        self.audit_db = audit_db_manager if audit_db_manager else AuditDatabaseManager()
        self._init_db()

    def get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON;")
        return conn

    def _init_db(self):
        with self.get_connection() as conn:
            cursor = conn.cursor()

            # User Profile Table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_profiles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT DEFAULT '',
                gender TEXT DEFAULT '',
                email TEXT DEFAULT '',
                jobs TEXT DEFAULT '',
                companies TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)

            # Projects Table with new fields
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                client_name TEXT DEFAULT '',
                client_email TEXT DEFAULT '',
                status TEXT DEFAULT 'active' CHECK(status IN ('active', 'paused', 'completed')),
                deadline TEXT DEFAULT '',
                description TEXT DEFAULT '',
                price REAL DEFAULT 0.0,
                paid_amount REAL DEFAULT 0.0,
                currency TEXT DEFAULT 'USD',
                tags TEXT DEFAULT '',
                company_id INTEGER DEFAULT NULL,
                is_personal INTEGER DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS resources (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                type TEXT NOT NULL CHECK(type IN ('link', 'document', 'folder', 'note', 'markdown')),
                title TEXT NOT NULL,
                path_or_content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)

            # Blockers Table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS blockers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER,
                step_id INTEGER,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                severity TEXT DEFAULT 'medium' CHECK(severity IN ('low', 'medium', 'high', 'critical')),
                status TEXT DEFAULT 'open' CHECK(status IN ('open', 'resolved', 'in_progress')),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
                FOREIGN KEY (step_id) REFERENCES steps (id) ON DELETE CASCADE
            );
            """)

            # Payment Tracking Table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                amount REAL NOT NULL,
                currency TEXT DEFAULT 'USD',
                payment_date TEXT DEFAULT '',
                payment_method TEXT DEFAULT '',
                description TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
            );
            """)

            # Project Ideas/Board Table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS project_ideas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                status TEXT DEFAULT 'idea' CHECK(status IN ('idea', 'planned', 'in_progress', 'completed', 'rejected')),
                priority TEXT DEFAULT 'medium' CHECK(priority IN ('low', 'medium', 'high', 'critical')),
                tags TEXT DEFAULT '',
                estimated_budget REAL DEFAULT 0.0,
                estimated_timeline TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)

            # Goals Table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS goals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                goal_type TEXT DEFAULT 'daily' CHECK(goal_type IN ('daily', 'weekly', 'monthly')),
                target_date TEXT DEFAULT '',
                status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')),
                priority TEXT DEFAULT 'medium' CHECK(priority IN ('low', 'medium', 'high', 'critical')),
                tags TEXT DEFAULT '',
                is_recurring INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)

            # Companies Table (for user's companies)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS companies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)

            conn.commit()

    # --- Projects CRUD ---
    def add_project(self, title: str, client_name: str = "", client_email: str = "",
                    status: str = "active", deadline: str = "", description: str = "") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO projects (title, client_name, client_email, status, deadline, description, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (title, client_name, client_email, status, deadline, description, now, now))
            pid = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(pid, "project", pid, "CREATE", f"Created project '{title}'")
        return pid

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
                p['deliverables_total'] = self._get_count(conn, "SELECT COUNT(*) FROM deliverables WHERE project_id = ?", (p['id'],))
                p['deliverables_completed'] = self._get_count(conn, "SELECT COUNT(*) FROM deliverables WHERE project_id = ? AND completed = 1", (p['id'],))
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
            p['audit_logs'] = self.audit_db.get_audit_logs(project_id, limit=6)
            return p

    def update_project(self, project_id: int, title: str, client_name: str, client_email: str,
                       status: str, deadline: str, description: str) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE projects
                SET title = ?, client_name = ?, client_email = ?, status = ?, deadline = ?, description = ?, updated_at = ?
                WHERE id = ?
            """, (title, client_name, client_email, status, deadline, description, now, project_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(project_id, "project", project_id, "UPDATE", f"Updated project '{title}'")
                return True
            return False

    def update_project_status(self, project_id: int, status: str) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE projects SET status = ?, updated_at = ? WHERE id = ?", (status, now, project_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(project_id, "project", project_id, "UPDATE_STATUS", f"Changed status to '{status}'")
                return True
            return False

    def delete_project(self, project_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT title FROM projects WHERE id = ?", (project_id,))
            row = cursor.fetchone()
            title = row['title'] if row else f"ID {project_id}"

            cursor.execute("DELETE FROM projects WHERE id = ?", (project_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(None, "project", project_id, "DELETE", f"Deleted project '{title}'")
                return True
            return False

    # --- Steps CRUD ---
    def add_step(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO steps (project_id, title, deadline, completed, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (project_id, title, deadline, 1 if completed else 0, now, now))
            sid = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(project_id, "step", sid, "CREATE", f"Added step '{title}'")
        return sid

    def get_steps(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM steps WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def update_step(self, step_id: int, title: str, deadline: str) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id FROM steps WHERE id = ?", (step_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']

            cursor.execute("""
                UPDATE steps
                SET title = ?, deadline = ?, updated_at = ?
                WHERE id = ?
            """, (title, deadline, now, step_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "step", step_id, "UPDATE", f"Updated step '{title}'")
                return True
            return False

    def toggle_step_completion(self, step_id: int, completed: bool) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM steps WHERE id = ?", (step_id,))
            step_row = cursor.fetchone()
            if not step_row:
                return False
            pid = step_row['project_id']
            title = step_row['title']

            cursor.execute("UPDATE steps SET completed = ?, updated_at = ? WHERE id = ?", (1 if completed else 0, now, step_id))
            status_str = "completed" if completed else "uncompleted"
            conn.commit()

        self.audit_db.log_audit(pid, "step", step_id, "TOGGLE", f"Marked step '{title}' as {status_str}")
        return True

    def delete_step(self, step_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM steps WHERE id = ?", (step_id,))
            step_row = cursor.fetchone()
            pid = step_row['project_id'] if step_row else None
            title = step_row['title'] if step_row else f"ID {step_id}"

            cursor.execute("DELETE FROM steps WHERE id = ?", (step_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "step", step_id, "DELETE", f"Deleted step '{title}'")
                return True
            return False

    # --- Deliverables CRUD ---
    def add_deliverable(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO deliverables (project_id, title, deadline, completed, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (project_id, title, deadline, 1 if completed else 0, now, now))
            did = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(project_id, "deliverable", did, "CREATE", f"Added deliverable '{title}'")
        return did

    def get_deliverables(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM deliverables WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def update_deliverable(self, deliverable_id: int, title: str, deadline: str) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id FROM deliverables WHERE id = ?", (deliverable_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']

            cursor.execute("""
                UPDATE deliverables
                SET title = ?, deadline = ?, updated_at = ?
                WHERE id = ?
            """, (title, deadline, now, deliverable_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "deliverable", deliverable_id, "UPDATE", f"Updated deliverable '{title}'")
                return True
            return False

    def toggle_deliverable_completion(self, deliverable_id: int, completed: bool) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM deliverables WHERE id = ?", (deliverable_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']
            title = row['title']

            cursor.execute("UPDATE deliverables SET completed = ?, updated_at = ? WHERE id = ?", (1 if completed else 0, now, deliverable_id))
            status_str = "completed" if completed else "uncompleted"
            conn.commit()

        self.audit_db.log_audit(pid, "deliverable", deliverable_id, "TOGGLE", f"Marked deliverable '{title}' as {status_str}")
        return True

    def delete_deliverable(self, deliverable_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM deliverables WHERE id = ?", (deliverable_id,))
            row = cursor.fetchone()
            pid = row['project_id'] if row else None
            title = row['title'] if row else f"ID {deliverable_id}"

            cursor.execute("DELETE FROM deliverables WHERE id = ?", (deliverable_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "deliverable", deliverable_id, "DELETE", f"Deleted deliverable '{title}'")
                return True
            return False

    # --- Resources CRUD ---
    def add_resource(self, project_id: int, res_type: str, title: str, path_or_content: str) -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO resources (project_id, type, title, path_or_content, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (project_id, res_type, title, path_or_content, now, now))
            rid = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(project_id, "resource", rid, "CREATE", f"Attached resource '{title}' ({res_type})")
        return rid

    def get_resources(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM resources WHERE project_id = ? ORDER BY id ASC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def update_resource(self, resource_id: int, res_type: str, title: str, path_or_content: str) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id FROM resources WHERE id = ?", (resource_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']

            cursor.execute("""
                UPDATE resources
                SET type = ?, title = ?, path_or_content = ?, updated_at = ?
                WHERE id = ?
            """, (res_type, title, path_or_content, now, resource_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "resource", resource_id, "UPDATE", f"Updated resource '{title}'")
                return True
            return False

    def delete_resource(self, resource_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM resources WHERE id = ?", (resource_id,))
            row = cursor.fetchone()
            pid = row['project_id'] if row else None
            title = row['title'] if row else f"ID {resource_id}"

            cursor.execute("DELETE FROM resources WHERE id = ?", (resource_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "resource", resource_id, "DELETE", f"Removed resource '{title}'")
                return True
            return False

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

            items.sort(key=lambda x: x['deadline'])
            return items[:limit]

    def _get_count(self, conn: sqlite3.Connection, query: str, params: tuple = ()) -> int:
        cursor = conn.cursor()
        cursor.execute(query, params)
        res = cursor.fetchone()
        return res[0] if res else 0

    # --- User Profile CRUD ---
    def add_user_profile(self, name: str = "", gender: str = "", email: str = "", jobs: str = "", companies: str = "") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO user_profiles (name, gender, email, jobs, companies, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (name, gender, email, jobs, companies, now, now))
            pid = cursor.lastrowid
            conn.commit()
        return pid

    def get_user_profiles(self) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM user_profiles ORDER BY id DESC")
            return [dict(r) for r in cursor.fetchall()]

    def get_user_profile_by_id(self, profile_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM user_profiles WHERE id = ?", (profile_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_user_profile(self, profile_id: int, name: str = "", gender: str = "", email: str = "", jobs: str = "", companies: str = "") -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE user_profiles
                SET name = ?, gender = ?, email = ?, jobs = ?, companies = ?, updated_at = ?
                WHERE id = ?
            """, (name, gender, email, jobs, companies, now, profile_id))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    def delete_user_profile(self, profile_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM user_profiles WHERE id = ?", (profile_id,))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    # --- Companies CRUD ---
    def add_company(self, name: str, description: str = "") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO companies (name, description, created_at, updated_at)
                VALUES (?, ?, ?, ?)
            """, (name, description, now, now))
            cid = cursor.lastrowid
            conn.commit()
        return cid

    def get_companies(self) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM companies ORDER BY name ASC")
            return [dict(r) for r in cursor.fetchall()]

    def get_company_by_id(self, company_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM companies WHERE id = ?", (company_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def delete_company(self, company_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM companies WHERE id = ?", (company_id,))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    # --- Updated Project CRUD with price, paid, tags ---
    def add_project(self, title: str, client_name: str = "", client_email: str = "",
                    status: str = "active", deadline: str = "", description: str = "",
                    price: float = 0.0, paid_amount: float = 0.0, currency: str = "USD",
                    tags: str = "", company_id: Optional[int] = None, is_personal: bool = True) -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO projects (title, client_name, client_email, status, deadline, description, price, paid_amount, currency, tags, company_id, is_personal, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (title, client_name, client_email, status, deadline, description, price, paid_amount, currency, tags, company_id, 1 if is_personal else 0, now, now))
            pid = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(pid, "project", pid, "CREATE", f"Created project '{title}'")
        return pid

    def get_projects(self, status_filter: Optional[str] = None, search: Optional[str] = None, company_filter: Optional[int] = None, tag_filter: Optional[str] = None) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            query = "SELECT * FROM projects WHERE 1=1"
            params = []

            if status_filter and status_filter.lower() != "all":
                query += " AND status = ?"
                params.append(status_filter.lower())

            if search:
                query += " AND (title LIKE ? OR client_name LIKE ? OR description LIKE ? OR tags LIKE ?)"
                term = f"%{search}%"
                params.extend([term, term, term, term])

            if company_filter is not None:
                query += " AND company_id = ?"
                params.append(company_filter)

            if tag_filter:
                query += " AND tags LIKE ?"
                params.append(f"%{tag_filter}%")

            query += " ORDER BY id DESC"
            cursor.execute(query, params)
            rows = cursor.fetchall()

            projects = []
            for row in rows:
                p = dict(row)
                p['steps_total'] = self._get_count(conn, "SELECT COUNT(*) FROM steps WHERE project_id = ?", (p['id'],))
                p['steps_completed'] = self._get_count(conn, "SELECT COUNT(*) FROM steps WHERE project_id = ? AND completed = 1", (p['id'],))
                p['deliverables_total'] = self._get_count(conn, "SELECT COUNT(*) FROM deliverables WHERE project_id = ?", (p['id'],))
                p['deliverables_completed'] = self._get_count(conn, "SELECT COUNT(*) FROM deliverables WHERE project_id = ? AND completed = 1", (p['id'],))
                p['blockers_count'] = self._get_count(conn, "SELECT COUNT(*) FROM blockers WHERE project_id = ?", (p['id'],))
                p['payments_count'] = self._get_count(conn, "SELECT COUNT(*) FROM payments WHERE project_id = ?", (p['id'],))
                p['price_remaining'] = p.get('price', 0) - p.get('paid_amount', 0)
                p['tags_list'] = self._parse_tags(p.get('tags', ''))
                projects.append(p)
            return projects

    def _parse_tags(self, tags_str: str) -> List[str]:
        if not tags_str:
            return []
        return [t.strip() for t in tags_str.split(',') if t.strip()]

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
            p['blockers'] = self.get_blockers(project_id)
            p['payments'] = self.get_payments(project_id)
            p['audit_logs'] = self.audit_db.get_audit_logs(project_id, limit=6)
            p['tags_list'] = self._parse_tags(p.get('tags', ''))
            p['price_remaining'] = p.get('price', 0) - p.get('paid_amount', 0)
            return p

    def update_project(self, project_id: int, title: str, client_name: str, client_email: str,
                       status: str, deadline: str, description: str, price: float = 0.0,
                       paid_amount: float = 0.0, currency: str = "USD", tags: str = "",
                       company_id: Optional[int] = None, is_personal: bool = True) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE projects
                SET title = ?, client_name = ?, client_email = ?, status = ?, deadline = ?, description = ?,
                    price = ?, paid_amount = ?, currency = ?, tags = ?, company_id = ?, is_personal = ?, updated_at = ?
                WHERE id = ?
            """, (title, client_name, client_email, status, deadline, description, price, paid_amount, currency, tags, company_id, 1 if is_personal else 0, now, project_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(project_id, "project", project_id, "UPDATE", f"Updated project '{title}'")
                return True
            return False

    # --- Payment CRUD ---
    def add_payment(self, project_id: int, amount: float, currency: str = "USD", payment_date: str = "",
                    payment_method: str = "", description: str = "") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO payments (project_id, amount, currency, payment_date, payment_method, description, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (project_id, amount, currency, payment_date, payment_method, description, now, now))
            pid = cursor.lastrowid
            conn.commit()

        self.audit_db.log_audit(project_id, "payment", pid, "CREATE", f"Added payment of {amount} {currency}")
        return pid

    def get_payments(self, project_id: int) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM payments WHERE project_id = ? ORDER BY created_at DESC", (project_id,))
            return [dict(r) for r in cursor.fetchall()]

    def get_payment_by_id(self, payment_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM payments WHERE id = ?", (payment_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_payment(self, payment_id: int, amount: float, currency: str = "USD", payment_date: str = "",
                       payment_method: str = "", description: str = "") -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id FROM payments WHERE id = ?", (payment_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']

            cursor.execute("""
                UPDATE payments
                SET amount = ?, currency = ?, payment_date = ?, payment_method = ?, description = ?, updated_at = ?
                WHERE id = ?
            """, (amount, currency, payment_date, payment_method, description, now, payment_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "payment", payment_id, "UPDATE", f"Updated payment to {amount} {currency}")
                return True
            return False

    def delete_payment(self, payment_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, amount, currency FROM payments WHERE id = ?", (payment_id,))
            row = cursor.fetchone()
            pid = row['project_id'] if row else None
            amount = row['amount'] if row else 0
            currency = row['currency'] if row else "USD"

            cursor.execute("DELETE FROM payments WHERE id = ?", (payment_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "payment", payment_id, "DELETE", f"Deleted payment of {amount} {currency}")
                return True
            return False

    # --- Blocker CRUD ---
    def add_blocker(self, project_id: Optional[int] = None, step_id: Optional[int] = None,
                    title: str = "", description: str = "", severity: str = "medium",
                    status: str = "open") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO blockers (project_id, step_id, title, description, severity, status, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (project_id, step_id, title, description, severity, status, now, now))
            bid = cursor.lastrowid
            conn.commit()

        pid = project_id if project_id else (step_id if step_id else None)
        self.audit_db.log_audit(pid, "blocker", bid, "CREATE", f"Added blocker: {title}")
        return bid

    def get_blockers(self, project_id: Optional[int] = None, step_id: Optional[int] = None) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            if project_id is not None:
                cursor.execute("SELECT * FROM blockers WHERE project_id = ? ORDER BY created_at DESC", (project_id,))
            elif step_id is not None:
                cursor.execute("SELECT * FROM blockers WHERE step_id = ? ORDER BY created_at DESC", (step_id,))
            else:
                cursor.execute("SELECT * FROM blockers ORDER BY created_at DESC")
            return [dict(r) for r in cursor.fetchall()]

    def get_blocker_by_id(self, blocker_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM blockers WHERE id = ?", (blocker_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_blocker(self, blocker_id: int, title: str = "", description: str = "",
                       severity: str = "medium", status: str = "open") -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id FROM blockers WHERE id = ?", (blocker_id,))
            row = cursor.fetchone()
            if not row:
                return False
            pid = row['project_id']

            cursor.execute("""
                UPDATE blockers
                SET title = ?, description = ?, severity = ?, status = ?, updated_at = ?
                WHERE id = ?
            """, (title, description, severity, status, now, blocker_id))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "blocker", blocker_id, "UPDATE", f"Updated blocker: {title}")
                return True
            return False

    def delete_blocker(self, blocker_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT project_id, title FROM blockers WHERE id = ?", (blocker_id,))
            row = cursor.fetchone()
            pid = row['project_id'] if row else None
            title = row['title'] if row else f"ID {blocker_id}"

            cursor.execute("DELETE FROM blockers WHERE id = ?", (blocker_id,))
            if cursor.rowcount > 0:
                conn.commit()
                self.audit_db.log_audit(pid, "blocker", blocker_id, "DELETE", f"Deleted blocker: {title}")
                return True
            return False

    # --- Project Ideas CRUD ---
    def add_project_idea(self, title: str, description: str = "", status: str = "idea",
                         priority: str = "medium", tags: str = "", estimated_budget: float = 0.0,
                         estimated_timeline: str = "") -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO project_ideas (title, description, status, priority, tags, estimated_budget, estimated_timeline, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (title, description, status, priority, tags, estimated_budget, estimated_timeline, now, now))
            iid = cursor.lastrowid
            conn.commit()
        return iid

    def get_project_ideas(self, status_filter: Optional[str] = None, search: Optional[str] = None) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            query = "SELECT * FROM project_ideas WHERE 1=1"
            params = []

            if status_filter and status_filter.lower() != "all":
                query += " AND status = ?"
                params.append(status_filter.lower())

            if search:
                query += " AND (title LIKE ? OR description LIKE ? OR tags LIKE ?)"
                term = f"%{search}%"
                params.extend([term, term, term])

            query += " ORDER BY created_at DESC"
            cursor.execute(query, params)
            return [dict(r) for r in cursor.fetchall()]

    def get_project_idea_by_id(self, idea_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM project_ideas WHERE id = ?", (idea_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_project_idea(self, idea_id: int, title: str, description: str = "", status: str = "idea",
                            priority: str = "medium", tags: str = "", estimated_budget: float = 0.0,
                            estimated_timeline: str = "") -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE project_ideas
                SET title = ?, description = ?, status = ?, priority = ?, tags = ?, estimated_budget = ?, estimated_timeline = ?, updated_at = ?
                WHERE id = ?
            """, (title, description, status, priority, tags, estimated_budget, estimated_timeline, now, idea_id))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    def delete_project_idea(self, idea_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM project_ideas WHERE id = ?", (idea_id,))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    # --- Goals CRUD ---
    def add_goal(self, title: str, description: str = "", goal_type: str = "daily",
                 target_date: str = "", status: str = "pending", priority: str = "medium",
                 tags: str = "", is_recurring: bool = False) -> int:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO goals (title, description, goal_type, target_date, status, priority, tags, is_recurring, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (title, description, goal_type, target_date, status, priority, tags, 1 if is_recurring else 0, now, now))
            gid = cursor.lastrowid
            conn.commit()
        return gid

    def get_goals(self, goal_type_filter: Optional[str] = None, status_filter: Optional[str] = None,
                  search: Optional[str] = None) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            query = "SELECT * FROM goals WHERE 1=1"
            params = []

            if goal_type_filter and goal_type_filter.lower() != "all":
                query += " AND goal_type = ?"
                params.append(goal_type_filter.lower())

            if status_filter and status_filter.lower() != "all":
                query += " AND status = ?"
                params.append(status_filter.lower())

            if search:
                query += " AND (title LIKE ? OR description LIKE ? OR tags LIKE ?)"
                term = f"%{search}%"
                params.extend([term, term, term])

            query += " ORDER BY created_at DESC"
            cursor.execute(query, params)
            return [dict(r) for r in cursor.fetchall()]

    def get_goal_by_id(self, goal_id: int) -> Optional[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM goals WHERE id = ?", (goal_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_goal(self, goal_id: int, title: str, description: str = "", goal_type: str = "daily",
                    target_date: str = "", status: str = "pending", priority: str = "medium",
                    tags: str = "", is_recurring: bool = False) -> bool:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE goals
                SET title = ?, description = ?, goal_type = ?, target_date = ?, status = ?, priority = ?, tags = ?, is_recurring = ?, updated_at = ?
                WHERE id = ?
            """, (title, description, goal_type, target_date, status, priority, tags, 1 if is_recurring else 0, now, goal_id))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    def delete_goal(self, goal_id: int) -> bool:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM goals WHERE id = ?", (goal_id,))
            if cursor.rowcount > 0:
                conn.commit()
                return True
            return False

    # --- Helper methods for tags ---
    def get_all_tags(self) -> List[str]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT tags FROM projects WHERE tags IS NOT NULL AND tags != ''")
            rows = cursor.fetchall()
            all_tags = []
            for row in rows:
                tags = self._parse_tags(row['tags'])
                all_tags.extend(tags)
            return list(set(all_tags))

    def get_available_companies(self) -> List[Dict[str, Any]]:
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM companies ORDER BY name ASC")
            return [dict(r) for r in cursor.fetchall()]
