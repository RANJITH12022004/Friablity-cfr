#!/usr/bin/env bash
# CFR-PLATFORM-HONOR-STORAGE
# When the platform selector already set storage paths, use them.
# Otherwise prefer internal USB root storage, else SD fallback under APP_ROOT.
set -euo pipefail
APP_ROOT="${APP_ROOT:-/opt/friability}"
PYTHON="${PYTHON:-$APP_ROOT/venv/bin/python3}"
INTERNAL_USB_PATH="${INTERNAL_USB_PATH:-/media/usb_internal}"

cd "$APP_ROOT"

if [ -n "${STORAGE_DIR:-}" ] && [ -n "${REPORTS_DIR:-}" ] && [ -n "${AUDIT_DB_DIR:-}" ]; then
  mkdir -p "$STORAGE_DIR" "$REPORTS_DIR" "$AUDIT_DB_DIR" 2>/dev/null || true
  export APP_ROOT PYTHONUNBUFFERED=1
  export FLASK_HOST="${FLASK_HOST:-0.0.0.0}"
  echo "run_kiosk_app: using selector storage at $STORAGE_DIR" >&2
  exec "$PYTHON" "$APP_ROOT/bridge.py"
fi

if mountpoint -q "$INTERNAL_USB_PATH" 2>/dev/null; then
  export STORAGE_DIR="${STORAGE_DIR:-$INTERNAL_USB_PATH/friability/storage}"
  export REPORTS_DIR="${REPORTS_DIR:-$INTERNAL_USB_PATH/friability/reports}"
  export AUDIT_DB_DIR="${AUDIT_DB_DIR:-$INTERNAL_USB_PATH/friability/db}"
else
  export STORAGE_DIR="$APP_ROOT/storage"
  export REPORTS_DIR="$APP_ROOT/reports"
  export AUDIT_DB_DIR="$APP_ROOT/db"
fi

export APP_ROOT PYTHONUNBUFFERED=1
export FLASK_HOST="${FLASK_HOST:-0.0.0.0}"
exec "$PYTHON" "$APP_ROOT/bridge.py"
