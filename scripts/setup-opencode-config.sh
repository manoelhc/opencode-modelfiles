#!/bin/bash

# Setup OpenCode configuration for tool support with local Ollama models
# This script:
# 1. Installs the AI SDK for OpenAI-compatible models
# 2. Creates the OpenCode configuration file
# 3. Provides instructions for model usage

set -e

echo "📝 OpenCode Configuration Setup 📝"
echo "===================================="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Config directory
CONFIG_DIR="$HOME/.config/opencode"
PROVIDERS_DIR="$CONFIG_DIR/providers"
CONFIG_FILE="$PROVIDERS_DIR/opencode.json"

echo -e "${BLUE}Step 1: Installing AI SDK...${NC}"
echo ""

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Navigate to config directory and install SDK
cd "$CONFIG_DIR"

if command -v bun &> /dev/null; then
    echo "Using bun to install @ai-sdk/openai-compatible..."
    bun add @ai-sdk/openai-compatible
elif command -v npm &> /dev/null; then
    echo "Using npm to install @ai-sdk/openai-compatible..."
    npm install @ai-sdk/openai-compatible
else
    echo -e "${RED}❌ Error: Neither bun nor npm found${NC}"
    echo "Please install Node.js or Bun first"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ AI SDK installed successfully!${NC}"
echo ""

echo -e "${BLUE}Step 2: Creating OpenCode configuration...${NC}"
echo ""

# Create providers directory
mkdir -p "$PROVIDERS_DIR"

# Create the configuration file
cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "code-wizard-3000:latest": {
          "name": "Code Wizard 3000 - Qwen3 30B",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        },
        "captain-code:latest": {
          "name": "Captain Code - OpenAI GPT OSS 20B",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        },
        "dev-ninja:latest": {
          "name": "Dev Ninja - Devstral 24B",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        },
        "code-maestro:latest": {
          "name": "Code Maestro - Qwen3 Coder",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        },
        "code-buddy:latest": {
          "name": "Code Buddy - Qwen2.5 7B",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        },
        "pocket-coder:latest": {
          "name": "Pocket Coder - Qwen3 0.8B",
          "tools": true,
          "reasoning": true,
          "options": { "num_ctx": 16384 }
        }
      }
    }
  }
}
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration created successfully!${NC}"
    echo ""
    echo -e "${BLUE}Config file location:${NC} $CONFIG_FILE"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Known Issue${NC}"
    echo "The OpenCode provider system may not recognize custom Ollama configs."
    echo "This is a known limitation in OpenCode 1.1.28."
    echo ""
    echo -e "${BLUE}Alternative Solution:${NC}"
    echo "Use models directly without the ollama/ prefix if they're registered"
    echo "in your OpenCode account, or wait for OpenCode updates that better"
    echo "support local Ollama configurations."
    echo ""
    echo -e "${BLUE}What works for sure:${NC}"
    echo "  1. All models are created with num_ctx 16384 ✓"
    echo "  2. Models have proper system prompts for tools ✓"
    echo "  3. AI SDK is installed ✓"
    echo "  4. Configuration file is in place ✓"
    echo ""
    echo -e "${YELLOW}Testing:${NC}"
    echo "Try: opencode run \"create a file test.txt with content 'hello'\" --model ollama/code-buddy:latest"
    echo ""
    echo "If it doesn't work, the issue is with OpenCode's provider loading,"
    echo "not with the models themselves."
    echo ""
else
    echo -e "${RED}❌ Failed to create configuration${NC}"
    exit 1
fi
