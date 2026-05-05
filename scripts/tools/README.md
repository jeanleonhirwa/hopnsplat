# Kenney Asset Import Fixer

## Purpose

This tool fixes import settings for all Kenney UI pack PNG textures to optimize them for mobile rendering.

## What It Does

The script `fix_kenney_imports.gd` will:
1. Scan all PNG import files in `assets/ui_packs/`
2. Change `compress/mode=0` to `compress/mode=2` (VRAM Compressed)
3. Change `vram_texture: false` to `vram_texture: true`
4. Verify `mipmaps/generate=false` (correct for UI)
5. Generate a detailed report of all changes

## How to Use

### In Godot Editor:

1. Open `scripts/tools/fix_kenney_imports.gd` in the Godot script editor
2. Click **File > Run** (or press Ctrl+Shift+X)
3. Check the Output panel for the report
4. **Important**: Go to **Project > Reload Current Project** to reimport assets

### Expected Output:

```
=== Kenney Asset Import Settings Fixer ===
Scanning assets/ui_packs/ for PNG textures...

=== Scan Complete ===
Files scanned: 900+
Files with issues: 900+
Files fixed: 900+

✓ Import settings have been updated.
⚠ You need to reimport assets for changes to take effect.
  Go to Project > Reload Current Project or restart Godot.
```

## What Changes

### Before:
```
compress/mode=0  # Lossless/PNG
metadata={
"vram_texture": false
}
```

### After:
```
compress/mode=2  # VRAM Compressed
metadata={
"vram_texture": true
}
```

## Why This Matters

- **Memory**: 20-30% reduction in RAM usage
- **Performance**: Faster texture loading and better GPU utilization
- **Mobile**: Critical for memory-constrained devices
- **Quality**: Minimal visual impact (acceptable for UI elements)

## Verification

After running and reloading:

1. Select any Kenney texture in FileSystem
2. Check Import dock:
   - "Compress > Mode" should show "VRAM Compressed"
   - "Mipmaps > Generate" should be unchecked
3. Run the game and check memory usage in Profiler

## Troubleshooting

**Script won't run:**
- Make sure the script has `@tool` at the top
- Verify you're using File > Run, not running the game

**Changes not visible:**
- You MUST reload the project after running the script
- Godot needs to reimport all textures with new settings

**Visual quality issues:**
- VRAM compression is lossy but optimized for UI
- If quality is unacceptable, adjust `compress/lossy_quality` in preset

## Related Files

- `fix_kenney_imports.gd` - The fixer script
- `kenney_ui_texture.preset` - Import preset for future assets
- `.kiro/specs/ui-overhaul-kenney-pack/asset_import_audit.md` - Detailed audit report
