# Runtime

## surface:step()

Advances the simulation.
This should typically be called every frame from `RunService`.

### Syntax

```lua
local didstep = surface:step(deltaTime)
```
> **Note:** step() normally wont step everytime you call it. This is to make sure it runs at the defined FPS. It will return true if it did actually update the mesh.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `deltaTime` | `number` | Frame delta time. |

### Returns

```lua
(boolean) -- Did run
```


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
