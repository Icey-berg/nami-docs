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
local Nami = require(script.NamiFinal)
local ocean: Nami.WaterSurface = Nami.create(50,50, 1, 30, 1/50, 0.98,1)
ocean:initialise(workspace)
ocean.meshPart.Material = Enum.Material.Glass

game.RunService.RenderStepped:Connect(function(dt)
	local t = os.clock()
	if ocean:step(dt) then
		local z,x = ocean:worldPositionToMesh(math.sin((2*math.pi)/2 * t)*10, math.cos((2*math.pi)/2 * t)*10)
		ocean:pointSplash(z,x,5)
	end
end)
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
