# Troubleshooting OpenCode Tool Support

## Issue: "does not support tools" Error

If you encounter this error when running OpenCode with local Ollama models:

```
Error: registry.ollama.ai/library/code-buddy:latest does not support tools
```

## Investigation Summary

We've conducted extensive investigation into this issue. Here's what we found:

### What Works ✅

1. **Models are properly configured**
   - All Modelfiles include `num_ctx 40960` 
   - System prompts mention tool capabilities
   - Stop tokens are correct
   - Template formats are appropriate

2. **AI SDK is installable**
   - `@ai-sdk/openai-compatible` can be installed via bun/npm
   - Package loads correctly in Node.js
   - Located in `~/.config/opencode/node_modules/`

3. **Configuration file is created**
   - Located at `~/.config/opencode/providers/opencode.json`
   - Contains proper JSON structure
   - Includes all model definitions with `"tools": true`

### What Doesn't Work ❌

**OpenCode's provider loading mechanism does not recognize the custom Ollama configuration.**

Despite following all documentation and community examples:
- The `ollama` provider is not loaded
- `opencode models ollama` returns "Provider not found"
- The error persists even after:
  - Restarting OpenCode processes
  - Recreating models
  - Validating JSON format
  - Installing AI SDK
  - Trying various config file locations/names

## Root Cause

OpenCode version 1.1.28 appears to have limitations in its custom provider loading system. The built-in "opencode" provider works, but dynamically loaded providers from config files may not be recognized.

## Attempted Solutions

### 1. Install AI SDK

```bash
cd ~/.config/opencode
bun add @ai-sdk/openai-compatible
# or
npm install @ai-sdk/openai-compatible
```

**Status**: ✅ Successful, but doesn't fix the issue

### 2. Create Provider Configuration

File: `~/.config/opencode/providers/opencode.json`

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
         "code-buddy:latest": {
           "name": "Code Buddy - Qwen2.5 7B",
           "tools": true,
           "reasoning": true,
           "options": { "num_ctx": 40960 }
         }
      }
    }
  }
}
```

**Status**: ✅ File created, but not recognized by OpenCode

### 3. Restart Everything

```bash
killall opencode
# Restart Ollama
systemctl --user restart ollama  # or however you run Ollama
# Try again
opencode run "test command" --model ollama/code-buddy:latest
```

**Status**: ❌ Still fails

## Current Workarounds

### Option 1: Use Models with Native Tool Support

Some Ollama models explicitly advertise tool capabilities:

```bash
ollama pull granite3.3:8b
ollama show granite3.3:8b
# Should show "Capabilities: tools"
```

Then use directly:

```bash
opencode run "your command" --model granite3.3:8b
```

### Option 2: Use Alternative Tools

- **LM Studio**: Better support for local models with tools
- **Continue.dev**: VS Code extension with good local model support
- **Aider**: CLI tool that works well with local Ollama models

### Option 3: Use OpenCode's Official Models

OpenCode works best with its integrated models:

```bash
opencode models
# Lists: opencode/big-pickle, opencode/grok-code, etc.
```

## GitHub Issue References

This is a known issue in the OpenCode community:
- [Tool use with Ollama models #1068](https://github.com/anomalyco/opencode/issues/1068)
- [Local Ollama tool calling either not calling or failing outright #1034](https://github.com/anomalyco/opencode/issues/1034)
- [Cannot use tools with qwen2.5-coder and Ollama #2728](https://github.com/anomalyco/opencode/issues/2728)

## What We Know For Sure

1. Our Modelfiles are correct (num_ctx 40960 ✓)
2. Our models have proper tool-aware system prompts ✓
3. Ollama serves models via OpenAI-compatible API ✓
4. The AI SDK package can load models from Ollama ✓

**The problem is OpenCode's provider discovery/loading mechanism.**

## Future Solutions

This repository will be updated when:
- OpenCode improves custom provider support
- A working configuration format is discovered
- Community finds a reliable workaround

## For Repository Maintainers

The models in this repository are correctly configured. The issue is not with the Modelfiles but with how OpenCode loads custom providers. Keep the Modelfiles as-is - they follow best practices and will work when OpenCode's provider system is fixed.

## Testing Tool Support Manually

You can test if models would work with tools by using the Ollama API directly:

```bash
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "code-buddy:latest",
    "messages": [{"role": "user", "content": "Hello"}],
    "tools": [
      {
        "type": "function",
        "function": {
          "name": "create_file",
          "description": "Create a new file",
          "parameters": {
            "type": "object",
            "properties": {
              "path": {"type": "string"},
              "content": {"type": "string"}
            }
          }
        }
      }
    ]
  }'
```

If this returns a valid response (not an error about tools), the model supports tools at the API level.

## Last Updated

January 21, 2026

Investigation conducted on:
- OpenCode version: 1.1.28
- Ollama version: 0.14.2
- System: Fedora Linux
