#!/bin/bash

# Gamemode Plasmoid Build Script

echo "Building Gamemode Plasmoid..."

# Ensure locale directories exist
mkdir -p locale/en_US/LC_MESSAGES locale/de/LC_MESSAGES
mkdir -p contents/locale/de/LC_MESSAGES contents/locale/en_US/LC_MESSAGES

# Compile translations
echo "Compiling translations..."
msgfmt po/en_US.po -o locale/en_US/LC_MESSAGES/plasma_applet_gamemodechecker.mo 2>/dev/null || echo "English translation compilation failed"
msgfmt po/de.po -o locale/de/LC_MESSAGES/plasma_applet_gamemodechecker.mo 2>/dev/null || echo "German translation compilation failed"

# Copy translations to contents directory for Plasma 6
cp locale/en_US/LC_MESSAGES/plasma_applet_gamemodechecker.mo contents/locale/en_US/LC_MESSAGES/ 2>/dev/null
cp locale/de/LC_MESSAGES/plasma_applet_gamemodechecker.mo contents/locale/de/LC_MESSAGES/ 2>/dev/null

# Create plasmoid package
echo "Creating plasmoid package..."
rm -f gamemodechecker.plasmoid && zip -r gamemodechecker.plasmoid . --exclude \*.git\* --exclude build.sh --exclude \*.md --exclude \*.po --exclude CMakeLists.txt --exclude Messages.sh --exclude po/README.md

echo "Build complete! Install with:"
echo "kpackagetool6 --type Plasma/Applet --install gamemodechecker.plasmoid"
echo ""
echo "Or to update an existing installation:"
echo "kpackagetool6 --type Plasma/Applet --upgrade gamemodechecker.plasmoid"
echo ""
echo "🔧 After installation, restart plasma:"
echo "kquitapp6 plasmashell && plasmashell > /dev/null 2>&1 &"