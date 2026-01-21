# opencode-modelfiles

Modelfiles compatible with Opencode to run on Ollama (locally)

## Overview

This repository contains optimized Ollama Modelfiles for various AI coding models, configured for use with opencode and optimized for AMD Radeon RX 7900 XTX (20 GB VRAM).

All models feature:
- **Tool Support**: Context window of 16384 tokens (`num_ctx 40960`) for OpenCode tool calling
- **GPU Optimization**: Configured for AMD Radeon RX 7900 XTX with maximum utilization
- **OpenCode Integration**: System prompts optimized for coding assistance with tool capabilities
- **GGUF Format**: Quantized models (Q4_K_M/Q6_K) for efficient local inference

## Available Models

### 1. GPT-OSS 20B
- **File**: `models/Modelfile.code-wizard-3000`
- **Model**: gpt-oss:20b
- **Best for**: Large-scale code generation and complex refactoring tasks

### 2. GPT-OSS 20B
- **File**: `models/Modelfile.captain-code`
- **Model**: gpt-oss:20b
- **Best for**: General-purpose coding with unrestricted capabilities

### 3. Ministral 3 8B
- **File**: `models/Modelfile.dev-ninja`
- **Model**: ministral-3:8b
- **Best for**: Balanced performance and capability for development tasks

### 4. Nemotron 3 Nano 30B
- **File**: `models/Modelfile.code-maestro`
- **Model**: nemotron-3-nano:30b
- **Best for**: General-purpose coding tasks and standard development workflows

### 5. Qwen2.5 Coder 7B 3x Instruct TIES
- **File**: `models/Modelfile.code-buddy`
- **Model**: hf.co/QuantFactory/Qwen2.5-Coder-7B-3x-Instruct-TIES-v1.2-GGUF:Qwen2.5-Coder-7B-3x-Instruct-TIES-v1.2.Q4_K_M.gguf
- **Best for**: Fast code completion and lightweight coding assistance

### 6. Qwen3 8B
- **File**: `models/Modelfile.pocket-coder`
- **Model**: qwen3:8b
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

2. **Quick Start** - Use the build script to create all models with fun names:
```bash
./scripts/build-models.sh
```

This will create all 6 models with creative names:
- `code-wizard-3000` - The mighty GPT-OSS 20B coding sorcerer
- `captain-code` - The fearless GPT-OSS 20B coding superhero
- `dev-ninja` - The stealthy Ministral 3 8B development master
- `code-maestro` - The versatile Nemotron 3 Nano 30B coding maestro
- `code-buddy` - Your friendly Qwen2.5 Coder 7B coding companion
- `pocket-coder` - The tiny but mighty Qwen3 8B code assistant

3. **Manual Creation** - Or create models individually:
```bash
# Example: Create GPT-OSS 20B model
ollama create code-wizard-3000 -f models/Modelfile.code-wizard-3000

# Example: Create Qwen2.5 Coder 7B model
ollama create code-buddy -f models/Modelfile.code-buddy
```

4. Test your models:
```bash
# Run the comprehensive test suite
./scripts/test-models.sh
```

This will check:
- ✅ Ollama service status
- ✅ OpenCode installation
- ✅ Model availability
- ✅ Model configurations (num_ctx)
- ✅ AI SDK installation
- ✅ OpenCode configuration
- ✅ Model execution with OpenCode
- ✅ Direct Ollama API access

5. Run a model:
```bash
# Using the fun names from the build script
ollama run code-wizard-3000

# Or specify another model
ollama run code-buddy
```

6. Use with opencode or your preferred interface:
```bash
# The models are now available for use with opencode
# or any other Ollama-compatible application
```

## Testing Your Setup

Before using the models with OpenCode, run the test suite:

```bash
./scripts/test-models.sh
```

The test script will verify:
- Ollama service is running
- All models are created and available
- Models have correct configurations (num_ctx 40960)
- OpenCode is installed and configured
- AI SDK is installed
- Models can communicate via Ollama's API

**Expected Test Results:**
- Tests 1-7 and 9 should **PASS** ✅
- Test 8 (OpenCode model execution) will likely **FAIL** ❌ due to the known provider recognition issue
- If Test 9 passes, your models work correctly at the API level - the issue is with OpenCode's provider loading

If other tests fail, the script provides specific recommendations for fixing issues.

## Tool Support for OpenCode

**CRITICAL**: For proper tool support in OpenCode, models must be created with the correct context window setting. The Modelfiles in this repository are already configured with `num_ctx 40960`, which is the recommended value for reliable tool calling.

### Why 16384 Context?

Based on extensive community testing ([OpenCode Issue #1068](https://github.com/anomalyco/opencode/issues/1068)):
- Ollama models default to 4096 context when first loaded, which is **too small** for tool support
- A minimum of **40960 tokens** is required for reliable tool calling
- Values like 65536 can work but may cause instability and higher VRAM usage
- **40960 is the sweet spot** - sufficient for tools while fitting in VRAM budget

### Verifying Tool Support

After creating a model, you can verify it has tool capabilities:

```bash
# Check model details
ollama show code-wizard-3000

# Look for:
# - context length: should show 40960
# - Capabilities: should list "tools"
```

### OpenCode Configuration

Configure OpenCode to use your models by editing `~/.config/opencode/providers/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
         "code-wizard-3000": {
           "name": "Code Wizard 3000 - GPT-OSS 20B",
           "tools": true,
           "reasoning": true
         },
         "captain-code": {
           "name": "Captain Code - GPT-OSS 20B",
           "tools": true,
           "reasoning": true
         },
         "dev-ninja": {
           "name": "Dev Ninja - Ministral 3 8B",
           "tools": true,
           "reasoning": true
         },
         "code-maestro": {
           "name": "Code Maestro - Nemotron 3 Nano 30B",
           "tools": true,
           "reasoning": true
         },
         "code-buddy": {
           "name": "Code Buddy - Qwen2.5 Coder 7B",
           "tools": true,
           "reasoning": true
         },
         "pocket-coder": {
           "name": "Pocket Coder - Qwen3 8B",
           "tools": true,
           "reasoning": true
         }
      }
    }
  }
}
```

### Testing Tool Support

Test if tools work properly:

```bash
opencode run "create a file named test.txt with the content 'Hello, OpenCode!'" --model ollama/code-wizard-3000
```

If the file is created successfully, tool support is working! 🎉

### Troubleshooting

**Known Issue: "does not support tools" error**

If you encounter this error:
```
Error: registry.ollama.ai/library/code-buddy:latest does not support tools
```

This is a known OpenCode limitation where custom Ollama provider configurations may not be recognized properly in OpenCode 1.1.28. Our investigation shows:

✅ **What IS working:**
- Models are created with correct `num_ctx 40960`
- System prompts include tool capabilities
- Modelfiles are properly configured
- AI SDK `@ai-sdk/openai-compatible` can be installed

❌ **What's NOT working:**
- OpenCode's provider loading system may not recognize custom Ollama configurations
- The `~/.config/opencode/providers/opencode.json` config file exists but isn't being loaded

**Attempted Solutions:**
1. Run `./setup-opencode-config.sh` to install the AI SDK and create the config file
2. The config file will be created but may not be recognized by OpenCode

**Temporary Workarounds:**
- Use models that explicitly advertise tool support (like `granite3.3:8b` from Ollama's official registry)
- Wait for OpenCode updates that better support custom local Ollama configurations  
- Use an alternative tool like LM Studio which has better local model tool support

**Other troubleshooting steps:**
1. **Verify context window**: Run `ollama show <model-name>` and check context length
2. **Recreate the model**: Delete and recreate using the Modelfile
3. **Check OpenCode config**: Ensure `"tools": true` is set for the model
4. **Restart Ollama**: Sometimes needed after model changes
5. **Kill OpenCode processes**: `killall opencode` then try again

We're tracking this issue and will update the repository when a solution is found.

## Configuration Details

Each Modelfile includes:
- `num_ctx 40960`: Extended context window for handling larger codebases
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

## OpenCode Configuration

The `opencode.json` file provides a comprehensive configuration for all models with:

### Features Enabled
- **Tools** (19 available): file operations, git operations, code execution, testing, building, debugging
- **Reasoning**: Chain-of-thought, step-by-step explanations, alternative solutions, error analysis
- **Autonomy**: Decision making, planning, multi-step task execution with safety controls

### Configuration Highlights
- **6 Models**: From 0.8B to 30B parameters, optimized for different use cases
- **Context Window**: 40,960 tokens across all models
- **Hardware Support**: Optimized for AMD Radeon RX 7900 XTX (20GB VRAM)
- **Security**: Code scanning, vulnerability detection, secrets detection, dependency audit
- **Integrations**: Ollama API, Git, VSCode, Vim

### Usage with OpenCode
The configuration file enables autonomous coding assistance with tool access, reasoning capabilities, and safe execution controls. Each model includes detailed specifications, capabilities, and hardware requirements.

## License

See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for improvements.
