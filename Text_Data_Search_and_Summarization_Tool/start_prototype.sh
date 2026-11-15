#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 server.py --port 8000
