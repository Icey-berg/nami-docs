
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
