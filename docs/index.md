# About
**See installation tab for setting things up**

Nami is a real-time 2D wave simulation module for Roblox built on EditableMesh. It simulates wave propagation using the discrete wave equation and renders the result as a deformable water surface.

# The Math

The 2D wave equation is given by:

$$
\frac{\partial^2 u}{\partial t^2}
=
c^2 \left(
\frac{\partial^2 u}{\partial x^2}
+
\frac{\partial^2 u}{\partial z^2}
\right)
$$

Where u(x,z,t) is a function of water height at point (x,z) during time t.

The terms to the right resemble the curvature of the surface and are approximated with central finite differences. The second time derivative is then solved using Verlet integration:

$$
u_{t+\Delta t} = 2u_t - u_{t-\Delta t} + a_t \Delta t^2
$$

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
