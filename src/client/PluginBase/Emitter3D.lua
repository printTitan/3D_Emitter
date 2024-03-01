-- Settings
local minimumEmitScripts = 3
local maxParticlesPerScript = 50


-- Services
local RunService = game:GetService("RunService")

-- Instances
local activeEmitScripts = script.Parent.ActiveEmitScripts

-- Variables
local allEmitScripts = {}

local Emitter3D = {}

local function random(min:number,max:number)
    return Random.new():NextNumber(min,max)
end

local function randomFromRange(numberRange:NumberRange)
    return random(numberRange.Min,numberRange.Max)
end

local function addEmitScript()
    local emitterScriptActor = script.Parent.EmitterScriptActor:Clone()
    table.insert(allEmitScripts,emitterScriptActor)
    emitterScriptActor.Parent = activeEmitScripts

    emitterScriptActor:SendMessage("BeginDetection")
end

local function emit3DParticle(emitter3D:Part,amount:number)
    local emitterConfig:Configuration = emitter3D.EmitterConfig
    for _ = 1,amount do
        local emitInfo = Instance.new("Configuration")
        emitInfo:SetAttribute("Speed",randomFromRange(emitterConfig:GetAttribute("Speed")))
        emitInfo:SetAttribute("Lifetime",randomFromRange(emitterConfig:GetAttribute("Lifetime")))
        emitInfo:SetAttribute("Angle",Vector3.new(0,1,0))
        local sourcePointer=  Instance.new("ObjectValue")
        sourcePointer.Name = "SourcePointer"
        sourcePointer.Value = emitter3D
        sourcePointer.Parent = emitInfo

        local chosenEmitActor:Actor = allEmitScripts[1]
        emitInfo.Parent = chosenEmitActor.ToEmit
    end    
end

local function onEmitterAdded(emitter3D:Part)
    task.spawn(function()
        while emitter3D.Parent == workspace do
            emit3DParticle(emitter3D,1)
            RunService.RenderStepped:Wait()
        end
    end)
end

function Emitter3D.AssignPartAsEmitter(part:BasePart)
    local emitterConfig = Instance.new("Configuration")
    emitterConfig.Name = "EmitterConfig"
    emitterConfig:SetAttribute("Rate",20)
    emitterConfig:SetAttribute("Lifetime",NumberRange.new(5,10))
    emitterConfig:SetAttribute("Speed",NumberRange.new(5))
    emitterConfig.Parent = part
    part:AddTag("Emitter3D")
    if not part:IsDescendantOf(workspace) then
        return
    end

    onEmitterAdded(part)
end

local function onEmitter3DAdded(emitter3D:BasePart)
    if not emitter3D:HasTag("Emitter3D") then
        return
    end

    onEmitterAdded(emitter3D)
end


-- load emitters already in workspace
for _,object in workspace:GetDescendants() do
    onEmitter3DAdded(object)
end

-- set up to add new emitters
workspace.DescendantAdded:Connect(onEmitter3DAdded)

return Emitter3D