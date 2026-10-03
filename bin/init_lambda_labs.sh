#! /bin/sh

sudo docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama -e OLLAMA_FLASH_ATTENTION=1 ollama/ollama
alias ollama="sudo docker exec -it ollama ollama"
ollama pull hf.co/bartowski/Evathene-v1.3-GGUF:Q4_K_M
