-- Settings
local minimumEmitScripts = 3
local maxParticlesPerScript = 200


-- Services
local RunService = game:GetService("RunService")

-- Instances
local activeEmitScripts = script.Parent.ActiveEmitScripts

-- Variables
local Emitter3D = {}
local allEmitActors:{Actor} = {}

-- Local Functions
local function random(min:number,max:number)
    return Random.new():NextNumber(min,max)
end

local function randomFromRange(numberRange:NumberRange)
    return random(numberRange.Min,numberRange.Max)
end

local function addEmitScript()
    local emitterScriptActor = script.Parent.EmitterScriptActor:Clone()
    table.insert(allEmitActors,emitterScriptActor)
    emitterScriptActor.Parent = activeEmitScripts

    emitterScriptActor:SendMessage("BeginDetection")
    return emitterScriptActor
end

local function getEmitActor()
    local chosenEmitActorInfo
    for _,emitActor in allEmitActors do
        local amountToEmit = #emitActor.ToEmit:GetChildren()
        if amountToEmit==maxParticlesPerScript then
            continue
        end

        -- if there is no chosen actor then we can just use this one
        local info = {actor = emitActor, amount = amountToEmit}
        if not chosenEmitActorInfo then
            chosenEmitActorInfo = info
            continue
        end

        -- we need to pick the script with lowest amount to emit so load is spread evenly
        if amountToEmit>chosenEmitActorInfo.amount then
            continue
        end
        chosenEmitActorInfo = info
    end

    -- if there are no avalibe ones then make new one
    if not chosenEmitActorInfo then
        return addEmitScript()
    end

    return chosenEmitActorInfo.actor
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

        local chosenEmitActor:Actor =  getEmitActor()
        emitInfo.Parent = chosenEmitActor.ToEmit
    end    
end

-- emit the emitter3d based off it's rate
local function startRateEmitting(emitter3D:Part)
    task.spawn(function()
        while emitter3D.Parent == workspace do
            emit3DParticle(emitter3D,1)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function onEmitter3DAdded(emitter3D:BasePart)
    if not emitter3D:HasTag("Emitter3D") then
        return
    end

    startRateEmitting(emitter3D)
end

-- Global Functions
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

    startRateEmitting(part)
end

for _ = 1,minimumEmitScripts do
    addEmitScript()
end

-- load emitters already in workspace
for _,object in workspace:GetDescendants() do
    onEmitter3DAdded(object)
end

-- set up to add new emitters
workspace.DescendantAdded:Connect(onEmitter3DAdded)

--[[RunService.Stepped:Connect(function(time, deltaTime)
    local totalAmount = 0
    for num,actor in allEmitActors do
        local toEmitNum = #actor.ToEmit:GetChildren()
        print("emits for actor " .. tostring(num) .. ": " .. toEmitNum)
        totalAmount+=toEmitNum
    end


    print("total particles:",totalAmount)
end)--]]
return Emitter3D