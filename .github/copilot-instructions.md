# GitHub Copilot Instructions for OpenCode Modelfiles

## Repository Purpose

This repository maintains Ollama Modelfiles for AI coding assistants optimized for:
- **Hardware**: AMD Radeon RX 7900 XTX (20 GB VRAM)
- **Framework**: OpenCode with tool integration
- **Use Case**: Local AI coding assistance with autonomous capabilities

## When Adding a New Model

You MUST follow these steps in order when adding a new model to this repository:

### 1. Create the Modelfile

**File naming**: `Modelfile.<model-identifier>` (use lowercase with hyphens)

**Required structure**:
```
# Modelfile for <Model Name>
# Optimized for opencode with AMD Radeon RX 7900 XTX (20 GB)

FROM <model-source>

# REQUIRED: Standard parameters for all models
PARAMETER num_ctx 16384        # Fixed: 16K context window
PARAMETER num_gpu 99           # Fixed: Maximum GPU utilization
PARAMETER num_thread 8         # Fixed: 8 threads
PARAMETER temperature 0.7      # Fixed: Balanced creativity
PARAMETER top_k 40             # Fixed: Top-k sampling
PARAMETER top_p 0.95          # Fixed: Nucleus sampling
PARAMETER repeat_penalty 1.1   # Fixed: Repetition control
PARAMETER stop "<stop-token>"  # Model-specific

SYSTEM """<standard-system-prompt>"""

TEMPLATE """<model-specific-template>"""
```

**Hardware constraints**:
- Model + context must fit in ≤20 GB VRAM
- Prefer Q4_K_M quantization (balance quality/size)
- Use Q6_K only for ultra-small models (<2B)
- Calculate VRAM: model size + (context tokens × 2 bytes × layers)

**System prompt requirements**:
- MUST mention tool capabilities
- MUST include standard capability list (see existing Modelfiles)
- Keep consistent with other models

**Template format selection**:
- **ChatML**: Qwen, OpenAI-style models
  ```
  <|im_start|>system\n{{ .System }}<|im_end|>\n<|im_start|>user\n{{ .Prompt }}<|im_end|>\n<|im_start|>assistant\n
  ```
- **Instruct**: Mistral, Devstral models
  ```
  [INST] {{ .System }}\n\n{{ .Prompt }} [/INST]
  ```
- **Llama**: Llama models
  ```
  <s>[INST] <<SYS>>\n{{ .System }}\n<</SYS>>\n\n{{ .Prompt }} [/INST]
  ```

### 2. Update build-models.sh

Add model creation entry maintaining size order (largest to smallest):

```bash
# Create <Model Name> - <Brief description>
create_model "Modelfile.<model-identifier>" \
    "<fun-creative-name>" \
    "<Engaging description>"
```

**Naming guidelines**:
- Creative, memorable names (e.g., "code-wizard-3000")
- Consistent style with existing names
- Reflect model personality/capability

Update the summary section:
```bash
echo "Available models:"
echo "  • <fun-name>  - <size>B parameter description"
```

### 3. Update opencode.json

Add complete model entry to `models` array:

**Required fields** (ALL must be present):
```json
{
  "id": "<fun-name>",
  "name": "<Display Name>",
  "description": "<Full description with use cases>",
  "modelfile": "Modelfile.<model-identifier>",
  "source": "<complete-model-path>",
  "parameters": {
    "num_ctx": 16384,
    "num_gpu": 99,
    "num_thread": 8,
    "temperature": 0.7,
    "top_k": 40,
    "top_p": 0.95,
    "repeat_penalty": 1.1
  },
  "stop_tokens": ["<tokens>"],
  "template_format": "<ChatML|Instruct|Llama>",
  "quantization": "<Q4_K_M|Q6_K>",
  "size_gb": <float>,
  "vram_required_gb": <integer>,
  "capabilities": {
    "tools": true,              // REQUIRED: Always true
    "reasoning": true,          // REQUIRED: Always true
    "autonomous": true,         // REQUIRED: Always true
    "code_generation": true,    // REQUIRED: Always true
    "code_refactoring": <bool>, // true for 7B+
    "bug_detection": true,      // REQUIRED: Always true
    "debugging": true,          // REQUIRED: Always true
    "code_explanation": true,   // REQUIRED: Always true
    "documentation": <bool>,    // true for 7B+
    "architecture_design": <bool>, // true for 20B+
    "performance_optimization": <bool>, // true for 7B+
    "security_analysis": <bool>,        // true for 7B+
    "test_generation": <bool>,          // true for 7B+
    "api_guidance": true,       // REQUIRED: Always true
    "cli_assistance": true,     // REQUIRED: Always true
    "git_operations": true,     // REQUIRED: Always true
    "file_operations": true,    // REQUIRED: Always true
    "web_search": false         // Always false (not implemented)
  },
  "best_for": [
    "<Primary use case>",
    "<Secondary use case>",
    "<Tertiary use case>"
  ],
  "hardware_requirements": {
    "gpu": "AMD Radeon RX 7900 XTX or equivalent",
    "vram_gb": 20,
    "recommended": <bool> // true for recommended GPU
  }
}
```

**Capability rules**:
- `tools`, `reasoning`, `autonomous`: ALWAYS `true`
- Core capabilities: ALWAYS `true` (code_generation, bug_detection, debugging, code_explanation, api_guidance, cli_assistance, git_operations, file_operations)
- Size-dependent: Set based on parameter count (see above)
- `web_search`: ALWAYS `false`

### 4. Update README.md

Add to "Available Models" section:
```markdown
### <Number>. <Model Name>
- **File**: `Modelfile.<model-identifier>`
- **Model**: <source-path> (<quantization>)
- **Best for**: <primary-use-cases>
```

Update:
- Model count in overview
- Template format section (if new format)
- Any example commands referencing model lists

## Validation Steps

Before committing, ALWAYS:

1. **Validate JSON**:
   ```bash
   python3 -m json.tool opencode.json > /dev/null
   ```

2. **Validate shell script**:
   ```bash
   bash -n build-models.sh
   ```

3. **Check file consistency**:
   - Modelfile exists
   - Referenced in build-models.sh
   - Entry in opencode.json
   - Documented in README.md

4. **Verify parameters**:
   - All standard parameters present
   - num_ctx = 16384
   - num_gpu = 99
   - num_thread = 8
   - temperature = 0.7
   - top_k = 40
   - top_p = 0.95
   - repeat_penalty = 1.1

5. **Check capabilities**:
   - `tools`, `reasoning`, `autonomous` = true
   - Core capabilities = true
   - Size-appropriate capabilities set correctly

## Common Mistakes to Avoid

❌ **DON'T**:
- Add models requiring >20 GB VRAM
- Use different parameter values than the standard
- Set `tools`, `reasoning`, or `autonomous` to `false`
- Forget to update all 4 files
- Use inconsistent naming between files
- Skip JSON validation
- Add web_search capability (not implemented)

✅ **DO**:
- Verify VRAM requirements fit within 20 GB budget
- Use standard parameters across all models
- Enable required capabilities
- Update all files consistently
- Test JSON and shell script syntax
- Follow existing naming conventions
- Document thoroughly

## Hardware Compatibility

**Target GPU**: AMD Radeon RX 7900 XTX
- **VRAM**: 20 GB
- **Optimization**: Set num_gpu = 99 for maximum utilization

**Quantization recommendations**:
- 0.5-2B params: Q6_K (higher quality, small enough)
- 3B-30B params: Q4_K_M (best balance)
- 30B+ params: Q4_K_S or Q3_K_M (if needed)

**VRAM calculation**:
- Base model size (from GGUF file)
- Context overhead: ~2-4 GB for 16K context
- Safety margin: 10-15% headroom
- Total must be ≤20 GB

## OpenCode Integration

All models MUST:
- Support tool calling (mentioned in system prompt)
- Enable reasoning capabilities
- Allow autonomous operation
- Work with 16K context window
- Use consistent temperature/sampling

System prompt MUST include:
- Tool capability mention
- Standard capability list
- Response guidelines
- Code quality standards

## Template Format Reference

**ChatML** (Qwen, OpenAI-style):
```
<|im_start|>system
{{ .System }}<|im_end|>
<|im_start|>user
{{ .Prompt }}<|im_end|>
<|im_start|>assistant
```
Stop tokens: `<|im_end|>`, `<|endoftext|>`

**Instruct** (Mistral, Devstral):
```
[INST] {{ .System }}

{{ .Prompt }} [/INST]
```
Stop tokens: `[INST]`, `[/INST]`, `</s>`

**Llama**:
```
<s>[INST] <<SYS>>
{{ .System }}
<</SYS>>

{{ .Prompt }} [/INST]
```
Stop tokens: `</s>`, `[/INST]`

## Examples

See existing models:
- `Modelfile.qwen3-coder-30b` - Large ChatML model
- `Modelfile.devstral-small-24b` - Large Instruct model
- `Modelfile.qwen2.5-coder-7b` - Medium model
- `Modelfile.qwen3-zero-coder-0.8b` - Ultra-light model

## Quick Reference Checklist

When adding a model, check off:
- [ ] Modelfile created with standard parameters
- [ ] VRAM requirement ≤20 GB
- [ ] System prompt includes tool mentions
- [ ] Correct template format for model family
- [ ] Appropriate stop tokens
- [ ] build-models.sh entry added
- [ ] build-models.sh summary updated
- [ ] opencode.json entry complete
- [ ] All required capabilities = true
- [ ] Size-appropriate optional capabilities set
- [ ] README.md "Available Models" updated
- [ ] README.md statistics updated
- [ ] JSON validated
- [ ] Shell script validated
- [ ] All 4 files consistent

## Questions?

Refer to:
- AGENTS.md for detailed instructions
- Existing Modelfiles for examples
- opencode.json for structure reference
- README.md for documentation patterns
