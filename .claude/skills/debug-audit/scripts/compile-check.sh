#!/bin/bash
# compile-check.sh — Pre-flight compilation verification for debug audit
# Detects project type and runs appropriate compilation checks

set -e

echo "🔍 Running compilation checks..."
echo ""

# Track if any checks were run
CHECKS_RUN=0
ERRORS=0

# TypeScript/JavaScript check
if [ -f "tsconfig.json" ]; then
    echo "📘 TypeScript project detected"
    echo "Running: npx tsc --noEmit"
    if npx tsc --noEmit 2>&1; then
        echo "✅ TypeScript compilation passed"
    else
        echo "❌ TypeScript compilation failed"
        ERRORS=$((ERRORS + 1))
    fi
    CHECKS_RUN=$((CHECKS_RUN + 1))
    echo ""
fi

# ESLint check
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
    echo "🔎 ESLint config detected"
    echo "Running: npm run lint (if available)"
    if npm run lint 2>&1; then
        echo "✅ ESLint passed"
    else
        echo "⚠️ ESLint found issues (may be warnings)"
    fi
    CHECKS_RUN=$((CHECKS_RUN + 1))
    echo ""
fi

# Python check
PYTHON_FILES=$(find . -name "*.py" \
    -not -path "./node_modules/*" \
    -not -path "./.venv/*" \
    -not -path "./__pycache__/*" \
    -not -path "./env/*" \
    -not -path "./.env/*" \
    2>/dev/null | head -1)

if [ -n "$PYTHON_FILES" ]; then
    echo "🐍 Python files detected"
    echo "Running: syntax check on all .py files"
    
    PYTHON_ERRORS=0
    while IFS= read -r file; do
        if ! python3 -m py_compile "$file" 2>&1; then
            echo "❌ Syntax error in: $file"
            PYTHON_ERRORS=$((PYTHON_ERRORS + 1))
        fi
    done < <(find . -name "*.py" \
        -not -path "./node_modules/*" \
        -not -path "./.venv/*" \
        -not -path "./__pycache__/*" \
        -not -path "./env/*" \
        -not -path "./.env/*" \
        2>/dev/null)
    
    if [ $PYTHON_ERRORS -eq 0 ]; then
        echo "✅ Python syntax check passed"
    else
        echo "❌ Python syntax check failed ($PYTHON_ERRORS errors)"
        ERRORS=$((ERRORS + PYTHON_ERRORS))
    fi
    CHECKS_RUN=$((CHECKS_RUN + 1))
    echo ""
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $CHECKS_RUN -eq 0 ]; then
    echo "⚠️ No compilation checks applicable to this project"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "✅ All compilation checks passed ($CHECKS_RUN checks)"
    exit 0
else
    echo "❌ Compilation failed ($ERRORS errors in $CHECKS_RUN checks)"
    echo ""
    echo "Fix compilation errors before proceeding with audit."
    exit 1
fi
