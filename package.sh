#!/usr/bin/env bash

# Package rubister for distribution
set -e

VERSION=${1:-"0.0.q"}
PACKAGE_NAME="rubister-${VERSION}"

echo "Packaging rubister version ${VERSION}..."

# Rebuild bundle without development gems for better Ruby version compatibility
echo "Building standalone bundle (production gems only)..."
bundle config set --local without 'development'
bundle install --standalone

# Create a clean staging directory
STAGING_DIR=".package-staging"
rm -rf "${STAGING_DIR}"
rm -f "${PACKAGE_NAME}.tar.gz"
mkdir -p "${STAGING_DIR}"

echo "Copying application files..."
# Copy all Ruby files and tools
cp -r *.rb tools "${STAGING_DIR}/"

# Copy the standalone bundle
echo "Copying standalone bundle..."
cp -r bundle "${STAGING_DIR}/"

# Copy the wrapper script
cp rubister "${STAGING_DIR}/"
chmod +x "${STAGING_DIR}/rubister"

# Copy format_output if it exists
if [ -f format_output.rb ]; then
    cp format_output.rb "${STAGING_DIR}/"
    chmod +x "${STAGING_DIR}/format_output.rb"
fi

# Create a README for the package
cat > "${STAGING_DIR}/README.txt" << 'EOF'
Rubister - AI Agent for File Operations

## Requirements
- Ruby 3.0 or higher (check with: ruby --version)
- Note: Package works across different Ruby 3.x versions (3.0, 3.1, 3.2, 3.3, 3.4, etc.)

## Installation
1. Extract this archive
2. Add the directory to your PATH, or create a symlink:
   ln -s /path/to/rubister /usr/local/bin/rubister

## Usage
Basic usage:
  ./rubister -m "your message here"

Interactive mode:
  ./rubister

With formatting:
  ./rubister -m "your message" | ./format_output.rb

For more options:
  ./rubister --help

## Configuration
Rubister looks for authentication in ~/.local/share/opencode/auth.json
or you can provide auth via --auth flag.

For more information, visit: https://github.com/Hyper-Unearthing/rubister
EOF

echo "Creating archive..."
# Rename staging dir to final package name for proper tar structure
mv "${STAGING_DIR}" "${PACKAGE_NAME}"
tar -czf "${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"

echo "Cleaning up..."
rm -rf "${PACKAGE_NAME}"

# Reset bundle config
bundle config unset --local without

echo ""
echo "✓ Package created: ${PACKAGE_NAME}.tar.gz"
echo ""
echo "To test the package:"
echo "  tar -xzf ${PACKAGE_NAME}.tar.gz"
echo "  cd ${PACKAGE_NAME}"
echo "  ./rubister --help"
echo ""
echo "Package structure: ${PACKAGE_NAME}/rubister"
echo ""
echo "Users can extract and run it with Ruby installed!"
