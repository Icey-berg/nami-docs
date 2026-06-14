# Surface Queries

## surface:worldPositionToMesh()

Converts a world-space position into mesh grid coordinates. All mesh related functions (`pointSplash`, `normalAt`, `heightAt`, etc) take mesh grid coordinates. Use this function to convert world to mesh grid.

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

__
## surface:normalAt()

Returns the surface normal at a grid coordinate.

Useful for buoyancy and object orientation.

### Syntax

```lua
local z, x = surface:worldPositionToMesh(boat.Z, boat.X)
local normal = surface:normalAt(z, x)
```

### Parameters

| Parameter | Type |
|-----------|------|
| `meshZ` | `number` |
| `meshX` | `number` |

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
local height = surface:heightAt(meshZ, meshX)
```

### Parameters

| Parameter | Type |
|-----------|------|
| `meshZ` | `number` |
| `meshX` | `number` |

### Returns

```lua
number
```

### Example

```lua
local z, x = surface:worldPositionToMesh(boat.Z, boat.X)
local height = surface:heightAt(z, x)
```

---
