# Installation

Place the `Nami` ModuleScript somewhere accessible and require it:
```lua
local Nami = require(path.To.Nami)
```
It is recommended that Nami is ran on the client.

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
| `blurSigma` | `number` |Dimensionless| Gaussian blur strength used for postprocessing. |

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

> **Note:** If the water looks spiky, the blur is too low. If the water lacks detail, the blur is too high.
>
---

# The CFL Condition **(important)**
For stability, Nami will refuse to initialise if the given parameters do not satisfy the CFL condition:
$$
\frac{wavespeed \times timestep}{vertspacing} \le \frac{1}{\sqrt{2}}
$$
For most use cases you probably wont have to worry about vertex spacing, just balancing time step to the wave speed you want. Faster waves require smaller step sizes.

# Initialisation

## surface:initialise()

Creates the EditableMesh, MeshPart, and simulation buffers.

**MUST** be called before any other surface method.

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
