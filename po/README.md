# Translation README

This plasmoid supports internationalization (i18n) with the following languages:

## Supported Languages
- English (en_US) - Default language
- German (de) - Deutsche Übersetzung

## File Structure
```
po/                              # Translation source files
├── gamemodechecker.pot         # Translation template
├── en_US.po                    # English translation source
└── de.po                       # German translation source

locale/                          # Compiled translation files
├── en_US/LC_MESSAGES/
│   └── plasma_applet_org.kde.gamemodechecker.mo
└── de/LC_MESSAGES/
    └── plasma_applet_org.kde.gamemodechecker.mo
```

## Adding New Translations

1. Create a new .po file based on the template:
   ```bash
   cp po/gamemodechecker.pot po/[LANGUAGE_CODE].po
   ```

2. Edit the new .po file and translate all msgstr entries

3. Compile the translation:
   ```bash
   mkdir -p locale/[LANGUAGE_CODE]/LC_MESSAGES/
   msgfmt po/[LANGUAGE_CODE].po -o locale/[LANGUAGE_CODE]/LC_MESSAGES/plasma_applet_org.kde.gamemodechecker.mo
   ```

## Updating Translations

1. Extract new translatable strings:
   ```bash
   ./Messages.sh
   ```

2. Update existing .po files:
   ```bash
   msgmerge -U po/[LANGUAGE_CODE].po po/gamemodechecker.pot
   ```

3. Recompile the .mo files as shown above

## Testing Translations

To test German translation:
```bash
export LANG=de_DE.UTF-8
export LC_MESSAGES=de
```

Then restart the plasmoid to see the German interface.
