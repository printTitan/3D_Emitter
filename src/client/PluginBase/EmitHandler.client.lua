-- Services
local RunService = game:GetService("RunService")

-- Instances
local activeEmitScripts = script.Parent.ActiveEmitScripts

-- Variables
local allEmitScripts = {}

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

local function assignAsEmitter(part:BasePart)
    local emitterConfig = Instance.new("Configuration")
    emitterConfig.Name = "EmitterConfig"
    emitterConfig:SetAttribute("Rate",20)
    emitterConfig:SetAttribute("Lifetime",NumberRange.new(5,10))
    emitterConfig:SetAttribute("Speed",NumberRange.new(5))
    emitterConfig.Parent = part
    part:AddTag("Emitter3D")
    if part.Parent~=workspace then
        return
    end

    onEmitterAdded(part)
end

workspace.DescendantAdded:Connect(function(emitter3D:BasePart)
    if not emitter3D:HasTag("Emitter3D") then
        return
    end

    onEmitterAdded(emitter3D)
end)

addEmitScript()
assignAsEmitter(workspace:WaitForChild("EmitPart"))