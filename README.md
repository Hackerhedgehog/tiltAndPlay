# Tilt and Play

A vertical platformer game where you control a character by tilting your phone. Jump from platform to platform, avoid obstacles, and reach the vent at the top to win.

## Project Overview

**Tilt and Play** is a Flutter game built with the Flame engine. It uses the device's accelerometer to move the character left and right. The player bounces off platforms to climb upward while avoiding obstacles. The camera follows the character as they ascend, and new platforms and obstacles spawn dynamically.

### Features

- **Tilt controls** — Use your phone's accelerometer to move the character left and right
- **Platform bouncing** — Land on platforms to bounce upward and climb higher
- **Obstacles** — Avoid obstacles; touching them ends the game
- **Win condition** — Reach the vent at the top of the level
- **Wrap-around** — Move off one side of the screen to appear on the opposite side
- **Progress tracker** — See how many platforms you've landed on vs. the level total
- **Audio** — Sound effects (jump, game start, game over) and looping background music
- **Multiple levels** — Tutorial, Level 1, Level 2, and Level 3 with increasing difficulty

### Tech Stack

- **Flutter** — UI and app framework
- **Flame** — 2D game engine
- **sensors_plus** — Accelerometer for tilt controls
- **flame_audio** — Sound effects and background music

---

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.0.0)
- A physical device with an accelerometer (phones/tablets recommended; emulators may not support motion sensors well)

### 1. Clone the repository

```bash
git clone <repository-url>
cd tiltAndPlay
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Asset files

Ensure the following assets exist in the project:

**Images** (`assets/images/`):

| File            | Description      |
| --------------- | ---------------- |
| `character.png` | Character sprite |
| `platform.png`  | Platform sprite  |
| `vent.png`      | Win vent sprite  |
| `obstacle.png`  | Obstacle sprite  |

**Logo** (`assets/`):

| File       | Description    |
| ---------- | -------------- |
| `logo.png` | Main menu logo |

**Audio** (`assets/sounds/`):

| Path                 | Description                    |
| -------------------- | ------------------------------ |
| `sfx/game-start.mp3` | Played when game starts        |
| `sfx/game-over.mp3`  | Played when player loses       |
| `sfx/jump.mp3`       | Played on each platform bounce |
| `music/music.mp3`    | Looping background music       |

Place empty `.gitkeep` files in empty asset directories if needed. The `pubspec.yaml` already references these asset paths.

### 4. Run the app

**On a connected device (recommended):**

```bash
flutter run
```

**Build for release:**

```bash
# Android APK
flutter build apk

# iOS (requires macOS and Xcode)
flutter build ios
```

### 5. Platform notes

- **Android**: No special permissions required for the accelerometer. The app works in portrait and landscape.

---

## Usage Guide

### Main Menu

After the splash screen, you'll see the main menu with:

- **Tutorial** — Opens an introductory slideshow, then starts the tutorial level
- **Level 1** — 10 platforms, 4 obstacles
- **Level 2** — 20 platforms, 10 obstacles (smaller platforms, larger obstacles)
- **Level 3** — 50 platforms, 40 obstacles (same sizing as Level 2)

### Tutorial Slideshow

When you select **Tutorial**, a short slideshow explains:

1. Use phone tilt to control the character
2. Jump up using platforms
3. Reach the vent to win
4. Watch out for obstacles

Tap **Next** to advance; the game starts after the last slide.

### Controls

- **Tilt left** — Move the character left
- **Tilt right** — Move the character right
- **Land on platform** — Bounce upward automatically

The character wraps around: moving off the left edge appears on the right, and vice versa.

### In-Game HUD

- **Top center** — Progress indicator (e.g. `3 / 10` = platforms landed on / total in level)
- **Bottom left** — Menu button (pause, restart, quit)

### Win / Lose

- **Win**: Touch the vent at the top of the level
- **Lose**: Fall off the bottom of the screen or touch an obstacle

### Menu Options

From the in-game menu:

- **Restart** — Reset the current level
- **Quit** — Return to the main menu
