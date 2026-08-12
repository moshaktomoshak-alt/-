# Above The Death: Survivor

Top-down zombie **wave-defense** survival game for Android, built with the
free/open-source **Godot 4** engine. Enemy roster and visual theme are
inspired by the "ABOVE THE DEATH" Rusted Warfare mod (Jumper, Hazmat,
Penetrator, Clawler, Spitter, Bomber, Tanker), rebuilt from scratch as an
original standalone game with its own code and engine.

## Gameplay
- Drag anywhere on the lower screen to move your survivor with a virtual joystick.
- Your survivor auto-fires at the nearest zombie in range — just focus on movement/positioning.
- Defend your base (center of the map) from escalating waves of zombies.
- Earn **Scrap** from kills → spend it to repair your base or upgrade fire rate.
- Every 5th wave spawns a **Tanker** mini-boss.
- Game ends when base HP hits 0.

## Project structure
```
game/
  project.godot          # Godot project config (portrait mobile)
  scripts/                # All gameplay code (GDScript)
  scenes/Main.tscn        # Entry scene
  assets/sprites/         # Cropped unit/building art sourced from the mod
  assets/audio/           # SFX sourced from the mod
  export_presets.cfg      # Android export preset (debug-signed)
  .github/workflows/android-build.yml   # CI: builds the APK on every push
```

## Building the APK via GitHub (no local install needed)
1. Create a new **public or private GitHub repository**.
2. Upload/push everything inside this `game/` folder to the repo root
   (keep the folder structure — `project.godot` must sit at the repo root).
3. Push to your `main` branch. GitHub Actions will automatically:
   - spin up the `barichello/godot-ci:4.3` container (Godot 4.3 + Android export templates preinstalled)
   - run `godot --headless --export-debug "Android" build/android/AboveTheDeath.apk`
   - upload the resulting **AboveTheDeath.apk** as a workflow artifact
4. Go to the repo's **Actions** tab → open the latest run → download the
   `AboveTheDeath-android-apk` artifact → unzip → install the `.apk` on
   your Android phone (enable "Install unknown apps" for your browser/file
   manager first).

You don't need Android Studio, a keystore, or a local Godot install — the
CI container ships with a debug keystore already configured, so the APK
is installable straight away (debug-signed, fine for personal use/testing;
for a Play Store release you'd add your own release keystore later).

### Building locally instead (optional)
If you'd rather build on your own machine:
1. Install [Godot 4.3](https://godotengine.org/download) (standard build).
2. Install Android export templates from Editor → Manage Export Templates.
3. Open `project.godot`, go to Project → Export → Android → Export Project.

## Editing / extending
- Zombie types & wave composition: `scripts/WaveManager.gd` (the `TYPES`
  dictionary — tweak hp/speed/damage or add new types).
- Player stats: `scripts/Player.gd`.
- UI/HUD: `scripts/HUD.gd`.
- Swap any sprite by replacing the PNG in `assets/sprites/` (keep the same filename).

## Note on assets
The sprites and sound effects bundled here were cropped/extracted from the
original "ABOVE THE DEATH" Rusted Warfare mod at your request as its
creator. If you plan to publish this game publicly, swap in your own
final art pass — the current sprites are quick single-frame crops from the
mod's animation sheets, meant as a functional placeholder rather than
final production art.
