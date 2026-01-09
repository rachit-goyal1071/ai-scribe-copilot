import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base

DB_URL = os.getenv("DB_URL", "sqlite:///./db.sqlite3")

engine = create_engine(
    DB_URL,
    connect_args={"check_same_thread": False} if DB_URL.startswith("sqlite") else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

from app import models
Base.metadata.create_all(bind=engine)


def _sqlite_add_column_if_missing(table: str, column: str, ddl: str) -> None:
    if not DB_URL.startswith("sqlite"):
        return
    with engine.begin() as conn:
        cols = [row[1] for row in conn.execute(text(f"PRAGMA table_info({table})"))]
        if column not in cols:
            conn.execute(text(ddl))


def _postgres_add_column_if_missing(table: str, ddl: str) -> None:
    # Only attempt for postgres; other DBs can be handled via proper migrations later.
    if not (DB_URL.startswith("postgresql") or DB_URL.startswith("postgres")):
        return
    with engine.begin() as conn:
        conn.execute(text(ddl))


# Best-effort local dev migration (SQLite only)
_sqlite_add_column_if_missing(
    table="sessions",
    column="session_error",
    ddl="ALTER TABLE sessions ADD COLUMN session_error TEXT",
)

# Best-effort VM migration (Postgres)
_postgres_add_column_if_missing(
    table="sessions",
    ddl="ALTER TABLE sessions ADD COLUMN IF NOT EXISTS session_error TEXT",
)
