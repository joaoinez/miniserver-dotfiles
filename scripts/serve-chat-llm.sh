#!/bin/bash

export LLAMA_CACHE="/Users/miniserver/Library/Caches/llama.cpp"
/opt/homebrew/bin/llama-server \
  -hf unsloth/Qwen3.5-9B-GGUF:UD-Q6_K_XL \
  --ctx-size 16384 \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.00 \
  --alias "unsloth/Qwen3.5-9B-GGUF" \
  --port 8001 \
  --chat-template-kwargs '{"enable_thinking":false}' \
  -np 4
