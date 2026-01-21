#!/bin/bash

# Fix tool support for Ollama models by setting num_ctx parameter
# This script sets the context window for each model and saves it

set -e

echo "🔧 Tool Support Fix Script 🔧"
echo "=============================="
echo ""
echo "This script will configure each model with num_ctx 16384"
echo "for proper tool support in OpenCode."
echo ""

# Color codes for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Array of models to fix
models=(
    "code-wizard-3000"
    "captain-code"
    "dev-ninja"
    "code-maestro"
    "code-buddy"
    "pocket-coder"
)

# Function to fix a model's tool support
fix_model() {
    local model_name=$1
    
    echo -e "${BLUE}🔧 Fixing: ${YELLOW}${model_name}${NC}"
    
    # Use expect-like functionality with here-document
    {
        sleep 1
        echo "/set parameter num_ctx 16384"
        sleep 1
        echo "/save ${model_name}:latest"
        sleep 1
        echo "/bye"
        sleep 1
    } | ollama run "${model_name}:latest" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully fixed ${model_name}${NC}"
    else
        echo -e "${RED}❌ Failed to fix ${model_name}${NC}"
        echo -e "${YELLOW}   Try manually: ollama run ${model_name}:latest${NC}"
        echo -e "${YELLOW}   Then run: /set parameter num_ctx 16384${NC}"
        echo -e "${YELLOW}   Then run: /save ${model_name}:latest${NC}"
        echo -e "${YELLOW}   Then run: /bye${NC}"
        return 1
    fi
    echo ""
}

echo "Fixing models..."
echo ""

for model in "${models[@]}"; do
    fix_model "$model"
done

echo "=============================="
echo -e "${GREEN}🎉 All models fixed! 🎉${NC}"
echo ""
echo "Your models now have proper tool support configured!"
echo ""
echo "Test with:"
echo "  opencode run \"create a file test.txt with content 'hello'\" --model ollama/code-buddy:latest"
echo ""
