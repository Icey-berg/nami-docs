# About

Nami is a real-time 2D wave simulation module for Roblox built on EditableMesh. It simulates wave propagation using the discrete wave equation and renders the result as a deformable water surface.

---

# Installation

Place the `Nami` ModuleScript somewhere accessible and require it:

```lua
local Nami = require(path.To.Nami)
```

---

# Creating a Surface

## Nami.create()

Creates a new water surface instance.

### Syntax

```lua
local surface = Nami.create(
    lengthX,
    lengthZ,
    vertsPerStud,
    waveSpeed,
    timeStep,
    damping,
    blurSigma
)
```

### Parameters

| Parameter | Type | Units | Description |
|------------|--------|--------|-------------|
| `lengthX` | `number` | Studs| Width of the water surface. |
| `lengthZ` | `number` | Studs| Length of the water surface. |
| `vertsPerStud` | `number` |Vertex per Stud | Vertex density used for rendering. |
| `waveSpeed` | `number` |Studs per Second | Speed at which waves propagate. |
| `timeStep` | `number` | Seconds| Fixed simulation timestep. |
| `damping` | `number` |Dimensionless | Energy loss applied each simulation step. Values slightly below `1` are recommended. |
| `blurSigma` | `number` |Dimensionless| Gaussian blur strength used for visual smoothing. |

### Returns

```lua
WaterSurface
```

### Example

```lua
local surface = Nami.create(
    100,
    100,
    0.5,
    20,
    1 / 50,
    0.995,
    1.1
)
```
> **Note:** The timestep is expressed as `1 / physics FPS` for easy interpretation. This is the recommended approach.
> Try to keep at or below 60.
---

# Initialisation

## surface:initialise()

Creates the EditableMesh, MeshPart, and simulation buffers.

Must be called before any other surface method.

### Syntax

```lua
surface:initialise(parent)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parent` | `Instance` | Parent instance for the generated MeshPart. |

### Example

```lua
surface:initialise(workspace)
```

---

# Simulation

## surface:step()

Advances the simulation.

This should typically be called every frame from `RunService`.

### Syntax

```lua
surface:step(deltaTime)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `deltaTime` | `number` | Frame delta time. |

### Example

```lua
RunService.Heartbeat:Connect(function(dt)
    surface:step(dt)
end)
```

---

# Wave Interaction

## surface:pointSplash()

Injects a displacement into a single simulation cell.

Useful for impacts, raindrops, explosions, or object interaction.

### Syntax

```lua
surface:pointSplash(z, x, height)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `z` | `number` | Grid Z coordinate. |
| `x` | `number` | Grid X coordinate. |
| `height` | `number` | Initial wave displacement. |

### Example

```lua
surface:pointSplash(50, 50, 5)
```

---

## surface:smoothSplash()

Creates a smooth Gaussian-shaped disturbance.

> **Note:** This function is currently not implemented.

### Syntax

```lua
surface:smoothSplash()
```

---

# Surface Queries

## surface:normalAt()

Returns the surface normal at a grid coordinate.

Useful for buoyancy, object orientation, reflections, and shading.

### Syntax

```lua
local normal = surface:normalAt(z, x)
```

### Parameters

| Parameter | Type |
|-----------|------|
| `z` | `number` |
| `x` | `number` |

### Returns

```lua
Vector3
```

### Example

```lua
local normal = surface:normalAt(50, 50)
```

---

## surface:heightAt()

Returns the rendered height of the water surface at a grid coordinate.

### Syntax

```lua
local height = surface:heightAt(z, x)
```

### Parameters

| Parameter | Type |
|-----------|------|
| `z` | `number` |
| `x` | `number` |

### Returns

```lua
number
```

### Example

```lua
local height = surface:heightAt(50, 50)
```

---

## surface:worldPositionToMesh()

Converts a world-space position into mesh grid coordinates.

Useful when converting hit positions into coordinates that can be used with `pointSplash`, `normalAt`, or `heightAt`.

### Syntax

```lua
local z, x = surface:worldPositionToMesh(worldZ, worldX)
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `worldZ` | `number` | World-space Z coordinate. |
| `worldX` | `number` | World-space X coordinate. |

### Returns

```lua
(number, number)
```

### Example

```lua
local z, x = surface:worldPositionToMesh(
    hitPosition.Z,
    hitPosition.X
)

surface:pointSplash(z, x, 4)
```

---

# Cleanup

## surface:destroy()

Destroys the generated mesh and marks the simulation as unusable.

After calling this method, any further operations on the surface will throw an error.

### Syntax

```lua
surface:destroy()
```

### Example

```lua
surface:destroy()
```

---

# Complete Example

```lua
local RunService = game:GetService("RunService")

local Nami = require(path.To.Nami)

local surface = Nami.create(
    100,
    100,
    2,
    20,
    1 / 60,
    0.5,
    0.995,
    1.2
)

surface:initialise(workspace)

RunService.Heartbeat:Connect(function(dt)
    surface:step(dt)
end)

surface:pointSplash(50, 50, 5)
```

---

# WaterSurface API

| Method |
|----------|
| `initialise(parent)` |
| `step(deltaTime)` |
| `pointSplash(z, x, height)` |
| `smoothSplash()` |
| `normalAt(z, x)` |
| `heightAt(z, x)` |
| `worldPositionToMesh(z, x)` |
| `destroy()` |
