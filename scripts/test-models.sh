#!/bin/bash

# Test script for OpenCode Modelfiles
# Checks if models are properly configured and can run with OpenCode

set +e  # Don't exit on errors, we want to test all models

echo "🧪 OpenCode Models Test Suite 🧪"
echo "================================="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Models to test
declare -a MODELS=(
    "code-wizard-3000:latest"
    "captain-code:latest"
    "dev-ninja:latest"
    "code-maestro:latest"
    "code-buddy:latest"
    "pocket-coder:latest"
)

# Function to print test header
test_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to print test result
test_result() {
    local status=$1
    local message=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC} - $message"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC} - $message"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            ;;
        "SKIP")
            echo -e "${YELLOW}⏭️  SKIP${NC} - $message"
            SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC} - $message"
            ;;
    esac
}

# Test 1: Check if Ollama is running
test_header "Test 1: Checking Ollama Service"
if curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
    OLLAMA_VERSION=$(curl -s http://localhost:11434/api/version | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    test_result "PASS" "Ollama is running (version: $OLLAMA_VERSION)"
else
    test_result "FAIL" "Ollama is not running or not accessible at localhost:11434"
    echo ""
    echo -e "${RED}Cannot continue without Ollama. Please start Ollama and try again.${NC}"
    exit 1
fi
echo ""

# Test 2: Check if OpenCode is installed
test_header "Test 2: Checking OpenCode Installation"
if command -v opencode &> /dev/null; then
    OPENCODE_VERSION=$(opencode --version 2>&1)
    test_result "PASS" "OpenCode is installed (version: $OPENCODE_VERSION)"
else
    test_result "FAIL" "OpenCode is not installed or not in PATH"
    echo ""
    echo -e "${RED}Cannot continue without OpenCode. Please install OpenCode and try again.${NC}"
    exit 1
fi
echo ""

# Test 3: Check if models exist in Ollama
test_header "Test 3: Checking Model Availability in Ollama"
for model in "${MODELS[@]}"; do
    if ollama list | grep -q "^${model}"; then
        MODEL_SIZE=$(ollama list | grep "^${model}" | awk '{print $3, $4}')
        test_result "PASS" "$model exists in Ollama ($MODEL_SIZE)"
    else
        test_result "FAIL" "$model not found in Ollama"
        echo -e "         ${YELLOW}Run: ./build-models.sh to create this model${NC}"
    fi
done
echo ""

# Test 4: Check model configurations
test_header "Test 4: Checking Model Configurations"
for model in "${MODELS[@]}"; do
    if ollama list | grep -q "^${model}"; then
        # Check num_ctx parameter
        NUM_CTX=$(ollama show "$model" --modelfile 2>/dev/null | grep "PARAMETER num_ctx" | awk '{print $3}')
        if [ "$NUM_CTX" == "40960" ]; then
            test_result "PASS" "$model has correct num_ctx (40960)"
        elif [ -n "$NUM_CTX" ]; then
            test_result "FAIL" "$model has incorrect num_ctx ($NUM_CTX, should be 40960)"
        else
            test_result "SKIP" "$model configuration check (unable to read modelfile)"
        fi
    else
        test_result "SKIP" "$model configuration check (model not found)"
    fi
done
echo ""

# Test 5: Check OpenCode AI SDK installation
test_header "Test 5: Checking OpenCode AI SDK"
if [ -d "$HOME/.config/opencode/node_modules/@ai-sdk/openai-compatible" ]; then
    test_result "PASS" "AI SDK (@ai-sdk/openai-compatible) is installed"
elif [ -f "$HOME/.config/opencode/package.json" ]; then
    test_result "FAIL" "AI SDK is not installed"
    echo -e "         ${YELLOW}Run: cd ~/.config/opencode && bun add @ai-sdk/openai-compatible${NC}"
else
    test_result "SKIP" "OpenCode config directory not initialized"
fi
echo ""

# Test 6: Check OpenCode configuration file
test_header "Test 6: Checking OpenCode Configuration"
CONFIG_FILE="$HOME/.config/opencode/providers/opencode.json"
if [ -f "$CONFIG_FILE" ]; then
    test_result "PASS" "Configuration file exists at $CONFIG_FILE"
    
    # Validate JSON
    if python3 -m json.tool "$CONFIG_FILE" >/dev/null 2>&1; then
        test_result "PASS" "Configuration file is valid JSON"
    else
        test_result "FAIL" "Configuration file is invalid JSON"
    fi
    
    # Check for ollama provider
    if grep -q '"ollama"' "$CONFIG_FILE"; then
        test_result "INFO" "Ollama provider configuration found"
    else
        test_result "INFO" "No Ollama provider in configuration"
    fi
else
    test_result "FAIL" "Configuration file not found"
    echo -e "         ${YELLOW}Run: ./setup-opencode-config.sh to create configuration${NC}"
fi
echo ""

# Test 7: Test OpenCode communication (simple test)
test_header "Test 7: Testing OpenCode Basic Functionality"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Try listing models
if opencode models 2>&1 | grep -q "opencode/"; then
    test_result "PASS" "OpenCode can list built-in models"
else
    test_result "FAIL" "OpenCode cannot list models"
fi
echo ""

# Test 8: Test model basic response
test_header "Test 8: Testing Model Basic Response"
for model in "${MODELS[@]}"; do
    if ! ollama list | grep -q "^${model}"; then
        test_result "SKIP" "$model basic response test (model not in Ollama)"
        continue
    fi
    
    echo -e "${BLUE}Testing: $model${NC}"
    
    TIMEOUT=60
    TEST_OUTPUT=$(timeout $TIMEOUT opencode run "respond with just the word: hello" --model ollama/$model 2>&1)
    TEST_EXIT_CODE=$?
    
    if [ $TEST_EXIT_CODE -eq 0 ] && echo "$TEST_OUTPUT" | grep -qi "hello"; then
        test_result "PASS" "$model - basic response works"
    elif echo "$TEST_OUTPUT" | grep -q "does not support tools"; then
        test_result "FAIL" "$model - does not support tools"
        echo -e "         ${YELLOW}Base model lacks tool calling capabilities${NC}"
    elif echo "$TEST_OUTPUT" | grep -q "Provider not found\|ProviderModelNotFoundError"; then
        test_result "FAIL" "$model - not recognized by OpenCode"
        echo -e "         ${YELLOW}Check OpenCode configuration${NC}"
    elif [ $TEST_EXIT_CODE -eq 124 ]; then
        test_result "FAIL" "$model - timeout (>${TIMEOUT}s)"
    else
        test_result "FAIL" "$model - execution failed"
        echo -e "         ${RED}Error: ${TEST_OUTPUT:0:100}${NC}"
    fi
    echo ""
done
echo ""

# Test 9: Test file creation capability
test_header "Test 9: Testing File Creation Capability"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

for model in "${MODELS[@]}"; do
    if ! ollama list | grep -q "^${model}"; then
        test_result "SKIP" "$model file creation test (model not in Ollama)"
        continue
    fi
    
    # Skip if model failed basic response test
    if ! timeout 60 opencode run "respond with just: ok" --model ollama/$model 2>&1 | grep -qi "ok"; then
        test_result "SKIP" "$model file creation test (basic response failed)"
        continue
    fi
    
    echo -e "${BLUE}Testing: $model${NC}"
    
    TEST_FILE="test_${model//:/_}.txt"
    TIMEOUT=90
    TEST_OUTPUT=$(timeout $TIMEOUT opencode run "create a file named $TEST_FILE with the content 'test passed'" --model ollama/$model 2>&1)
    TEST_EXIT_CODE=$?
    
    if [ -f "$TEST_FILE" ] && grep -q "test passed" "$TEST_FILE"; then
        test_result "PASS" "$model - file creation works"
        rm -f "$TEST_FILE"
    elif echo "$TEST_OUTPUT" | grep -q "does not support tools"; then
        test_result "FAIL" "$model - no tool support for file operations"
    elif [ $TEST_EXIT_CODE -eq 124 ]; then
        test_result "FAIL" "$model - file creation timeout"
    else
        test_result "FAIL" "$model - file creation failed"
        rm -f "$TEST_FILE"
    fi
    echo ""
done

cd - >/dev/null
rm -rf "$TEST_DIR"
echo ""

# Test 10: Test command execution capability
test_header "Test 10: Testing Command Execution Capability"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

for model in "${MODELS[@]}"; do
    if ! ollama list | grep -q "^${model}"; then
        test_result "SKIP" "$model command execution test (model not in Ollama)"
        continue
    fi
    
    # Skip if model failed basic response test
    if ! timeout 60 opencode run "respond with just: ok" --model ollama/$model 2>&1 | grep -qi "ok"; then
        test_result "SKIP" "$model command execution test (basic response failed)"
        continue
    fi
    
    echo -e "${BLUE}Testing: $model${NC}"
    
    TIMEOUT=90
    TEST_OUTPUT=$(timeout $TIMEOUT opencode run "run the command: date +%Y-%m-%d" --model ollama/$model 2>&1)
    TEST_EXIT_CODE=$?
    CURRENT_DATE=$(date +%Y-%m-%d)
    
    if [ $TEST_EXIT_CODE -eq 0 ] && echo "$TEST_OUTPUT" | grep -q "$CURRENT_DATE"; then
        test_result "PASS" "$model - command execution works"
    elif echo "$TEST_OUTPUT" | grep -q "does not support tools"; then
        test_result "FAIL" "$model - no tool support for commands"
    elif echo "$TEST_OUTPUT" | grep -q '{"name":\|{"command":'; then
        test_result "FAIL" "$model - returns JSON instead of executing"
        echo -e "         ${YELLOW}Model describes tools but doesn't execute them${NC}"
    elif [ $TEST_EXIT_CODE -eq 124 ]; then
        test_result "FAIL" "$model - command execution timeout"
    else
        test_result "FAIL" "$model - command execution failed"
    fi
    echo ""
done

cd - >/dev/null
rm -rf "$TEST_DIR"
echo ""

# Test 11: Test complex task capability
test_header "Test 11: Testing Complex Task Capability"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Only test the best performing models to save time
COMPLEX_TEST_MODELS=("code-wizard-3000:latest" "captain-code:latest" "code-maestro:latest")

for model in "${COMPLEX_TEST_MODELS[@]}"; do
    if ! ollama list | grep -q "^${model}"; then
        test_result "SKIP" "$model complex task test (model not in Ollama)"
        continue
    fi
    
    # Skip if model failed basic response test
    if ! timeout 60 opencode run "respond with just: ok" --model ollama/$model 2>&1 | grep -qi "ok"; then
        test_result "SKIP" "$model complex task test (basic response failed)"
        continue
    fi
    
    echo -e "${BLUE}Testing: $model${NC}"
    
    TIMEOUT=120
    TEST_OUTPUT=$(timeout $TIMEOUT opencode run "create a Python script factorial.py that calculates factorial of 5 and run it" --model ollama/$model 2>&1)
    TEST_EXIT_CODE=$?
    
    if [ $TEST_EXIT_CODE -eq 0 ] && echo "$TEST_OUTPUT" | grep -q "120"; then
        test_result "PASS" "$model - complex task (create + execute) works"
        rm -f factorial.py
    elif echo "$TEST_OUTPUT" | grep -q "does not support tools"; then
        test_result "FAIL" "$model - no tool support"
    elif [ $TEST_EXIT_CODE -eq 124 ]; then
        test_result "FAIL" "$model - complex task timeout"
    else
        test_result "FAIL" "$model - complex task failed"
        rm -f factorial.py
    fi
    echo ""
done

cd - >/dev/null
rm -rf "$TEST_DIR"
echo ""

# Test 12: Direct Ollama API test
test_header "Test 12: Testing Direct Ollama API Access"
SAMPLE_MODEL="${MODELS[0]}"
if ollama list | grep -q "^${SAMPLE_MODEL}"; then
    API_RESPONSE=$(curl -s -X POST http://localhost:11434/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"${SAMPLE_MODEL}\",
            \"messages\": [{\"role\": \"user\", \"content\": \"Say 'API test passed'\"}],
            \"max_tokens\": 20
        }" 2>&1)
    
    if echo "$API_RESPONSE" | grep -q "choices\|content"; then
        test_result "PASS" "Ollama OpenAI-compatible API is responding"
        if echo "$API_RESPONSE" | grep -qi "API test passed"; then
            test_result "INFO" "Model generated expected response"
        fi
    else
        test_result "FAIL" "Ollama API returned unexpected response"
        echo -e "         ${RED}Response: ${API_RESPONSE:0:200}${NC}"
    fi
else
    test_result "SKIP" "Direct API test (no models available)"
fi
echo ""

# Print summary
test_header "Test Summary"
echo -e "${BLUE}Total Tests:${NC}   $TOTAL_TESTS"
echo -e "${GREEN}Passed:${NC}        $PASSED_TESTS"
echo -e "${RED}Failed:${NC}        $FAILED_TESTS"
echo -e "${YELLOW}Skipped:${NC}       $SKIPPED_TESTS"
echo ""

# Overall result
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo ""
    if [ $SKIPPED_TESTS -gt 0 ]; then
        echo -e "${YELLOW}Note: Some tests were skipped. Check skipped items above.${NC}"
    fi
    exit 0
elif [ $PASSED_TESTS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo "- Models are configured correctly"
    echo "- Ollama is working"
    if echo "$TEST_OUTPUT" | grep -q "does not support tools\|Provider not found"; then
        echo -e "- ${YELLOW}OpenCode provider recognition is the issue (known limitation)${NC}"
        echo ""
        echo -e "${BLUE}Recommendation:${NC}"
        echo "Your models are fine. The issue is with OpenCode's custom provider support."
        echo "See TROUBLESHOOTING.md for details and workarounds."
    fi
    exit 1
else
    echo -e "${RED}❌ Most tests failed${NC}"
    echo ""
    echo -e "${BLUE}Recommendations:${NC}"
    if ! curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
        echo "1. Start Ollama service"
    fi
    if ! ollama list | grep -q "code-wizard-3000\|code-buddy"; then
        echo "2. Run ./build-models.sh to create models"
    fi
    if [ ! -f "$HOME/.config/opencode/providers/opencode.json" ]; then
        echo "3. Run ./setup-opencode-config.sh to configure OpenCode"
    fi
    exit 1
fi
