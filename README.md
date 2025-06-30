# Scrap Ascent

**Scrap Ascent** is a unique 2D platformer where you play as a mysterious Orb with the power to possess and control different types of robotic enemies. Use their unique abilities strategically to navigate challenging levels and overcome obstacles.

## 🎮 Game Concept

In Scrap Ascent, you don't play as a traditional hero. Instead, you are a small, ethereal Orb capable of taking control of enemy robots by possessing them. Each enemy type has different abilities, and mastering when and how to possess them is key to progressing through the game.

The core gameplay revolves around:
- **Possession Mechanics**: Take control of enemies to use their abilities
- **Strategic Ability Usage**: Different enemies have different movement and combat capabilities
- **Platforming Challenges**: Navigate levels using the right enemy for each obstacle
- **Combat System**: Armed enemies can shoot projectiles and engage in combat

## 🎯 Gameplay Mechanics

### The Orb (Your Core Character)
- Small, nimble character that can move and jump
- Affected by gravity and physics
- **Primary Ability**: Possess nearby enemies within range
- Vulnerable but essential - losing the orb means game over
- Respawns when you release control from a possessed enemy

### Possession System
The heart of Scrap Ascent's gameplay:

1. **Possessing Enemies**: Get close to an enemy and press the possess key
2. **Taking Control**: The orb disappears and you gain full control of the enemy
3. **Using Abilities**: Access all of the possessed enemy's unique skills
4. **Releasing Control**: Press possess again to release control and respawn as the orb
5. **Strategic Switching**: Chain possessions to navigate complex areas

### Enemy States & Visual Indicators
- 🔴 **Red Tint**: AI-controlled enemy (can be possessed)
- 🟢 **Green Tint**: Currently controlled by you
- ⚫ **Gray Tint**: Inert/destroyed chip (cannot be possessed)

## 🤖 Enemy Types & Abilities

### Tier 1 Enemy (Basic)
- **Color**: Red tint
- **Speed**: Slow (80 units)
- **Abilities**: 
  - Basic Movement
  - Single Jump
- **Best for**: Simple platforming, basic navigation

### Tier 2 Enemy (Agile)  
- **Color**: Blue tint
- **Speed**: Medium (120 units)
- **Abilities**:
  - Movement
  - Jump
  - Dash (quick burst of speed)
- **Best for**: Crossing gaps, quick traversal

### Tier 3 Enemy (Advanced)
- **Color**: Purple tint  
- **Speed**: Fast (140 units)
- **Abilities**:
  - Movement
  - Jump
  - Double Jump (can jump twice in air)
  - Dash
- **Best for**: Complex platforming, reaching high areas

### Armed Enemy (Combat)
- **Color**: Orange tint
- **Speed**: Slow (90 units)
- **Abilities**:
  - Movement  
  - Jump
  - Weapon System (shooting, weapon management)
- **Comes Equipped**: With a weapon for immediate combat use
- **Best for**: Combat encounters, destroying obstacles

## 🎮 Controls

### Basic Movement
- **A / Left Arrow**: Move Left
- **D / Right Arrow**: Move Right  
- **Space**: Jump
- **Shift**: Dash (if possessed enemy has dash ability)

### Core Mechanics  
- **K**: Possess nearby enemy / Release control from possessed enemy
- **Enter**: Shoot (when controlling armed enemy)
- **C**: Toggle Weapon (when controlling armed enemy)
- **G**: Drop Weapon (when controlling armed enemy)

### Tips for Controls
- Possession works within a limited range - get close to enemies
- Each enemy type feels different to control due to varying speeds and abilities
- Experiment with different enemies to find the best approach for each challenge

## 🔧 Weapon System

When controlling Armed Enemies, you gain access to a sophisticated weapon system:

### Weapon Mechanics
- **Shooting**: Projectiles travel in the direction you're facing
- **Cooldown**: Weapons have a fire rate limit to prevent spam
- **Knockback**: Weapons have recoil that can affect movement
- **Damage**: Projectiles can damage other enemies and destroy their control chips

### Weapon Management
- **Toggle**: Switch weapon on/off for different situations
- **Drop**: Release weapon to make it available for other enemies to pick up
- **Pickup**: Weapons can be retrieved by getting close to them

## 🚀 Installation & Setup

### Requirements
- **Godot Engine 4.4** or later
- Windows, macOS, or Linux operating system
- Minimum 2GB RAM
- Graphics card with OpenGL compatibility

### Running the Game

1. **Download Godot 4.4+**
   ```
   Download from: https://godotengine.org/download
   ```

2. **Clone or Download the Repository**
   ```bash
   git clone https://github.com/andresguibarra/scrap-ascent.git
   cd scrap-ascent
   ```

3. **Open in Godot**
   - Launch Godot Engine
   - Click "Import" and select the `project.godot` file
   - Click "Import & Edit"

4. **Run the Game**
   - Press **F5** or click the Play button
   - Select `TestingMechanics.tscn` as the main scene if prompted

### Troubleshooting
- **Game won't start**: Ensure you're using Godot 4.4 or later
- **Missing textures**: The game uses simple colored rectangles for sprites
- **Controls not working**: Check that the input map is properly configured in Project Settings
- **Performance issues**: Try reducing the window size in the project settings

## 🎯 Gameplay Tips & Strategies

### Getting Started - First Steps
1. **Start as the Orb**: You begin as a small orb that can move and jump
2. **Find an Enemy**: Look for colored robots patrolling the platforms  
3. **Get Close**: Move within possession range (you'll see when you're close enough)
4. **Press K**: This possesses the nearest enemy - you'll see it turn green
5. **Experiment**: Try the enemy's abilities - movement feels different for each type
6. **Release Control**: Press K again to return to orb form

### Mastering Possession
- **Range Awareness**: Stay close to enemies you want to possess
- **Timing**: Possess enemies at the right moment to avoid hazards
- **Chain Possessions**: Move from enemy to enemy without returning to orb form

### Enemy Selection Strategy
- **Use Tier 1** for basic movement and when you need slow, precise control
- **Use Tier 2** for medium-range traversal and dash-based challenges
- **Use Tier 3** for complex platforming requiring double jumps and agility  
- **Use Armed Enemies** for combat situations and destroying obstacles

### Advanced Techniques
- **Momentum Preservation**: Your velocity carries over when releasing control
- **Ability Chaining**: Combine different enemy abilities by possessing sequentially
- **Combat Tactics**: Use armed enemies to clear paths and disable other enemies

## 🔧 Technical Details

### Built With
- **Engine**: Godot 4.4
- **Language**: GDScript (Typed)
- **Resolution**: 1280x720 (configurable)
- **Physics**: Godot's built-in 2D physics system

### Architecture Highlights
- **Modular Enemy System**: Skill-based enemy capabilities
- **Centralized Input Management**: Clean input handling via InputManager singleton
- **Physics-Based Movement**: Realistic gravity and collision detection
- **Dynamic Camera System**: Smart camera that follows active character

## 🎨 Visual Style & Feedback
- **Minimalist geometric art style** with colored rectangles representing characters
- **Color-coded enemy system** for easy identification of states and types
- **Visual State Indicators**:
  - 🔴 Red robots = AI-controlled (can be possessed)
  - 🟢 Green robots = Currently under your control  
  - ⚫ Gray robots = Destroyed/inert (cannot be possessed)
  - 🔵 Blue robots = Tier 2 enemies with dash ability
  - 🟣 Purple robots = Tier 3 enemies with all abilities
  - 🟠 Orange robots = Armed enemies with weapons
- **Smooth physics-based movement** and collision detection
- **Dynamic camera** that intelligently follows your active character

## 🚧 Current Status
This is a demonstration/prototype showcasing the core possession mechanics. The current build includes:
- ✅ Core possession system
- ✅ Multiple enemy types with unique abilities  
- ✅ Weapon system for armed enemies
- ✅ Physics-based platforming
- ✅ Testing environment with multiple platforms
- ✅ Smart camera system that follows active character
- ✅ Complete input management system

### Testing the Game
The game currently runs in a testing environment (`TestingMechanics.tscn`) that includes:
- Sample platforms for movement testing
- One of each enemy type to test possession mechanics
- Weapons for combat testing
- Camera system demonstration

## 🤝 Contributing
Contributions are welcome! Feel free to:
- Report bugs or issues
- Suggest new enemy types or abilities
- Improve documentation
- Add new levels or challenges

## 📄 License
This project is open source. Please check the repository for specific license details.

---

**Enjoy your ascent through the world of possessed robots! 🤖⚡**