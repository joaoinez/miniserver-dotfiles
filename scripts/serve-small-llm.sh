#!/bin/bash

export LLAMA_CACHE="unsloth/Qwen3.5-2B-GGUF"
llama-server \
  -hf unsloth/Qwen3.5-2B-GGUF:UD-Q4_K_XL \
  --ctx-size 16384 \
  --temp 0.7 \
  --top-p 0.8 \
  --top-k 20 \
  --min-p 0.00 \
  --alias "unsloth/Qwen3.5-2B-GGUF" \
  --port 8001
