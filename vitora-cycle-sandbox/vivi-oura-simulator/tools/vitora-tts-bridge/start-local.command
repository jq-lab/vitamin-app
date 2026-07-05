#!/bin/zsh
set -euo pipefail

cd "/Users/youxiang/Desktop/V12 最终确认版/vitora-cycle-sandbox/vivi-oura-simulator"

export VITORA_TTS_DATA_DIR="/private/tmp/vitora-tts-live-listen"
export VITORA_TTS_HOST="127.0.0.1"
export VITORA_TTS_PORT="8787"

echo "Starting Vitora TTS Bridge..."
echo "Open: http://127.0.0.1:8787/"
echo ""

pnpm tts:bridge
