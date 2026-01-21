# Agent Instructions for Adding New Models

This document provides comprehensive instructions for AI agents when adding new models to the opencode-modelfiles repository.

## Prerequisites

Before adding a new model, ensure you have:
- Access to the model source (Hugging Face or other model hub)
- Model specifications (parameter count, quantization, VRAM requirements)
- Understanding of the model's template format (ChatML, Instruct, etc.)

## Step-by-Step Process

### 1. Create the Modelfile

Create a new Modelfile named `Modelfile.<model-identifier>` in the `models/` directory.

#### Required Modelfile Components

```
# Modelfile for <Model Name>
# Optimized for opencode with AMD Radeon RX 7900 XTX (20 GB)

# Using quantization for optimal balance between quality and VRAM usage
FROM <model-source>

# Context window and performance parameters
PARAMETER num_ctx 40960
PARAMETER num_gpu 99
PARAMETER num_thread 8
PARAMETER temperature 0.7
PARAMETER top_k 40
PARAMETER top_p 0.95
PARAMETER repeat_penalty 1.1
PARAMETER stop "<appropriate-stop-token>"

# System prompt optimized for opencode coding assistant
SYSTEM """You are an autonomous AI coding agent with comprehensive knowledge of software development, algorithms, and best practices across multiple programming languages and frameworks.

Your capabilities include:
- Code generation, completion, and refactoring
- Bug detection and debugging assistance
- Code explanation and documentation
- Architecture and design pattern recommendations
- Performance optimization suggestions
- Security vulnerability analysis
- Test generation and coverage improvement
- API and library usage guidance
- Command-line and tooling assistance
- Git operations and version control
- File system operations and project structure management

When responding:
- Provide clear, well-commented, production-ready code
- Follow language-specific best practices and conventions
- Explain your reasoning when making architectural decisions
- Suggest alternatives when appropriate
- Consider edge cases and error handling
- Prioritize code readability and maintainability
- Include relevant documentation and examples

You have access to tools for file operations, code execution, web search, and more. Use them effectively to provide comprehensive assistance."""

TEMPLATE """<appropriate-template-format>"""
```

#### Hardware Compatibility Requirements

**CRITICAL**: All models must be compatible with AMD Radeon RX 7900 XTX (20 GB total VRAM capacity)

- **Maximum VRAM**: Model must fit within 20 GB total VRAM budget (includes model + context)
- **Recommended quantization**: Q4_K_M or Q6_K for balance between quality and size
- **Context window**: Use `num_ctx 40960` (standard across all models for tool support)
- **GPU utilization**: Set `num_gpu 99` for maximum GPU usage
- **Threading**: Set `num_thread 8` for optimal CPU threading

#### Template Formats

Choose the appropriate template format based on the model:

**ChatML Format** (for Qwen, OpenAI-style models):
```
TEMPLATE """<|im_start|>system
{{ .System }}<|im_end|>
<|im_start|>user
{{ .Prompt }}<|im_end|>
<|im_start|>assistant
"""
```

**Instruct Format** (for Mistral, Devstral models):
```
TEMPLATE """[INST] {{ .System }}

{{ .Prompt }} [/INST]
"""
```

**Llama Format** (for Llama models):
```
TEMPLATE """<s>[INST] <<SYS>>
{{ .System }}
<</SYS>>

{{ .Prompt }} [/INST]"""
```

#### Stop Tokens

Include appropriate stop tokens based on template format:
- ChatML: `<|im_end|>`, `<|endoftext|>`
- Instruct: `[INST]`, `[/INST]`, `</s>`
- Llama: `</s>`, `[/INST]`

### 2. Update scripts/build-models.sh

Add a new entry to the build script:

```bash
# Create <Model Name> - <Brief description>
create_model "models/Modelfile.<model-identifier>" \
    "<fun-name>" \
    "<Creative description>"
```

**Guidelines for naming**:
- Use creative, memorable names (e.g., "code-wizard-3000", "captain-code")
- Keep descriptions concise and engaging
- Maintain alphabetical or size-based ordering

**Update the summary section**:
```bash
echo "Available models:"
echo "  • <fun-name>  - <brief description>"
# ... other models ...
```

### 3. Update opencode.json

Add a comprehensive model entry to the `models` array in `opencode.json`:

```json
{
  "id": "<fun-name>",
  "name": "<Model Display Name>",
  "description": "<Detailed description with use cases>",
  "modelfile": "models/Modelfile.<model-identifier>",
  "source": "<full-model-source-path>",
  "parameters": {
    "num_ctx": 40960,
    "num_gpu": 99,
    "num_thread": 8,
    "temperature": 0.7,
    "top_k": 40,
    "top_p": 0.95,
    "repeat_penalty": 1.1
  },
  "stop_tokens": [
    "<appropriate-stop-tokens>"
  ],
  "template_format": "<ChatML|Instruct|Llama>",
  "quantization": "<Q4_K_M|Q6_K>",
  "size_gb": <model-size-in-gb>,
  "vram_required_gb": <vram-requirement>,
  "capabilities": {
    "tools": true,
    "reasoning": true,
    "autonomous": true,
    "code_generation": true,
    "code_refactoring": true,
    "bug_detection": true,
    "debugging": true,
    "code_explanation": true,
    "documentation": true,
    "architecture_design": true,
    "performance_optimization": true,
    "security_analysis": true,
    "test_generation": true,
    "api_guidance": true,
    "cli_assistance": true,
    "git_operations": true,
    "file_operations": true,
    "web_search": false
  },
  "best_for": [
    "<Primary use case>",
    "<Secondary use case>",
    "<Tertiary use case>"
  ],
  "hardware_requirements": {
    "gpu": "AMD Radeon RX 7900 XTX or equivalent",
    "vram_gb": 20,
    "recommended": true
  }
}
```

#### Capabilities Guidelines

**MUST be enabled for all models**:
- `tools`: true
- `reasoning`: true
- `autonomous`: true
- `code_generation`: true
- `bug_detection`: true
- `debugging`: true
- `code_explanation`: true
- `api_guidance`: true
- `cli_assistance`: true
- `git_operations`: true
- `file_operations`: true

**May vary based on model size/capability**:
- `code_refactoring`: true for models 7B+
- `documentation`: true for models 7B+
- `architecture_design`: true for models 20B+
- `performance_optimization`: true for models 7B+
- `security_analysis`: true for models 7B+
- `test_generation`: true for models 7B+

**Typically disabled**:
- `web_search`: false (requires external integration)

### 4. Update Documentation

#### Update README.md

Add the new model to the "Available Models" section:

```markdown
### <Number>. <Model Name>
- **File**: `models/Modelfile.<model-identifier>`
- **Model**: <full-model-source>
- **Best for**: <primary-use-cases>
```

Update the summary section with the new model count and any relevant details.

If the model introduces new template formats, add documentation to the "Template Formats" section.

#### Update any example commands

If there are example commands that reference specific models, ensure they remain accurate or add examples for the new model.

### 5. Validation Checklist

Before submitting changes, verify:

- [ ] Modelfile created with correct naming convention
- [ ] All required parameters included in Modelfile
- [ ] Parameters compatible with AMD Radeon RX 7900 XTX (20 GB VRAM)
- [ ] System prompt includes tool capabilities mention
- [ ] Appropriate template format selected
- [ ] Correct stop tokens specified
- [ ] scripts/build-models.sh updated with new model entry
- [ ] scripts/build-models.sh summary section updated
- [ ] opencode.json updated with complete model entry
- [ ] All required capabilities set to `true`
- [ ] VRAM requirement does not exceed 20 GB
- [ ] Hardware requirements specify AMD Radeon RX 7900 XTX
- [ ] README.md "Available Models" section updated
- [ ] README.md example count/statistics updated
- [ ] JSON syntax validated (`python3 -m json.tool opencode.json`)
- [ ] Build script syntax validated (`bash -n scripts/build-models.sh`)

### 6. Testing

After making changes, test:

1. **JSON Validation**:
   ```bash
   python3 -m json.tool opencode.json >/dev/null 2>&1 && echo "✅ Valid" || (echo "❌ Invalid"; python3 -m json.tool opencode.json)
   ```

2. **Shell Script Validation**:
   ```bash
   bash -n scripts/build-models.sh && echo "✅ Valid" || echo "❌ Invalid"
   ```

3. **Model Creation** (if Ollama is available):
   ```bash
   ollama create <fun-name> -f models/Modelfile.<model-identifier>
   ```

## Common Pitfalls to Avoid

1. **VRAM Overload**: Do not add models that exceed 20 GB VRAM requirement
2. **Inconsistent Parameters**: All models must use the same standard parameters (num_ctx, num_gpu, temperature, etc.)
3. **Missing Capabilities**: Ensure `tools`, `reasoning`, and `autonomous` are always set to `true`
4. **Wrong Template**: Using incorrect template format will cause model failures
5. **Missing Stop Tokens**: Models without proper stop tokens may not stop generating
6. **Incomplete Updates**: Forgetting to update all four files (Modelfile, scripts/build-models.sh, opencode.json, README.md)

## Model Size Guidelines

- **Ultra-lightweight**: 0.5-2 GB (< 3B parameters)
  - Use Q6_K quantization for better quality
  - Limited capabilities acceptable
  
- **Lightweight**: 3-6 GB (3B-7B parameters)
  - Use Q4_K_M quantization
  - Most capabilities should be enabled
  
- **Medium**: 7-14 GB (7B-20B parameters)
  - Use Q4_K_M quantization
  - All capabilities should be enabled
  
- **Large**: 15-20 GB (20B-30B+ parameters)
  - Use Q4_K_M quantization
  - All capabilities enabled with maximum performance

## Reference Examples

See existing models for reference:
- `models/Modelfile.code-wizard-3000` - Large model with ChatML template
- `models/Modelfile.captain-code` - Large model with ChatML template
- `models/Modelfile.dev-ninja` - Large model with Instruct template
- `models/Modelfile.code-maestro` - Medium model with ChatML template
- `models/Modelfile.code-buddy` - Medium model example
- `models/Modelfile.pocket-coder` - Ultra-lightweight model example

## Questions?

If you encounter issues or have questions about adding a new model, refer to:
- Existing Modelfiles for examples
- opencode.json for capability definitions
- README.md for documentation patterns
