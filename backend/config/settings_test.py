"""Test settings: in-memory SQLite and no migrations.

The dev Postgres role can't create a test database, and these tests don't
need Postgres-only features, so `python manage.py test --settings=config.settings_test`
runs entirely in memory and never touches the real database.
"""

from .settings import *  # noqa: F401,F403


# SQLite has no array columns; only used here to create the tables.
from django.contrib.postgres.fields import ArrayField  # noqa: E402

ArrayField.db_type = lambda self, connection: "text"


class _NoMigrations(dict):
    def __contains__(self, item):
        return True

    def __getitem__(self, item):
        return None


DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
MIGRATION_MODULES = _NoMigrations()
PASSWORD_HASHERS = ["django.contrib.auth.hashers.MD5PasswordHasher"]
GOOGLE_CLIENT_IDS = ["client-web"]
CACHES = {"default": {"BACKEND": "django.core.cache.backends.locmem.LocMemCache"}}
