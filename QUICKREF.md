# Quick Reference Guide

## Scripts

### `build-models.sh`
Creates all 5 models with fun, memorable names.

```bash
./build-models.sh
```

**Creates:**
- `code-wizard-3000` (30B) - Large-scale projects
- `captain-code` (20B) - General purpose
- `dev-ninja` (24B) - Balanced development
- `code-maestro` (30B MoE) - Versatile coding
- `code-buddy` (7B) - Fast prototyping
- `pocket-coder` (0.8B) - Lightweight tasks

### `test-models.sh`
Comprehensive test suite to verify your setup.

```bash
./test-models.sh
```

**Tests:**
1. ✅ Ollama service status
2. ✅ OpenCode installation
3. ✅ Model availability in Ollama
4. ✅ Model configurations (num_ctx)
5. ✅ AI SDK installation
6. ✅ OpenCode configuration file
7. ✅ OpenCode basic functionality
8. ⚠️  Model execution (may fail - known issue)
9. ✅ Direct Ollama API access

**Expected:** Tests 1-7 and 9 should pass. Test 8 may fail due to OpenCode provider limitations.

### `setup-opencode-config.sh`
Installs AI SDK and creates OpenCode configuration.

```bash
./setup-opencode-config.sh
```

**Does:**
- Installs `@ai-sdk/openai-compatible`
- Creates `~/.config/opencode/providers/opencode.json`
- Configures all 5 models with tool support

**Note:** Due to OpenCode limitations, the configuration may not be recognized.

### `recreate-models.sh`
Removes and recreates all models (useful after Modelfile updates).

```bash
./recreate-models.sh
```

**Warning:** This deletes existing models before recreating them.

### `fix-tool-support.sh`
Attempts to set num_ctx parameter via interactive Ollama sessions.

```bash
./fix-tool-support.sh
```

**Status:** Experimental, may not resolve OpenCode recognition issues.

## Quick Commands

### Using Models with Ollama

```bash
# Interactive chat
ollama run code-buddy

# Single query
echo "Write a hello world function" | ollama run code-buddy

# With specific parameters
ollama run code-buddy "Explain async/await in JavaScript"
```

### Checking Model Status

```bash
# List all models
ollama list

# Show model details
ollama show code-buddy

# Check configuration
ollama show code-buddy --modelfile
```

### OpenCode Usage (if working)

```bash
# Simple task
opencode run "create a file hello.txt" --model ollama/code-buddy:latest

# Interactive mode
opencode --model ollama/code-buddy:latest

# List available models
opencode models
```

## Troubleshooting

### Issue: "does not support tools"

**Quick diagnosis:**
```bash
./test-models.sh
```

If Test 9 passes but Test 8 fails → OpenCode provider issue (not your models).

**See:** `TROUBLESHOOTING.md` for detailed information

### Issue: Model not found

```bash
# Check if model exists
ollama list | grep code-buddy

# If not found, create it
./build-models.sh
```

### Issue: Wrong context size

```bash
# Check current value
ollama show code-buddy --modelfile | grep num_ctx

# Should show: PARAMETER num_ctx 16384

# If different, recreate model
ollama rm code-buddy
ollama create code-buddy -f models/Modelfile.code-buddy
```

### Issue: Ollama not running

```bash
# Check status
curl http://localhost:11434/api/version

# If fails, start Ollama
# (method depends on your installation)
```

## File Structure

```
opencode-modelfiles/
├── models/
│   ├── Modelfile.code-wizard-3000     # 30B parameter model
│   ├── Modelfile.captain-code         # 20B parameter model  
│   ├── Modelfile.dev-ninja            # 24B parameter model
│   ├── Modelfile.code-buddy           # 7B parameter model
│   └── Modelfile.pocket-coder         # 0.8B parameter model
├── scripts/
│   ├── build-models.sh                # Create all models
│   ├── test-models.sh                 # Test suite
│   ├── setup-opencode-config.sh       # OpenCode configuration
│   ├── recreate-models.sh              # Recreate all models
│   └── fix-tool-support.sh            # Fix tool support issues
├── recreate-models.sh                  # Recreate models
├── fix-tool-support.sh                 # Experimental fix
├── opencode.json                       # Model metadata
├── README.md                           # Full documentation
├── TROUBLESHOOTING.md                  # Known issues & solutions
├── AGENTS.md                           # AI agent instructions
└── .github/copilot-instructions.md     # GitHub Copilot guidance
```

## Configuration Files

### OpenCode Provider Config
**Location:** `~/.config/opencode/providers/opencode.json`

**Purpose:** Tells OpenCode about Ollama models

**Status:** Created by setup script, but may not be recognized by OpenCode 1.1.28

### AI SDK Package
**Location:** `~/.config/opencode/node_modules/@ai-sdk/openai-compatible`

**Purpose:** Enables OpenAI-compatible API support

**Install:** Automatic via `setup-opencode-config.sh`

## Model Specifications

| Model | Parameters | Quantization | VRAM | Context | Speed |
|-------|-----------|--------------|------|---------|-------|
| code-wizard-3000 | 30B | Q4_K_M | 18GB | 16K | Slow |
| captain-code | 20B | IQ4_NL | 13GB | 16K | Medium |
| dev-ninja | 24B | Q4_K_M | 16GB | 16K | Medium |
| code-maestro | 30.5B MoE | Q4_K_M | 20GB | 16K | Medium |
| code-buddy | 7B | Q4_K_M | 6GB | 16K | Fast |
| pocket-coder | 0.8B | BF16 | 3GB | 16K | Very Fast |

All models support:
- Tool calling (via API)
- Reasoning capabilities
- Code generation/completion
- Debugging assistance
- Multiple programming languages

## Known Limitations

1. **OpenCode Provider Recognition**: Custom Ollama providers may not be loaded by OpenCode 1.1.28
2. **Tool Support Error**: "does not support tools" despite correct configuration
3. **Workaround**: Use models directly with Ollama CLI or via direct API access

See `TROUBLESHOOTING.md` for complete details and tracking of these issues.

## Getting Help

1. Run diagnostics: `./test-models.sh`
2. Check detailed troubleshooting: `TROUBLESHOOTING.md`
3. Verify model config: `ollama show <model-name> --modelfile`
4. Test API directly: See TROUBLESHOOTING.md for curl examples

## Links

- [OpenCode Documentation](https://opencode.ai/docs)
- [Ollama Documentation](https://ollama.ai/docs)
- [AI SDK Documentation](https://sdk.vercel.ai/docs)
- [GitHub Issue #1068](https://github.com/anomalyco/opencode/issues/1068) - Tool support tracking
