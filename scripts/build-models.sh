#!/bin/bash

# Build script for creating Ollama models with fun names
# This script creates all models from the Modelfiles in this repository

set -e

echo "🎨 OpenCode Modelfile Builder 🎨"
echo "================================="
echo ""

# Color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create a model
create_model() {
    local modelfile=$1
    local model_name=$2
    local description=$3
    
    echo -e "${BLUE}📦 Creating model: ${YELLOW}${model_name}${NC}"
    echo -e "${BLUE}   Description: ${description}${NC}"
    echo -e "${BLUE}   From: ${modelfile}${NC}"
    
    if ollama create "${model_name}" -f "${modelfile}"; then
        echo -e "${GREEN}✅ Successfully created ${model_name}${NC}"
    else
        echo -e "❌ Failed to create ${model_name}"
        return 1
    fi
    echo ""
}

echo "Creating models with fun names..."
echo ""

# Create Qwen3 Coder 30B - A large, powerful coding assistant
create_model "Modelfile.code-wizard-3000" \
    "code-wizard-3000" \
    "The mighty 30B coding sorcerer"

# Create OpenAI GPT OSS 20B - Unrestricted general purpose
create_model "Modelfile.captain-code" \
    "captain-code" \
    "The fearless 20B coding superhero"

# Create Devstral Small 24B - Balanced development assistant
create_model "Modelfile.dev-ninja" \
    "dev-ninja" \
    "The stealthy 24B development master"

# Create Qwen3 Coder - Standard coding assistant
create_model "Modelfile.code-maestro" \
    "code-maestro" \
    "The versatile coding maestro"

# Create Qwen2.5 Coder 7B - Fast and lightweight
create_model "Modelfile.code-buddy" \
    "code-buddy" \
    "Your friendly 7B coding companion"

# Create Qwen3 Zero Coder 0.8B - Ultra lightweight
create_model "Modelfile.pocket-coder" \
    "pocket-coder" \
    "The tiny but mighty 0.8B code assistant"

echo "================================="
echo -e "${GREEN}🎉 All models created successfully! 🎉${NC}"
echo ""
echo "Available models:"
echo "  • code-wizard-3000  - 30B parameter powerhouse"
echo "  • captain-code      - 20B unrestricted hero"
echo "  • dev-ninja         - 24B balanced master"
echo "  • code-maestro      - Standard versatile coder"
echo "  • code-buddy        - 7B fast companion"
echo "  • pocket-coder      - 0.8B lightweight assistant"
echo ""
echo -e "${YELLOW}🔧 Tool Support Enabled!${NC}"
echo "All models are configured with num_ctx 16384 for OpenCode tool calling."
echo "Each model includes:"
echo "  ✓ File operations"
echo "  ✓ Code execution"
echo "  ✓ Git operations"
echo "  ✓ Reasoning capabilities"
echo ""
echo "To use with OpenCode, configure your opencode.json with:"
echo "  \"tools\": true"
echo "  \"reasoning\": true"
echo ""
echo "Try running: ollama run code-wizard-3000"
echo ""
