# Development Environment Setup

This repository contains scripts and configuration files to set up a development environment for macOS. It's tailored for software development, focusing on a clean, minimal, and efficient setup.

## YouTube Video Walkthrough

Click on the image below to watch the video on YouTube:

[![Watch the video](https://img.youtube.com/vi/ra5kMCXO-6I/0.jpg)](https://youtu.be/ra5kMCXO-6I)

## Overview

The setup includes automated scripts for installing essential software, configuring Bash and Zsh shells, and setting up Visual Studio Code. This guide will help you replicate my development environment on your machine if you desire to do so.

## Important Note Before Installation

**WARNING:** The configurations and scripts in this repository are **HIGHLY PERSONALIZED** to my own preferences and workflows. If you decide to use them, please be aware that they will **MODIFY** your current system.

If you would like a development environment similar to mine, I highly encourage you to fork this repository and make your own personalized changes to these scripts instead of running them exactly as I have them written for myself.

I likely won't accept pull requests unless they align closely with my personal preferences and the way I use my development environment. But if there are some obvious errors in my scripts then corrections would be welcome!

If you choose to run these scripts, please do so with **EXTREME CAUTION**. It's recommended to review the scripts and understand the changes they will make to your system before proceeding.

By using these scripts, you acknowledge and accept the risk of potential data loss or system alteration. Proceed at your own risk.

## Getting Started

### Prerequisites

- macOS (The scripts are tailored for macOS)
- A fresh Mac or one you're comfortable modifying

### Step-by-Step Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/adamontherun/dotfiles.git ~/dotfiles
   ```

2. **Navigate to the dotfiles directory:**
   ```bash
   cd ~/dotfiles
   ```

3. **Run the installation script:**
   ```bash
   ./install.sh
   ```

4. **Follow the prompts:**
   - Accept the Xcode Command Line Tools installation dialog
   - Enter your full name and email for Git configuration
   - Copy your SSH public key to GitHub when prompted
   - Import the Terminal profile when prompted
   - Sign in to your apps (Chrome, Spotify, Discord, etc.)

5. **Restart your terminal** to ensure all changes take effect

## What This Script Does

The installation script automates the following:

### System Configuration
- Installs Xcode Command Line Tools (with GUI prompt)
- Installs Rosetta 2 (for Apple Silicon Macs)
- Configures macOS preferences (see [macOS Preferences](#macos-preferences) below)

### Dotfiles & Shell
- Creates symlinks for shell configuration files (`.zshrc`, `.bashrc`, `.aliases`, etc.)
- Sets Homebrew's zsh as the default shell

### Development Tools
- Installs Homebrew package manager
- Installs CLI tools and applications (see [What Gets Installed](#what-gets-installed) below)
- Installs fonts (Source Code Pro, Lato, Montserrat, etc.)

### Git Configuration
- Sets your Git username and email
- Configures Git defaults:
  - Default branch: `main`
  - Pull strategy: `merge` (not rebase)
  - Editor: VS Code (`code --wait`)

### SSH Key
- Generates an Ed25519 SSH key if one doesn't exist
- Displays the public key for you to add to GitHub

### Version Managers
- Installs asdf version manager
- Installs latest versions of:
  - Python
  - Node.js
  - Ruby

### Global Packages
- npm: Prettier, Claude Code
- gem: Cocoapods

### Editor Configuration
- Symlinks VS Code settings and keybindings

## What Gets Installed

### CLI Tools (via Homebrew)
- **Version Management:** asdf
- **Shells:** bash, zsh
- **Version Control:** git, git-lfs
- **Databases:** postgresql@16, mysql, redis, neo4j
- **Cloud Tools:** awscli, render-cli, terraform
- **Languages:** dart, python (via asdf), nodejs (via asdf), ruby (via asdf)
- **Package Managers:** poetry, composer, uv
- **Image Processing:** pngquant, jpegoptim, svgo, optipng
- **Code Quality:** pylint, black
- **Utilities:** tree, coreutils, curl, wget, ngrok

### Applications (via Homebrew Cask)
- **Editors:** Visual Studio Code
- **AI Tools:** Amazon Q, Granola, Claude Code (CLI)
- **Development:** Docker, Android Studio, Flutter, dotnet-sdk, GitHub Desktop, Postman, Charles, TablePlus, DBeaver, DB Browser for SQLite, React Native Debugger
- **Communication:** Slack, Discord, Zoom, Microsoft Teams
- **Browsers:** Google Chrome
- **Productivity:** Notion, Spotify, Microsoft Excel
- **Utilities:** OBS, Private Internet Access, VirtualBox

### Fonts
- Source Code Pro
- Lato
- Montserrat
- Nunito
- Open Sans
- Oswald
- Poppins
- Raleway
- Roboto

## macOS Preferences

The script configures the following macOS settings:

### Finder
- Show all file extensions
- Show hidden files

### Dock
- Auto-hide enabled
- Faster auto-hide animation (no delay)

### Keyboard
- Faster key repeat rate
- Shorter delay before key repeat starts

### Screenshots
- Save location: `~/Desktop/Screenshots`

### Trackpad/Mouse
- Disable "natural" scroll direction

### Menu Bar
- Show Bluetooth icon (for battery percentages)

## Configuration Files

### Shell Configuration
- `.zshrc`: Main zsh configuration with history, completion, and options
- `.zprofile`: Login shell setup, PATH configuration, Amazon Q integration
- `.zprompt`: Custom zsh prompt with git branch and virtual environment display
- `.bashrc`: Main bash configuration
- `.bash_profile`: Login shell setup for bash
- `.bash_prompt`: Custom bash prompt
- `.shared_prompt`: Shared prompt functions used by both zsh and bash
- `.aliases`: Common aliases for ls, grep, git, development shortcuts
- `.private`: Private configuration file (gitignored) for personal aliases and environment variables

### Editor Settings
- `settings/VSCode-Settings.json`: VS Code editor settings
- `settings/VSCode-Keybindings.json`: VS Code keyboard shortcuts
- `settings/CMS.terminal`: Terminal color scheme

## Customizing Your Setup

You're encouraged to modify the scripts and configuration files to suit your preferences:

### Dotfiles
Edit `.zshrc`, `.bashrc`, `.aliases`, or `.private` to add or modify shell configurations.

### VS Code
Adjust settings in the `settings/` directory to change editor preferences.

### Packages
Edit `brew.sh` to add or remove packages, applications, or fonts.

### macOS Preferences
Edit `macOS.sh` to change system preferences.

## Contributing

Feel free to fork this repository and customize it for your setup. Pull requests for improvements and bug fixes are welcome, but I likely won't accept pull requests that simply add additional brew installations or change some settings unless they align with my personal preferences.

## License

This project is licensed under the MIT License - see the [LICENSE-MIT.txt](LICENSE-MIT.txt) file for details.

## Acknowledgments

- I originally forked this from [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- Thanks to all the open-source projects used in this setup.
