# Scrap Ascent

**Scrap Ascent** is a unique 2D platformer where you play as a mysterious Orb with the power to possess and control different types of robotic enemies. Use their unique abilities strategically to navigate challenging levels and overcome obstacles.

## 🎮 Game Concept

**Scrap Ascent** revolutionizes traditional platforming through its innovative possession-based gameplay. Rather than controlling a single character, you embody a mysterious Orb with the unique ability to take control of robotic enemies, each offering distinct capabilities and strategic applications.

### Core Innovation: Possession-Driven Gameplay
The fundamental mechanic centers around **strategic character switching**:
- **Dynamic Character Control**: Seamlessly transition between different robot types mid-gameplay
- **Ability-Based Problem Solving**: Each possession grants access to unique movement and combat capabilities  
- **Strategic Resource Management**: Choose the right enemy type for each challenge
- **Layered Complexity**: Simple possession mechanics combine to create sophisticated puzzle solutions

### Gameplay Pillars

**🔄 Adaptive Possession System**
- **Proximity-Based Control**: Possess enemies within range through intuitive proximity detection
- **Visual State Management**: Clear color-coding system for instant enemy identification
- **Seamless Transitions**: Smooth character switching with momentum preservation
- **Strategic Depth**: Multiple solutions to challenges based on available enemy types

**⚡ Physics-Enhanced Platforming**
- **Tier-Based Abilities**: Four distinct enemy tiers with progressive capability expansion
- **Advanced Movement**: Wall climbing, air dashing, double jumping, and precision platforming
- **Momentum Physics**: Realistic movement with coyote time, jump buffering, and air control
- **Environmental Interaction**: Physics-aware collision with dynamic platform systems

**🎯 Combat & Destruction**
- **Projectile Physics**: Armed enemies provide ranged combat with realistic trajectory calculation
- **Strategic Elimination**: Destroy enemy control chips to permanently disable threats
- **Weapon Management**: Auto-pickup systems with tactical weapon deployment
- **Environmental Combat**: Use projectiles to activate switches and solve ranged puzzles

**🧩 Interactive Environmental Puzzles**
- **Multi-Component Systems**: Doors, buttons, platforms, and countdown mechanisms work in harmony
- **Cause-and-Effect Chains**: Actions create cascading effects throughout the environment
- **Timing-Based Challenges**: Countdown systems create urgency and strategic planning requirements
- **Spatial Reasoning**: 3D thinking in 2D space through layered puzzle design

### Unique Design Philosophy
Unlike traditional platformers where you master a single character's abilities, **Scrap Ascent** challenges you to:
- **Think Multi-Dimensionally**: Consider which enemy type best solves each specific challenge
- **Plan Possession Chains**: Sequence character switches to navigate complex areas
- **Adapt to Constraints**: Work with available enemy types when optimal choices aren't present
- **Master Multiple Skillsets**: Become proficient with different movement patterns and combat styles

This creates a gameplay experience where **strategic thinking** is as important as **mechanical skill**, and where the environment itself becomes a dynamic puzzle to solve through possession mastery.

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

Scrap Ascent features a sophisticated tier-based enemy system where each robot type offers unique capabilities for strategic gameplay.

### Tier 1 Enemy (Basic Foundation)
- **Visual Identifier**: Red tint `rgb(204, 102, 102)`
- **Movement Speed**: 80 units (deliberate and precise)
- **Core Abilities**: 
  - Fundamental Movement (left/right with physics-based acceleration)
  - Single Jump (standard height with coyote time support)
- **Strategic Use**: Ideal for precise platforming, slow traversal, and situations requiring careful positioning
- **Best Scenarios**: Basic navigation, simple puzzles, learning possession mechanics

### Tier 2 Enemy (Agile Specialist)  
- **Visual Identifier**: Blue tint `rgb(102, 153, 229)`
- **Movement Speed**: 120 units (balanced mobility)
- **Enhanced Abilities**:
  - Standard Movement and Jump
  - **Air Dash** (directional burst with cooldown management)
  - **Wall Climbing** (slide down walls, wall jump for vertical navigation)
- **Strategic Use**: Crossing moderate gaps, quick repositioning, vertical exploration
- **Best Scenarios**: Multi-level navigation, gap crossing, wall-based puzzles

### Tier 3 Enemy (Advanced Mobility)
- **Visual Identifier**: Orange tint `rgb(229, 153, 51)`
- **Movement Speed**: 140 units (high agility)
- **Advanced Abilities**:
  - Enhanced Movement and Jump
  - **Double Jump** (secondary air jump for extended traversal)
  - Air Dash with improved control
  - Advanced Wall Climbing with enhanced grip
- **Strategic Use**: Complex platforming sequences, reaching high areas, advanced vertical movement
- **Best Scenarios**: Multi-stage jumps, challenging platforming, exploration of hard-to-reach areas

### Tier 4 Enemy (Elite Performance)
- **Visual Identifier**: Purple tint `rgb(178, 76, 204)`
- **Movement Speed**: Variable (optimized for situation)
- **Elite Capabilities**:
  - Complete mobility suite (all movement abilities)
  - Enhanced physics with improved air control
  - Advanced wall interaction and climbing mastery
  - Superior dash control with reduced cooldowns
- **Strategic Use**: Master-level challenges, complex navigation sequences
- **Best Scenarios**: End-game content, advanced puzzles, demonstration of full possession potential

### Armed Enemy Variants (Combat-Ready)
- **Visual Identifier**: Enhanced with weapon indicators
- **Base Capabilities**: Varies by tier (can be any tier with weapon attachment)
- **Weapon Integration**:
  - **Projectile System** with physics-based trajectory and collision
  - **Auto-Pickup Mechanics** for seamless weapon acquisition
  - **Firing Cooldown** to prevent spam while maintaining combat flow
  - **Weapon Toggle** for strategic weapon management (C key)
- **Combat Features**:
  - Directional shooting based on character facing
  - Knockback effects on both shooter and target
  - Damage system that can destroy enemy control chips
- **Strategic Use**: Combat encounters, obstacle destruction, puzzle-solving through firepower
- **Best Scenarios**: Enemy elimination, breaking through barriers, long-range activation of switches

## 🎮 Controls

### Basic Movement
- **A / Left Arrow**: Move Left
- **D / Right Arrow**: Move Right  
- **Space**: Jump
- **Shift**: Dash (if possessed enemy has dash ability)

### Core Mechanics  
- **K**: Possess nearby enemy / Release control from possessed enemy
- **Enter**: Shoot (when controlling armed enemy)
- **C**: Toggle Weapon (when controlling armed enemy - get/drop weapon)

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
- **Toggle**: Switch weapon on/off for different situations (C key handles both pickup and drop)
- **Pickup**: Weapons can be retrieved by pressing C when close to them

## 🏗️ Interactive Environment System

Scrap Ascent features a comprehensive interactive environment that creates dynamic puzzles and strategic challenges through interconnected mechanisms.

### 🚪 Advanced Door System
- **Smooth Animation**: Doors follow predetermined paths with physics-aware movement
- **Multi-Trigger Support**: Can be activated by buttons, switches, countdown mechanisms, or other triggers
- **Collision Intelligence**: Doors detect and crush enemy control chips caught during closing sequences
- **Strategic Integration**: Doors can block access, create new pathways, or serve as moving platforms
- **Visual Feedback**: Clear animation states showing opening/closing progress and final positions

### 🔘 Pressure Button Mechanics
- **Activation Types**:
  - **Temporary Buttons** (`rgb(20, 32, 18)` → `rgb(46, 71, 41)`): Require continuous pressure to stay active
  - **Permanent Switches** (Light variants): Stay activated once triggered by projectiles
- **Detection System**: Smart collision detection that specifically recognizes possessed enemies
- **Visual States**: Dynamic color changes and lighting effects for immediate feedback
- **Persistence Logic**: Buttons remain active while any enemy stands on them
- **Multi-Entity Support**: Can handle multiple enemies simultaneously

### 📦 Dynamic Platform System (GlowBox)
- **State-Based Collision**: Platforms toggle between solid and passable states
- **Visual Indicators**: 
  - **Inactive** (`rgb(84, 133, 78)`): Enemies fall through
  - **Active** (`rgb(138, 199, 130)`): Enemies can stand on platform
- **Trigger Integration**: Responds to button activation/deactivation signals
- **Physics Consistency**: Seamless collision state changes without entity displacement
- **Strategic Applications**: Create conditional pathways, moving platform puzzles, trap mechanisms

### ⏰ Countdown Mechanism System
- **Timed Sequences**: Programmable countdown duration with visual progression
- **Progressive Animation**: Frame-by-frame animation showing countdown progress
- **Light Effects**: Pulsing warning lights (`rgb(255, 204, 76)`) during active countdown
- **Auto-Reset**: Automatic return to idle state after countdown completion
- **Trigger Deactivation**: Automatically deactivates connected buttons upon completion
- **Strategic Use**: Time-based puzzles, temporary access windows, urgency mechanics

### 🔗 Signal-Based Architecture
- **Decoupled Communication**: Components communicate through Godot signals for clean architecture
- **Flexible Connections**: Any trigger can be connected to any responsive mechanism
- **Editor Integration**: Visual connection setup directly in Godot editor
- **Real-Time Configuration**: @tool-enabled components allow live editing and testing
- **Scalable Design**: Easy addition of new interactive elements without code changes

### 🎯 Puzzle Design Philosophy
- **Layered Complexity**: Simple mechanics combine to create sophisticated challenges
- **Multiple Solutions**: Many puzzles can be solved using different enemy types or approaches
- **Progressive Difficulty**: Mechanics introduce individually before combining in complex scenarios
- **Clear Feedback**: Visual and audio cues guide player understanding of cause-and-effect relationships
- **Strategic Depth**: Optimal solutions often require understanding of timing, positioning, and enemy capabilities

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
- **Missing textures**: Check that all asset files (.png, .svg) are properly imported in Godot
- **Controls not working**: Check that the input map is properly configured in Project Settings
- **Performance issues**: Try reducing the window size in the project settings
- **Audio not playing**: Ensure audio drivers are properly configured and volume levels are set

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
- **Use Tier 2** for medium-range traversal, dash-based challenges, and wall climbing sections
- **Use Tier 3** for complex platforming requiring double jumps, agility, and advanced wall climbing
- **Use Armed Enemies** for combat situations and destroying obstacles

### Advanced Techniques
- **Momentum Preservation**: Your velocity carries over when releasing control
- **Ability Chaining**: Combine different enemy abilities by possessing sequentially
- **Combat Tactics**: Use armed enemies to clear paths and disable other enemies
- **Wall Climbing**: Use Tier 2 and 3 enemies to slide down walls and perform wall jumps for vertical navigation
- **Environmental Puzzles**: Use possessed enemies to activate buttons and manipulate doors for level progression

## 🔧 Technical Details

### Built With
- **Engine**: Godot 4.4 (latest stable release with advanced 2D features)
- **Language**: GDScript with full typed annotations for performance and reliability
- **Resolution**: 1280x720 base with viewport scaling for multiple display sizes
- **Physics**: Enhanced Godot 2D physics with custom collision layer management
- **Performance**: Optimized for smooth 60fps gameplay with efficient resource management

### Advanced Architecture Highlights

**🏗️ Modular Component System**
- **Skill-Based Enemy Framework**: Configurable abilities through exportable enum arrays
- **Signal-Driven Communication**: Decoupled architecture using Godot's signal system
- **@tool Integration**: Real-time editor configuration for interactive components
- **Collision Layer Architecture**: Multi-layered physics system for precise interaction control

**🎮 Input & Control Systems**
- **Centralized Input Management**: InputManager singleton for consistent control handling
- **Context-Aware Input**: Input behavior adapts based on possessed character capabilities
- **Buffer System**: Jump buffering and coyote time for responsive platforming feel
- **Physics Integration**: Input directly tied to physics for consistent movement behavior

**🎨 Visual & Effects Pipeline**
- **Dynamic Lighting System**: Real-time lighting effects with possession-aware color changes
- **Dual Particle Architecture**: Separate base and intense particle systems for activity feedback
- **State-Based Animations**: Animation states that respond to physics and gameplay context
- **Damage Visualization**: Color-matched particle effects that correspond to enemy tiers

**🏃 Advanced Movement Systems**
- **Enhanced Physics**: Custom gravity, acceleration, and friction for varied character feel
- **Wall Interaction**: Sophisticated wall detection with slide mechanics and wall jumping
- **Air Control**: Multi-tier jump systems with double jump and air dash capabilities
- **Momentum Preservation**: Velocity maintenance across possession transitions

**🔫 Weapon & Combat Framework**
- **Physics-Based Projectiles**: Realistic trajectory calculation with collision detection
- **Auto-Pickup System**: Intelligent weapon acquisition with proximity detection
- **Cooldown Management**: Firing rate control with visual feedback systems
- **Damage Integration**: Projectile damage system that destroys enemy control chips

**📷 Smart Camera System**
- **Possession-Aware Following**: Camera intelligently tracks active character with smooth transitions
- **Dynamic Zoom**: Automatic adjustment based on character type and movement speed
- **Boundary Handling**: Intelligent edge detection to prevent camera from showing empty areas
- **Smooth Interpolation**: Lag-free camera movement with customizable responsiveness

**🔧 Development Tools & Quality**
- **Comprehensive Debugging**: Built-in debug output for possession states, physics, and interactions
- **Editor Integration**: Custom inspector properties for easy designer configuration
- **Signal Validation**: Automatic connection verification to prevent broken trigger chains
- **Performance Monitoring**: Efficient resource usage with minimal garbage collection impact

## 🎨 Visual Style & Feedback

Scrap Ascent features a cohesive visual design that prioritizes clear gameplay feedback while maintaining an immersive industrial/sci-fi aesthetic.

### Art Style & Environment
- **Professional sprite-based art** with detailed character animations and environmental assets
- **Industrial/sci-fi atmosphere** featuring metallic surfaces, technical elements, and futuristic lighting
- **Consistent visual language** that guides player understanding through color and animation

### Dynamic Enemy Visual System
The game uses a sophisticated color-coding system for instant enemy identification:
- **🔴 Tier 1 (Red)** - Basic enemies with fundamental movement capabilities
- **🔵 Tier 2 (Blue)** - Agile enemies featuring dash and wall climbing abilities  
- **🟠 Tier 3 (Orange)** - Advanced enemies with double jump and enhanced mobility
- **🟣 Tier 4 (Purple)** - Elite enemies with complete ability sets
- **⚫ Inert (Gray)** - Destroyed enemies that cannot be possessed
- **🟢 Possessed State** - Clear green indication when under player control

### Advanced Visual Effects
- **Orb Lighting System**: Dynamic pulsing effects that intensify during movement and possession sequences
- **Dual Particle Systems**: Base and intense particle effects that respond to player activity states
- **Color-Matched Damage Effects**: Destruction particles that match enemy colors for immediate visual feedback
- **Possession Lighting**: Color-coordinated light effects during character transitions
- **Environmental Responsiveness**: Interactive elements with clear activation states and smooth transitions

### Interactive Environment Feedback
- **Pressure Button System**: Visual state changes with lighting effects for activation feedback
- **Dynamic Platform Indicators**: GlowBox platforms with clear solid/passable state visualization
- **Countdown Mechanisms**: Progressive visual feedback with pulsing warning lights
- **Door Animation System**: Smooth mechanical movements with collision-aware behavior
- **Weapon Effects**: Projectile trails and impact feedback for combat clarity

### Technical Visual Features
- **Smart Camera System**: Intelligent following with possession-aware transitions and smooth movement
- **Physics-Based Animation**: Realistic movement with proper collision detection and response
- **Multi-Layer Lighting**: Depth-aware illumination that enhances the 3D feel of 2D environments
- **Performance-Optimized Effects**: Efficient particle systems and lighting that maintain smooth gameplay

## 🎵 Audio & Atmosphere
- **Atmospheric Background Music**: Exploration-themed soundtrack that enhances the sci-fi industrial atmosphere
- **Dynamic Audio System**: Audio that responds to gameplay actions and environmental interactions
- **Immersive Soundscape**: Audio design that complements the visual style and enhances player immersion

## 🎨 Color Palette

Scrap Ascent uses a carefully designed color palette to provide clear visual feedback and enhance the gaming experience. Here are all the colors used throughout the application:

### 🤖 Enemy State Colors

<table>
<tr>
<td><strong>Tier 1 (Basic)</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(204, 102, 102); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(204, 102, 102)</code></td>
<td>Red tint for basic enemies with movement and jump abilities</td>
</tr>
<tr>
<td><strong>Tier 2 (Agile)</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(102, 153, 229); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(102, 153, 229)</code></td>
<td>Blue tint for agile enemies with dash and wall climbing</td>
</tr>
<tr>
<td><strong>Tier 3 (Advanced)</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(229, 153, 51); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(229, 153, 51)</code></td>
<td>Orange tint for advanced enemies with double jump and full abilities</td>
</tr>
<tr>
<td><strong>Tier 4 (Elite)</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(178, 76, 204); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(178, 76, 204)</code></td>
<td>Purple tint for elite enemies with all advanced capabilities</td>
</tr>
<tr>
<td><strong>Inert/Destroyed</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(76, 76, 76); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(76, 76, 76)</code></td>
<td>Gray tint for destroyed enemies that cannot be possessed</td>
</tr>
</table>

### 🔘 Interactive Button Colors

<table>
<tr>
<td><strong>Button Inactive</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(20, 32, 18); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(20, 32, 18)</code></td>
<td>Dark green for inactive pressure buttons</td>
</tr>
<tr>
<td><strong>Button Active</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(46, 71, 41); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(46, 71, 41)</code></td>
<td>Bright green for activated pressure buttons</td>
</tr>
</table>

### 📦 Platform Colors (GlowBox)

<table>
<tr>
<td><strong>Platform Inactive</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(84, 133, 78); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(84, 133, 78)</code></td>
<td>Medium green for inactive platforms (passable)</td>
</tr>
<tr>
<td><strong>Platform Active</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(138, 199, 130); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(138, 199, 130)</code></td>
<td>Light green for active platforms (solid)</td>
</tr>
</table>

### ⏰ Special Effect Colors

<table>
<tr>
<td><strong>Countdown Light</strong></td>
<td><div style="width: 20px; height: 20px; background-color: rgb(255, 204, 76); border: 1px solid #000; display: inline-block;"></div></td>
<td><code>rgb(255, 204, 76)</code></td>
<td>Warm yellow/orange for countdown mechanisms and warning lights</td>
</tr>
</table>

## 🚧 Current Status

Scrap Ascent is a feature-complete demonstration showcasing advanced possession mechanics and interactive environments. The current build includes:

**✅ Core Systems:**
- Complete possession system with seamless character switching
- Four distinct enemy tiers with unique ability sets
- Advanced physics-based movement with coyote time and jump buffering
- Comprehensive weapon system with projectile physics and auto-pickup
- Smart camera system with possession-aware following

**✅ Interactive Environment:**
- Animated doors with trigger-based activation and crushing mechanics
- Pressure-sensitive buttons with visual feedback and persistent activation
- Dynamic platforms (GlowBox) that toggle between solid and passable states
- Countdown mechanisms with timed sequences and visual progression
- Multi-layered collision system for precise interaction detection

**✅ Advanced Movement:**
- Wall climbing and sliding mechanics for Tier 2+ enemies
- Air dashing with directional control and cooldown management
- Double jumping capabilities for advanced traversal
- Momentum preservation across possession transitions

**✅ Visual & Audio:**
- Dynamic particle systems that respond to player activity
- Possession-aware lighting effects with color-coded feedback
- Damage particles that match enemy colors for clear visual feedback
- Atmospheric background music and immersive soundscape
- Professional sprite-based art with detailed animations

**✅ Technical Features:**
- Centralized input management via InputManager singleton
- Modular enemy system with skill-based capabilities
- @tool-enabled components for real-time editor configuration
- Comprehensive collision layer management
- Signal-based communication for decoupled system architecture

### Testing the Game
The game runs in a comprehensive testing environment (`TestingMechanics.tscn`) featuring:
- **Multi-tier Platform Complex**: Various heights and distances for testing different enemy capabilities
- **Complete Enemy Showcase**: One of each enemy type demonstrating all tier abilities
- **Weapon Combat Arena**: Areas designed for testing projectile mechanics and combat encounters
- **Interactive Puzzle Section**: Doors, buttons, and platforms demonstrating trigger-based mechanics
- **Advanced Movement Challenges**: Wall climbing sections and vertical navigation tests
- **Technical Demonstrations**: Camera behavior, visual effects, and audio integration showcase
- **Environmental Storytelling**: Industrial/sci-fi themed level design with atmospheric elements

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