#!/bin/bash

export LLAMA_CACHE="/Users/miniserver/Library/Caches/llama.cpp"
/opt/homebrew/bin/llama-server \
  -hf unsloth/Qwen3.5-0.8B-GGUF:UD-Q4_K_XL \
  --ctx-size 16384 \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --alias "unsloth/Qwen3.5-0.8B-GGUF" \
  --port 8002 \
  --chat-template-kwargs '{"enable_thinking":false}' \
  -np 1
