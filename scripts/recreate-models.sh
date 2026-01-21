#!/bin/bash

# Script to recreate Ollama models with updated tool support settings
# This removes existing models and recreates them with num_ctx 16384

set -e

echo "🔧 Model Recreation Script - Tool Support Fix 🔧"
echo "================================================"
echo ""

# Color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to recreate a model
recreate_model() {
    local modelfile=$1
    local model_name=$2
    local description=$3
    
    echo -e "${BLUE}🔄 Recreating model: ${YELLOW}${model_name}${NC}"
    echo -e "${BLUE}   Description: ${description}${NC}"
    echo -e "${BLUE}   From: ${modelfile}${NC}"
    
    # Remove existing model if it exists
    if ollama list | grep -q "^${model_name}"; then
        echo -e "${YELLOW}   Removing old version...${NC}"
        ollama rm "${model_name}" 2>/dev/null || true
    fi
    
    # Create new model with updated settings
    if ollama create "${model_name}" -f "${modelfile}"; then
        echo -e "${GREEN}✅ Successfully recreated ${model_name}${NC}"
        
        # Verify tool support
        echo -e "${BLUE}   Verifying tool support...${NC}"
        if ollama show "${model_name}" | grep -q "tools"; then
            echo -e "${GREEN}   ✓ Tool support confirmed!${NC}"
        else
            echo -e "${YELLOW}   ⚠ Warning: Tool capability not shown (may still work)${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to recreate ${model_name}${NC}"
        return 1
    fi
    echo ""
}

echo "This script will recreate your models with proper tool support."
echo "Old models will be removed and recreated with num_ctx 16384."
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi
echo ""

# Recreate all models
recreate_model "Modelfile.code-wizard-3000" \
    "code-wizard-3000" \
    "The mighty 30B coding sorcerer"

recreate_model "Modelfile.captain-code" \
    "captain-code" \
    "The fearless 20B coding superhero"

recreate_model "Modelfile.dev-ninja" \
    "dev-ninja" \
    "The stealthy 24B development master"

recreate_model "Modelfile.code-maestro" \
    "code-maestro" \
    "The versatile coding maestro"

recreate_model "Modelfile.code-buddy" \
    "code-buddy" \
    "Your friendly 7B coding companion"

recreate_model "Modelfile.pocket-coder" \
    "pocket-coder" \
    "The tiny but mighty 0.8B code assistant"

echo "================================================"
echo -e "${GREEN}🎉 All models recreated successfully! 🎉${NC}"
echo ""
echo "Your models now support tools with num_ctx 16384!"
echo ""
echo "Test tool support with:"
echo "  opencode run \"create a file test.txt with content 'hello'\" --model ollama/code-buddy"
echo ""
