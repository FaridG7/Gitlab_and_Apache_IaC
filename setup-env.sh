#!/bin/bash

# --- Configuration ---
SOURCE_FILE="example.env"
TARGET_FILE=".env"
TOKEN_VAR="GITLAB_REGISTRATION_TOKEN"

# --- Step 1: Ensure source file exists ---
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: $SOURCE_FILE not found in current directory."
    exit 1
fi

# --- Step 2: Generate a secure random token ---
TOKEN=$(openssl rand -hex 32)
if [ -z "$TOKEN" ]; then
    echo "Error: Failed to generate token."
    exit 1
fi
echo "Generated token: $TOKEN"

# --- Step 3: Copy source to target (overwrites existing .env) ---
cp "$SOURCE_FILE" "$TARGET_FILE"
echo "Copied $SOURCE_FILE → $TARGET_FILE"

# --- Step 4: Replace the token line in .env ---
# The line is exactly "GITLAB_REGISTRATION_TOKEN=" (no spaces around =)
sed -i "s/^$TOKEN_VAR=.*/$TOKEN_VAR=$TOKEN/" "$TARGET_FILE"

# Compatibility: if `sed -i` fails, try macOS style (important for Mac users)
if [ $? -ne 0 ]; then
    # macOS sed requires a backup extension
    sed -i '' "s/^$TOKEN_VAR=.*/$TOKEN_VAR=$TOKEN/" "$TARGET_FILE" 2>/dev/null
fi

# --- Step 5: Verify the replacement ---
if grep -q "^$TOKEN_VAR=$TOKEN" "$TARGET_FILE"; then
    echo "✅ Token successfully written to $TARGET_FILE"
    echo "   Content: $(grep "^$TOKEN_VAR=" "$TARGET_FILE")"
else
    echo "❌ Failed to update token in $TARGET_FILE. Please edit manually."
    exit 1
fi

echo "Ready. Now run: docker compose up -d"

