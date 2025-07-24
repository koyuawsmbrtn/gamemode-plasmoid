# Gamemode Status Checker

A KDE Plasma 6 widget that displays the current status of [gamemode](https://github.com/FeralInteractive/gamemode) in your system panel.

## Description

This widget shows a gaming controller icon in your Plasma panel that changes color to indicate whether gamemode is currently active on your system. Gamemode is a daemon/lib combo that allows games to request a set of optimizations be temporarily applied to the host OS and/or a game process.

## Features

- **Visual Status Indicator**: Gaming controller icon that changes color based on gamemode status
- **Real-time Updates**: Polls gamemode status every 2 seconds
- **Theme Integration**: Uses system colors and adapts to light/dark themes
- **Smooth Animations**: Color transitions with smooth animations
- **Memory Efficient**: Proper cleanup to prevent memory leaks

## Visual States

- **Inactive**: Normal system text color icon - gamemode is not running
- **Active**: Bright green (#4ade80) icon - gamemode is currently active

## Requirements

- KDE Plasma 6
- gamemode daemon installed and running
- Qt 6 with QML support
- Kirigami 2.20+

## Installation

1. Copy the entire `gamemodechecker` directory to your Plasma widgets directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids/
   cp -r gamemodechecker ~/.local/share/plasma/plasmoids/
   ```

2. Restart Plasma or reload widgets:
   ```bash
   kquitapp6 plasmashell && plasmashell &
   ```

3. Add the widget to your panel:
   - Right-click on your panel → "Add Widgets..."
   - Search for "Gamemode Status Icon"
   - Add it to your panel

## File Structure

```
gamemodechecker/
├── metadata.json          # Widget metadata and configuration
├── contents/
│   ├── ui/
│   │   └── main.qml      # Main widget interface
│   ├── code/
│   │   └── check.sh      # Gamemode status checking script
└── README.md
```

## How It Works

1. **Status Checking**: The `check.sh` script runs `gamemoded -s` to check gamemode status
2. **Polling**: A QML Timer executes the script every 2 seconds
3. **Visual Update**: Based on script output ("active" or "inactive"), the icon color changes
4. **Memory Management**: Each execution uses a unique command to force fresh results while properly cleaning up previous connections

## Technical Details

- **Icon**: Uses `input-gamepad-symbolic` system icon for broad compatibility
- **Data Source**: Plasma5Support.DataSource with "executable" engine
- **Update Frequency**: 2-second intervals
- **Color Animation**: 200ms smooth color transitions
- **API**: Plasma 6.0+ compatible

## Troubleshooting

### Widget doesn't appear
- Ensure you're running Plasma 6
- Check that the files are in the correct directory structure
- Restart Plasma shell

### Icon shows as square/missing
- The widget falls back to system icons, but you can modify `main.qml` to use different icons
- Try `applications-games` or `input-gaming` as alternatives

### Status not updating
- Verify gamemode is installed: `which gamemoded`
- Check if gamemode daemon is running: `systemctl --user status gamemoded`
- Test the script manually: `bash contents/code/check.sh`

### Permission issues
- Ensure the check.sh script is executable: `chmod +x contents/code/check.sh`

## Development

The widget is built with:
- **QML**: User interface and logic
- **JavaScript**: Data processing and timer management
- **Bash**: System status checking
- **JSON**: Widget metadata

To modify the polling interval, change the `interval` property in the Timer component in `main.qml`.

## License

MIT License - see project files for details.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the widget.

## Author

Created by Leonie (https://leonie.lgbt)
