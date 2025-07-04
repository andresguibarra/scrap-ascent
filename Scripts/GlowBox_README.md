# GlowBox System

## Overview
The GlowBox is a platform/surface that can be activated/deactivated by connecting it to a Button trigger. When active, enemies can stand on it; when inactive, they fall through.

## Features

### Visual States
- **Inactive**: Color `#55854e` (dark green), collision disabled
- **Active**: Color `#8bc882` (bright green), collision enabled

### Collision Behavior
- **Inactive**: `CollisionShape2D.disabled = true` - enemies fall through
- **Active**: `CollisionShape2D.disabled = false` - enemies can stand on it

### Trigger Integration
- Connects to any Button node via `@export var trigger_node: Node2D`
- Responds to `activated` and `deactivated` signals from the button
- Follows the same pattern as Door.gd for consistency

## Setup Instructions

1. **Add GlowBox to scene**: Instance `GlowBox.tscn` in your level
2. **Add Button trigger**: Instance any `Button.tscn` variant
3. **Connect in editor**: 
   - Select the GlowBox node
   - In the Inspector, set `Trigger Node` to your Button node
   - Optionally set `Start Active` if you want it active by default

## Expected Scene Structure

```
GlowBox
├── Sprite2D (visual representation)
└── StaticBody2D
    └── CollisionShape2D (platform collision)
```

## Usage Examples

### Temporary Platform (Button activated)
- Use `Type.BUTTON` for pressure-sensitive activation
- GlowBox appears when enemy steps on button
- GlowBox disappears when enemy leaves button

### Permanent Platform (Switch activated)  
- Use `Type.LIGHT_LEFT` or `Type.LIGHT_RIGHT` for permanent switches
- GlowBox appears when projectile hits switch
- GlowBox stays active until level reset

### Puzzle Mechanics
- Chain multiple GlowBoxes with different buttons
- Create moving platforms by combining with moving button triggers
- Use `start_active = true` for inverted logic (platform disappears when activated)

## Configuration

```gdscript
@export var trigger_node: Node2D    # Button that controls this GlowBox
@export var start_active: bool = false  # Initial state
```

## API

```gdscript
# Check current state
if glow_box.get_is_active():
    print("Platform is solid")
else:
    print("Platform is passable")

# Manual control (if needed)
glow_box._activate()    # Make solid
glow_box._deactivate()  # Make passable
```
