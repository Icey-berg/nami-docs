--!nonstrict

local AssetService = game:GetService("AssetService")

local Nami = {}
Nami.__index = Nami

type NumberGrid = { [number]: number }
type VertexGrid = { [number]: number }
type Kernel3x3 = { [number]: number }

export type WaterSurface = {
	LengthX: number,
	LengthZ: number,
	VertsPerStud: number,
	WaveSpeed: number,
	TimeStep: number,
	GridSpacing: number,
	Damping: number,
	Sigma: number,

	_accumulatedDt: number,

	_initialised: boolean,

	_destroyed: boolean,

	meshPart: MeshPart?,
	editableMesh: EditableMesh?,

	vertexGrid: VertexGrid?,
	physicsField: NumberGrid?,
	previousPhysicsField: NumberGrid?,
	laplacian: NumberGrid?,
	dhdx: NumberGrid?,
	dhdz: NumberGrid?,

	blurKernels: Kernel3x3?,

	physicsSizeX: number?,
	physicsSizeZ: number?,

	meshXSpacing: number?,
	meshZSpacing: number?,

	physicsGridSpacing: number?,

	initialise: (self: WaterSurface, parent: Instance) -> (),
	step: (self: WaterSurface, deltaTime: number) -> boolean,
	normalAt: (self: WaterSurface) -> Vector3,
	pointSplash: (self: WaterSurface, z: number, x: number, y: number) -> (),
	destroy: (self: WaterSurface) -> (),
	worldPositionToMesh: (self: WaterSurface, z: number, x: number) -> (number, number),

	_computeLaplacian: (self: WaterSurface) -> (),
	_computeBlurBuffer: (self: WaterSurface) -> NumberGrid,
	_stepField: (self: WaterSurface, dt: number) -> (),
	_verifyCFL: (self: WaterSurface) -> boolean,
	_assertAlive: (self: WaterSurface) -> (),
}

function Nami.create(
	lengthX: number,
	lengthZ: number,
	vertsPerStud: number,
	waveSpeed: number,
	timeStep: number,
	damping: number,
	blurSigma: number
): WaterSurface
	local self = setmetatable({
		LengthX = lengthX,
		LengthZ = lengthZ,
		VertsPerStud = vertsPerStud,
		WaveSpeed = waveSpeed,
		TimeStep = timeStep,
		Damping = damping,
		Sigma = blurSigma,
		_accumulatedDt = 0,
		_initialised = false,
		_destroyed = false
	}, Nami) :: any

	return self :: WaterSurface
end

-- MUST call before using any other function
function Nami:initialise(parent: Instance)
	self._initialised = true
	local editableMesh = AssetService:CreateEditableMesh()

	local xVerts = math.floor(self.LengthX * self.VertsPerStud) + 1
	local zVerts = math.floor(self.LengthZ * self.VertsPerStud) + 1

	local xSpacing = self.LengthX / (xVerts - 1)
	local zSpacing = self.LengthZ / (zVerts - 1)

	local vertexGrid: VertexGrid = {}
	local physicsField: NumberGrid = {}

	for index = 1, zVerts * xVerts do
		local z = (index - 1) % zVerts + 1
		local x = math.ceil(index / zVerts)

		local worldX = ((x - 1) * xSpacing) - self.LengthX / 2
		local worldZ = ((z - 1) * zSpacing) - self.LengthZ / 2

		local vertexId = editableMesh:AddVertex(
			Vector3.new(worldX, 0, worldZ)
		)

		vertexGrid[index] = vertexId
		physicsField[index] = 0
	end

	-- triangulate from vertices
	for zi = 1, zVerts - 1 do
		for xi = 1, xVerts - 1 do

			local i = zi +(xi-1)*zVerts

			local v1 = vertexGrid[i]
			local v2 = vertexGrid[i+zVerts]
			local v3 = vertexGrid[i+1+zVerts]
			local v4 = vertexGrid[i+1]

			editableMesh:AddTriangle(v1, v3, v2)
			editableMesh:AddTriangle(v1, v4, v3)
		end
	end

	local meshPart = AssetService:CreateMeshPartAsync(
		Content.fromObject(editableMesh)
	)

	meshPart.Anchored = true
	meshPart.Parent = parent
	meshPart.BrickColor = BrickColor.Blue()

	self.meshPart = meshPart
	self.editableMesh = editableMesh

	self.vertexGrid = vertexGrid
	self.physicsField = physicsField
	self.previousPhysicsField = physicsField

	self.physicsSizeX = xVerts
	self.physicsSizeZ = zVerts

	self.meshXSpacing = xSpacing
	self.meshZSpacing = zSpacing

	self.physicsGridSpacing = xSpacing

	self.blurKernels = Nami._computeBlurKernels(self.Sigma)

	if self:_verifyCFL() == false then
		error("CFL Condition Unsatisfied")
	else
		print("CFL Condition Satisfied")
	end
end

-- Attach to RunService
function Nami:step(deltaTime: number)
	self:_assertAlive()
	self:_assertInitialised()

	self._accumulatedDt = self._accumulatedDt + deltaTime
	if self._accumulatedDt < self.TimeStep then
		return false
	end

	self._accumulatedDt = 0

	self:_computeLaplacian()
	self:_stepField(self.TimeStep) 

	local meshField = self:_computeBlurBuffer()

	local vertexGrid = self.vertexGrid :: VertexGrid
	local editableMesh = self.editableMesh :: EditableMesh

	local meshXSpacing = self.meshXSpacing :: number
	local meshZSpacing = self.meshZSpacing :: number

	self.blurBufferField = meshField

	self:_computeDeltaFields()


	for index, vertex in pairs(vertexGrid) do

		local z = (index - 1) % self.physicsSizeZ + 1
		local x = math.ceil(index / self.physicsSizeZ)

		editableMesh:SetPosition(
			vertex,
			Vector3.new(
				x * meshXSpacing  - self.LengthX / 2,
				meshField[index],
				z * meshZSpacing  - self.LengthZ / 2
			)
		)
	end

	return true
end


function Nami:normalAt(relativeZ: number, relativeX: number): Vector3
	local i = relativeZ +(relativeX-1)*self.physicsSizeZ
	local vec = Vector3.new(self.dhdx[i],1,self.dhdz[i])

	return vec / vec.Magnitude
end

function Nami:heightAt(relativeZ: number, relativeX: number): number


	return self.blurBufferField[relativeZ +(relativeX-1)*self.physicsSizeZ]
end

function Nami:worldPositionToMesh(z: number, x: number): (number, number)
	local relativePos: Vector3 = self.meshPart.CFrame:PointToObjectSpace(Vector3.new(x + self.LengthX / 2,0,z + self.LengthZ / 2))
	local rz = relativePos.Z
	local rx = relativePos.X

	local pz = math.round(rz*self.VertsPerStud)
	local px = math.round(rx*self.VertsPerStud)
	return pz, px

end

-- Displaces a single point on the surface. May cause choppier waves.
function Nami:pointSplash(z: number, x: number, y: number)
	if z <= 0 or x <= 0 or z > self.physicsSizeZ or x > self.physicsSizeX then
		return
	end

	local field = self.physicsField :: NumberGrid


	local i = z +(x-1)*self.physicsSizeZ
	field[i] = y
end

function Nami:destroy()
	Nami:_assertAlive()
	self.meshPart:Destroy()
	self._destroyed = true
end

function Nami:_computeLaplacian()
	local field = self.physicsField :: NumberGrid

	local physicsSizeX = self.physicsSizeX :: number
	local physicsSizeZ = self.physicsSizeZ :: number
	local spacing = self.physicsGridSpacing :: number

	local laplacian: NumberGrid = {}

	for index = 1, physicsSizeX * physicsSizeZ do
		local z = (index - 1) % physicsSizeZ + 1

		local xm = field[if index > physicsSizeZ then index - physicsSizeZ else index]
		local xp = field[if index <= physicsSizeX * physicsSizeZ - physicsSizeZ then index + physicsSizeZ else index]

		local zm = field[if z > 1 then index - 1 else index]
		local zp = field[if z < physicsSizeZ then index + 1 else index]

		local center = field[index]

		laplacian[index] =
			(xp + xm + zp + zm - 4 * center) / (spacing ^ 2)
	end

	self.laplacian = laplacian
end

function Nami._computeBlurKernels(sigma: number)
	local kernel = {}
	local sum = 0

	local sigma2 = sigma * sigma
	local denom = 2 * sigma2

	for i = -2, 2 do
		local v = math.exp(-(i * i) / denom)

		kernel[i + 3] = v
		sum += v
	end

	for i = 1, 5 do
		kernel[i] /= sum
	end

	return kernel
end

function Nami:_computeDeltaFields()
	local blurredField = self.blurBufferField :: NumberGrid

	local physicsSizeX = self.physicsSizeX :: number
	local physicsSizeZ = self.physicsSizeZ :: number
	local spacing = self.physicsGridSpacing :: number

	local dhdx: NumberGrid = {}
	local dhdz: NumberGrid = {}

	for index = 1, physicsSizeX * physicsSizeZ do
		local z = (index - 1) % physicsSizeZ + 1

		local xm = blurredField[if index > physicsSizeZ then index - physicsSizeZ else index]
		local xp = blurredField[if index <= physicsSizeX * physicsSizeZ - physicsSizeZ then index + physicsSizeZ else index]

		local zm = blurredField[if z > 1 then index - 1 else index]
		local zp = blurredField[if z < physicsSizeZ then index + 1 else index]

		local center = blurredField[index]

		dhdx[index] = (xp - xm) / (2 * spacing)
		dhdz[index] = (zp - zm) / (2 * spacing)
	end



	self.dhdx = dhdx
	self.dhdz = dhdz
end

function Nami:_computeBlurBuffer()
	local field = self.physicsField
	local kernel = self.blurKernels

	local width = self.physicsSizeX
	local lengthZ = self.physicsSizeZ


	-- horizontal pass
	local temp = table.create(width * lengthZ)

	for x = 1, width do
		for z = 1, lengthZ do
			local x1 = math.clamp(x - 2, 1, width)
			local x2 = math.clamp(x - 1, 1, width)
			local x3 = x
			local x4 = math.clamp(x + 1, 1, width)
			local x5 = math.clamp(x + 2, 1, width)

			local index =
				(x - 1) * lengthZ + z

			temp[index] =
				kernel[1] * field[(x1 - 1) * lengthZ + z] +
				kernel[2] * field[(x2 - 1) * lengthZ + z] +
				kernel[3] * field[(x3 - 1) * lengthZ + z] +
				kernel[4] * field[(x4 - 1) * lengthZ + z] +
				kernel[5] * field[(x5 - 1) * lengthZ + z]
		end
	end

	-- vertical pass
	local blurBuffer = table.create(width * lengthZ)

	for x = 1, width do
		for z = 1, lengthZ do
			local z1 = math.clamp(z - 2, 1, lengthZ)
			local z2 = math.clamp(z - 1, 1, lengthZ)
			local z3 = z
			local z4 = math.clamp(z + 1, 1, lengthZ)
			local z5 = math.clamp(z + 2, 1, lengthZ)

			local index =
				(x - 1) * lengthZ + z

			blurBuffer[index] =
				kernel[1] * temp[(x - 1) * lengthZ + z1] +
				kernel[2] * temp[(x - 1) * lengthZ + z2] +
				kernel[3] * temp[(x - 1) * lengthZ + z3] +
				kernel[4] * temp[(x - 1) * lengthZ + z4] +
				kernel[5] * temp[(x - 1) * lengthZ + z5]
		end
	end

	return blurBuffer
end
-- does rewrite state buffers
function Nami:_stepField(dt: number)
	local curr = self.physicsField :: NumberGrid
	local prev = self.previousPhysicsField :: NumberGrid
	local laplacian = self.laplacian :: NumberGrid

	local physicsSizeX = self.physicsSizeX :: number
	local physicsSizeZ = self.physicsSizeZ :: number

	local nextField: NumberGrid = {}

	for index = 1, physicsSizeX * physicsSizeZ do
		local uNext =
			(2 * curr[index])
		- prev[index]
			+ (self.WaveSpeed ^ 2)
			* (dt * dt)
			* laplacian[index]

		-- damping for numerical stability
		uNext *= self.Damping

		nextField[index] = uNext
	end

	self.previousPhysicsField = curr	
	self.physicsField = nextField
end

function Nami:_verifyCFL(): boolean
	return ((self.WaveSpeed * self.TimeStep) / self.physicsGridSpacing) < 1 / math.sqrt(2)
end

function Nami:_assertAlive()
	assert(not self._destroyed, "Nami instance is already destroyed")
end

function Nami:_assertInitialised()
	assert(self._initialised, "Please initialise Nami first")
end

return Nami