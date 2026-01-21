# opencode-modelfiles

Modelfiles compatible with Opencode to run on Ollama (locally)

## Overview

This repository contains optimized Ollama Modelfiles for various AI coding models, configured for use with opencode and optimized for AMD Radeon RX 7900 XTX (20 GB VRAM).

All models feature:
- **Extended Context Window**: 16384 tokens (`num_ctx 16384`)
- **GPU Optimization**: Configured for AMD Radeon RX 7900 XTX
- **Opencode Integration**: System prompts optimized for coding assistance with tool capabilities
- **GGUF Format**: Quantized models for efficient local inference

## Available Models

### 1. Qwen3 Coder 30B A3B Instruct
- **File**: `Modelfile.qwen3-coder-30b`
- **Model**: unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF (Q4_K_M)
- **Best for**: Large-scale code generation and complex refactoring tasks

### 2. OpenAI GPT OSS 20B Abliterated Uncensored
- **File**: `Modelfile.openai-gpt-oss-20b`
- **Model**: DavidAU/OpenAi-GPT-oss-20b-abliterated-uncensored-NEO-Imatrix-gguf (Q4_K_M)
- **Best for**: General-purpose coding with unrestricted capabilities

### 3. Devstral Small 24B Instruct
- **File**: `Modelfile.devstral-small-24b`
- **Model**: unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF (Q4_K_M)
- **Best for**: Balanced performance and capability for development tasks

### 4. Qwen2.5 Coder 7B 3x Instruct TIES
- **File**: `Modelfile.qwen2.5-coder-7b`
- **Model**: QuantFactory/Qwen2.5-Coder-7B-3x-Instruct-TIES-v1.2-GGUF (Q4_K_M)
- **Best for**: Fast code completion and lightweight coding assistance

### 5. Qwen3 Zero Coder Reasoning 0.8B
- **File**: `Modelfile.qwen3-zero-coder-0.8b`
- **Model**: DavidAU/Qwen3-Zero-Coder-Reasoning-0.8B-NEO-EX-GGUF (Q6_K)
- **Best for**: Ultra-lightweight reasoning and quick code suggestions

## Installation

### Prerequisites
- [Ollama](https://ollama.ai/) installed on your system
- AMD Radeon RX 7900 XTX or compatible GPU
- Sufficient disk space for model downloads

### Usage

1. Clone this repository:
```bash
git clone https://github.com/manoelhc/opencode-modelfiles.git
cd opencode-modelfiles
```

2. Create a model using any of the Modelfiles:
```bash
# Example: Create Qwen3 Coder 30B model
ollama create qwen3-coder-30b -f Modelfile.qwen3-coder-30b

# Example: Create Qwen2.5 Coder 7B model
ollama create qwen2.5-coder-7b -f Modelfile.qwen2.5-coder-7b
```

3. Run the model:
```bash
ollama run qwen3-coder-30b
```

4. Use with opencode or your preferred interface:
```bash
# The model is now available for use with opencode
# or any other Ollama-compatible application
```

## Configuration Details

Each Modelfile includes:
- `num_ctx 16384`: Extended context window for handling larger codebases
- `num_gpu 99`: Maximum GPU utilization for AMD hardware
- `num_thread 8`: Optimized threading for modern CPUs
- `temperature 0.7`: Balanced creativity vs. determinism
- Model-specific stop tokens for proper inference
- Comprehensive system prompts for coding assistance

### Template Formats

Different models use different prompt templates:

- **ChatML Format** (Qwen models, OpenAI GPT OSS): Uses `<|im_start|>` and `<|im_end|>` tags
  - Used by: Qwen3 Coder 30B, Qwen2.5 Coder 7B, Qwen3 Zero Coder 0.8B, OpenAI GPT OSS 20B

- **Instruct Format** (Devstral): Uses `[INST]` and `[/INST]` tags
  - Used by: Devstral Small 24B

These templates are optimized for each model's training format to ensure proper response generation.

## Capabilities

All models are configured with system prompts that enable:
- Code generation, completion, and refactoring
- Bug detection and debugging assistance
- Code explanation and documentation
- Architecture and design recommendations
- Performance optimization
- Security analysis
- Test generation
- Git operations and file management
- Command-line assistance

## License

See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for improvements.
