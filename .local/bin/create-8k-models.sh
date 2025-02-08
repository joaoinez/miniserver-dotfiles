#!/bin/bash

for modelfile in *.Modelfile; do
  base_name=$(basename "$modelfile" .Modelfile)

  sanitized_name="${base_name%-8k}"

  model_name="${sanitized_name}-8k"

  echo "Creating model $model_name from $modelfile"
  ollama create -f "$modelfile" "$model_name"
done
