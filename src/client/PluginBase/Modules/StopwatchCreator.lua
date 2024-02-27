local RunService = game:GetService("RunService")
local StopwatchCreator = {}

-- Returns a new stopwatch
function StopwatchCreator.new(startNil:boolean)
	local self = setmetatable({},StopwatchCreator)
	self.start = not startNil and tick() or nil
	self.freezeStart = nil
	self.freezeTimeSubtract = 0
	return self
end

-- Returns how much has elapsed since the given tick() point
function StopwatchCreator.GetTimePassed(startTime:number):number
    return tick() - startTime
end

-- Resets the stopwatch
function StopwatchCreator:Reset()
    self.start = tick()
    self.freezeStart = nil
    self.freezeTimeSubtract = 0
end

-- Updates how much times needs to be subtracted from the stopwatch to account for frozen time
function StopwatchCreator:UpdateFreezeTimeSub():boolean
    local freezeStart = self.freezeStart
    if not freezeStart then
        return false
    end
    self.freezeTimeSubtract += StopwatchCreator.GetTimePassed(freezeStart)
    self.freezeStart = tick()
    return true
end

-- Pauses the stopwatch's time from passing
function StopwatchCreator:Freeze()
    -- this func already resets the freeze start so we don't need to do it again
    if self:UpdateFreezeTimeSub() then
        return
    end
    self.freezeStart = tick()
end

-- Unpauses the stopwatch
function StopwatchCreator:Unfreeze()
    self:UpdateFreezeTimeSub()
    self.freezeStart = nil
end

-- Checks if the stopwatch has passed a certain time and reset it if it has
function StopwatchCreator:HasPassedTime(t,noReset):boolean
    if not self.start or self() >= t then
        if not noReset then
            self:Reset()
        end
        return true
    else
        return false
    end
end

-- Returns how much time has elapsed since the stopwatch was started
function StopwatchCreator:GetStopwatchTime():number
    local currentTime = tick()
    self.start = self.start or currentTime
    self:UpdateFreezeTimeSub()

    local timePassed = StopwatchCreator.GetTimePassed(self.start) - self.freezeTimeSubtract
    return timePassed
end

function StopwatchCreator:GetAlpha(totalTime:number,noClamp)
    local alpha = self()/totalTime

    if noClamp then
        return alpha
    end
    return math.clamp(alpha,0,1)
end
function StopwatchCreator.newTimer(waitTime,onLoop)
    local stopwatch = StopwatchCreator.new()
    local deltaStopwatch = StopwatchCreator.new()
    while not stopwatch:HasPassedTime(waitTime,true) do
        local alpha = stopwatch:GetAlpha(waitTime)
        if onLoop(alpha,stopwatch(),deltaStopwatch()) then
            break
        end
        deltaStopwatch:Reset()
        RunService.Heartbeat:Wait()
    end
end

StopwatchCreator.__index = StopwatchCreator
StopwatchCreator.__call = function(self)
    return self:GetStopwatchTime()
end

return StopwatchCreator