-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Instances
local emitterScriptActor = script.Parent
local modules = Players.LocalPlayer.PlayerScripts.PluginBase.Modules

-- Modules
local StopwatchCreator = require(modules.StopwatchCreator)

-- Variables
local activeParticles = {}

local function updateParticles()
    local parts,cframes = {},{}

    local toDestroy = {}
    for _,particleInfo in activeParticles do        
        local particle3D:BasePart = particleInfo.Particle

        -- remove dead particles
        local timePassed = particleInfo.LifeStopwatch()
        if timePassed>=particleInfo.Lifetime then
            table.remove(activeParticles,table.find(activeParticles,particleInfo))
            table.insert(toDestroy,particleInfo)
            
            continue
        end

        -- calculate new position
        local newCF = CFrame.new(particleInfo.StartPosition + particleInfo.Speed*timePassed*particleInfo.Angle)
        table.insert(parts,particle3D)
        table.insert(cframes,newCF)
    end

    task.synchronize()
    workspace:BulkMoveTo(parts,cframes,Enum.BulkMoveMode.FireCFrameChanged)
    for _,particleInfo in toDestroy do
        particleInfo.Particle:Destroy()
        particleInfo.EmitInfo:Destroy()
    end

end

local loopActive = false
local function bootUpdateLoop()
    if loopActive then
        return
    end
    loopActive = true
    
    local updateConnection
    updateConnection = RunService.Stepped:ConnectParallel(function()
        if #activeParticles == 0 then
            loopActive = false
            updateConnection:Disconnect()
            return
        end

        updateParticles()
    end)
end

local function loadEmit(emitInfo:Configuration)
    local emitter3D:Part = emitInfo.SourcePointer.Value
    local particle3D:BasePart = emitter3D:Clone()
    particle3D:RemoveTag("Emitter3D")
    particle3D.Parent = workspace.Terrain
    
    -- load particle from emit config
    table.insert(activeParticles,{
        Speed = emitInfo:GetAttribute("Speed");
        Lifetime = emitInfo:GetAttribute("Lifetime");
        LifeStopwatch = StopwatchCreator.new();
        Particle = particle3D;
        StartPosition = emitter3D.CFrame.Position;
        Emitter3D = emitter3D;
        Angle = emitInfo:GetAttribute("Angle");
        EmitInfo=emitInfo;
    })
    bootUpdateLoop()
end
local toEmit:Folder = emitterScriptActor.ToEmit

for _,emitInfo:Configuration in toEmit:GetChildren() do
    loadEmit(emitInfo)
end
toEmit.ChildAdded:Connect(loadEmit)
