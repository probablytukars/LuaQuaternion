-- v1.3.0

--[[
    SOURCE: https://github.com/Quenty/NevermoreEngine/blob/main/src/WrappedSpring/src/Shared/WrappedSpring.lua
    [MIT LICENSE]
--]]

local ERROR_FORMAT = "%q is not a valid member of WrappedSpring."

export type WrappedSpring = {
    new: (initial: number, damping: number, speed: number, min: number, max: number, clock: () -> number) -> WrappedSpring,
    Reset: (target: number?) -> nil,
    Impulse: (self: WrappedSpring, velocity: number) -> nil,
    TimeSkip: (self: WrappedSpring, delta: number) -> nil,
    
    Position: number,
    p: number,
    Velocity: number,
    v: number,
    Target: number,
    t: number,
    Damping: number,
    d: number,
    Speed: number,
    s: number,
    Clock: () -> number
}

--[=[
    @class WrappedSpring
    @grouporder ["Constructors", "Methods"]
    
    This class represents a WrappedSpring, which supports number values on a specified range.
    A common use case is angles in a wrapped range [-pi, pi).
    
    This is lazily evaluated meaning it only updates when indexed.
]=]
--[=[
    @prop Position number
    
    The current position at the given clock time. 
    Assigning the position will change the WrappedSpring to have that position.
]=]
--[=[
    @prop p number
    @alias Position
]=]
--[=[
    @prop Velocity number
    
    The current velocity. Assigning the velocity will change the WrappedSpring to have 
    that velocity.
]=]
--[=[
    @prop v number
    @alias Velocity
]=]
--[=[
    @prop Target number
    
    The current target. Assigning the target will change the WrappedSpring to have 
    that target.
]=]
--[=[
    @prop t number
    @alias Target
]=]
--[=[
    @prop Damping number
    
    The current damper, defaults to 1. At 1 the WrappedSpring is critically damped. 
    At less than 1, it will be underdamped, and thus, bounce, and at over 1, 
    it will be critically damped.
]=]
--[=[
    @prop d number
    @alias Damping
]=]
--[=[
    @prop Speed number
    
    The speed, defaults to 1, but should be between [0, infinity)
]=]
--[=[
    @prop s number
    @alias Speed
]=]
--[=[
    @prop Clock
]=]
local WrappedSpring = {_type = "WrappedSpring"}

--[=[
    @function
    @group Constructors
    
    Constructs a new WrappedSpring at the position and target specified.
    
    `min` defaults to -pi, and `max` defaults to pi.
]=]
function WrappedSpring.new(initial: number, damping: number, speed: number, min: number, max: number, clock: () -> number)
    initial = initial or Vector3.new()
    damping = damping or 1
    speed = speed or 1
	clock = clock or os.clock
	min = min or -math.pi
	max = max or math.pi
    return setmetatable({
        _clock = clock;
        _time = clock();
        _position = initial;
        _velocity = 0 * initial;
        _target = initial;
        _damping = damping;
        _speed = speed;
		_initial = initial;
		_min = min;
		_max = max;
    }, WrappedSpring)
end

--[=[
    @method
    @group Methods
    
    Resets the WrappedSprings' position and target to the initial value the
    WrappedSpring was created with. Sets the velocity to zero.
]=]
function WrappedSpring:Reset(target: number?)
	local now = self._clock()
	local setTo = target or self._initial
	self._position = setTo
	self._target = setTo
	self._velocity = 0 * setTo
	self._time = now
end

--[=[
    @method
    @group Methods
    
    Impulses the WrappedSpring, increasing velocity by the amount given.
    This is useful to make something shake.
]=]
function WrappedSpring:Impulse(velocity: number)
	self._velocity = self._velocity + velocity
end

--[=[
    @method
    @group Methods
    Instantly skips the WrappedSpring forwards by the given time.
]=]
function WrappedSpring:TimeSkip(delta: number)
    local now = self._clock()
    local position, velocity = self:_positionVelocity(now+delta)
    self._position = position
    self._velocity = velocity
    self._time = now
end

function WrappedSpring:__index(index)
    if WrappedSpring[index] then
        return WrappedSpring[index]
    elseif index == "Position" or index == "p" then
        local position, _ = self:_positionVelocity(self._clock())
        return position
    elseif index == "Velocity" or index == "v" then
        local _, velocity = self:_positionVelocity(self._clock())
        return velocity
    elseif index == "Target" or index == "t" then
        return self._target
    elseif index == "Damping" or index == "d" then
        return self._damping
    elseif index == "Speed" or index == "s" then
        return self._speed
    elseif index == "Clock" then
        return self._clock
    else
        error(string.format(ERROR_FORMAT, tostring(index)), 2)
    end
end

function WrappedSpring:__newindex(index, value)
	local now = self._clock()
    if index == "Position" or index == "p" then
        local _, velocity = self:_positionVelocity(now)
        self._position = value
        self._velocity = velocity
        self._time = now
    elseif index == "Velocity" or index == "v" then
        local position, _ = self:_positionVelocity(now)
        self._position = position
        self._velocity = value
        self._time = now
    elseif index == "Target" or index == "t" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._target = value
        self._time = now
    elseif index == "Damping" or index == "d" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._damping = value
        self._time = now
    elseif index == "Speed" or index == "s" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._speed = value < 0 and 0 or value
        self._time = now
    elseif index == "Clock" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._clock = value
        self._time = value()
    else
        error(string.format(ERROR_FORMAT, tostring(index)), 2)
    end
end

local function wrap(a, min, max) return (a - min) % (max - min) + min end

local function wrappedDifference(a, b, min, max)
    return wrap(wrap(b, min, max) - wrap(a, min, max), min, max)
end

function WrappedSpring:_positionVelocity(now)
    local currentPosition = self._position
    local currentVelocity = self._velocity
    local targetPosition = self._target
    local dampingFactor = self._damping
    local speed = self._speed
    local min = self._min
    local max = self._max
    
    local deltaTime = speed * (now - self._time)
    local dampingSquared = dampingFactor * dampingFactor
    
    local angFreq, sinTheta, cosTheta
    if dampingSquared < 1 then
        angFreq = math.sqrt(1 - dampingSquared)
        local exponential = math.exp(-dampingFactor * deltaTime) / angFreq
        cosTheta = exponential * math.cos(angFreq * deltaTime)
        sinTheta = exponential * math.sin(angFreq * deltaTime)
    elseif dampingSquared == 1 then
        angFreq = 1
        local exponential = math.exp(-dampingFactor * deltaTime) / angFreq
        cosTheta, sinTheta = exponential, exponential * deltaTime
    else
        angFreq = math.sqrt(dampingSquared - 1)
        local angFreq2 = 2 * angFreq
        local u = math.exp((-dampingFactor + angFreq) * deltaTime) / angFreq2
        local v = math.exp((-dampingFactor - angFreq) * deltaTime) / angFreq2
        cosTheta, sinTheta = u + v, u - v
    end
    
    local pullToTarget = 1 - (angFreq * cosTheta + dampingFactor * sinTheta)
    local velPosPush = sinTheta / speed
    local velPushRate = speed * sinTheta
    local velocityDecay = angFreq * cosTheta - dampingFactor * sinTheta
    
    local positionDifference = wrappedDifference(currentPosition, targetPosition, min, max)
    
    local newPosition = currentPosition + (positionDifference * pullToTarget) + (currentVelocity * velPosPush)
    newPosition = wrap(newPosition, min, max)
    
    local newVelocity = (positionDifference * velPushRate) + (currentVelocity * velocityDecay)
    
    return newPosition, newVelocity
end

return WrappedSpring