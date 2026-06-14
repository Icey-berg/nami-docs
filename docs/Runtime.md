# Runtime

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
surface:step()

surface:destroy()

surface:step() --Throws an error
```
