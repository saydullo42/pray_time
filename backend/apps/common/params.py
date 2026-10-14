"""Validation of query-string parameters, so malformed input gets a 400 with a
message instead of an unhandled exception (HTTP 500)."""

from datetime import date

from rest_framework.exceptions import ValidationError

MIN_YEAR = 1900
MAX_YEAR = 2200


def int_param(params, name: str, *, minimum: int, maximum: int, default: int | None = None, required: bool = True) -> int:
    raw = params.get(name)
    if raw in (None, ""):
        if default is not None:
            return default
        if required:
            raise ValidationError({name: "Bu parametr majburiy."})
    try:
        value = int(raw)
    except (TypeError, ValueError):
        raise ValidationError({name: "Butun son bo'lishi kerak."})
    if not minimum <= value <= maximum:
        raise ValidationError({name: f"{minimum} dan {maximum} gacha bo'lishi kerak."})
    return value


def float_param(params, name: str, *, minimum: float, maximum: float) -> float:
    raw = params.get(name)
    if raw in (None, ""):
        raise ValidationError({name: "Bu parametr majburiy."})
    try:
        value = float(raw)
    except (TypeError, ValueError):
        raise ValidationError({name: "Son bo'lishi kerak."})
    if not minimum <= value <= maximum:  # also rejects nan
        raise ValidationError({name: f"{minimum} dan {maximum} gacha bo'lishi kerak."})
    return value


def date_param(params, name: str, *, default: date | None = None) -> date:
    raw = params.get(name)
    if raw in (None, ""):
        if default is not None:
            return default
        raise ValidationError({name: "Bu parametr majburiy."})
    try:
        value = date.fromisoformat(raw)
    except ValueError:
        raise ValidationError({name: "Sana YYYY-MM-DD ko'rinishida bo'lishi kerak."})
    if not MIN_YEAR <= value.year <= MAX_YEAR:
        raise ValidationError({name: f"Yil {MIN_YEAR} dan {MAX_YEAR} gacha bo'lishi kerak."})
    return value
