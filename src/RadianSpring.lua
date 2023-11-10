-- v1.3.0

--[[
    SOURCE: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
--]]

local ERROR_FORMAT = "%q is not a valid member of RadianSpring."

local pi = math.pi
local tau = pi * 2

local function wrap(x) return ((x + tau) % (2 * tau)) - tau end

export type RadianSpring = {
    new: (initial: number, damping: number, speed: number, clock: () -> number) -> RadianSpring,
    Reset: (target: number?) -> nil,
    Impulse: (self: RadianSpring, velocity: number) -> nil,
    TimeSkip: (self: RadianSpring, delta: number) -> nil,
    
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
    @class RadianSpring
    @grouporder ["Constructors", "Methods"]
    
    This class represents a RadianSpring, which is used for springing angles.
    This is specifically designed to spring angles towards 0, and supports
    the range [-2pi, 2pi) also known as [-tau, tau), which essentially
    gives the angles "double cover" which is a useful property especially
    with angular springs as it allows you to control the "direction" that
    the angle travels in, just add or subtract tau to change the direction.
    
    This is lazily evaluated meaning it only updates when indexed.
]=]
--[=[
    @prop Position number
    
    The current position at the given clock time. 
    Assigning the position will change the RadianSpring to have that position.
]=]
--[=[
    @prop p number
    @alias Position
]=]
--[=[
    @prop Velocity number
    
    The current velocity. Assigning the velocity will change the RadianSpring to have 
    that velocity.
]=]
--[=[
    @prop v number
    @alias Velocity
]=]
--[=[
    @prop Damping number
    
    The current damper, defaults to 1. At 1 the RadianSpring is critically damped. 
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
local RadianSpring = {_type = "RadianSpring"}

--[=[
    @function
    @group Constructors
    
    Constructs a new RadianSpring at the position specified.
]=]
function RadianSpring.new(initial: number, damping: number, speed: number, clock: () -> number)
    initial = initial or 0
    damping = damping or 1
    speed = speed or 1
	clock = clock or os.clock
    return setmetatable({
        _clock = clock;
        _time = clock();
        _position = initial;
        _velocity = 0 * initial;
        _damping = damping;
        _speed = speed;
		_initial = initial;
    }, RadianSpring)
end

--[=[
    @method
    @group Methods
    
    Resets the RadianSprings' position and target to the initial value the
    RadianSpring was created with. Sets the velocity to zero.
]=]
function RadianSpring:Reset()
	local now = self._clock()
	self._position = 0
	self._velocity = 0
	self._time = now
end

--[=[
    @method
    @group Methods
    
    Impulses the RadianSpring, increasing velocity by the amount given.
    This is useful to make something shake.
]=]
function RadianSpring:Impulse(velocity: number)
	self._velocity = self._velocity + velocity
end

--[=[
    @method
    @group Methods
    Instantly skips the RadianSpring forwards by the given time.
]=]
function RadianSpring:TimeSkip(delta: number)
    local now = self._clock()
    local position, velocity = self:_positionVelocity(now+delta)
    self._position = position
    self._velocity = velocity
    self._time = now
end

function RadianSpring:__index(index)
    if RadianSpring[index] then
        return RadianSpring[index]
    elseif index == "Position" or index == "p" then
        local position, _ = self:_positionVelocity(self._clock())
        return position
    elseif index == "Velocity" or index == "v" then
        local _, velocity = self:_positionVelocity(self._clock())
        return velocity
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

function RadianSpring:__newindex(index, value)
	local now = self._clock()
    if index == "Position" or index == "p" then
        local _, velocity = self:_positionVelocity(now)
        self._position = wrap(value)
        self._velocity = velocity
        self._time = now
    elseif index == "Velocity" or index == "v" then
        local position, _ = self:_positionVelocity(now)
        self._position = position
        self._velocity = value
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



function RadianSpring:_positionVelocity(now)
    local currentPosition = self._position
    local currentVelocity = self._velocity
    local dampingFactor = self._damping
    local speed = self._speed
    
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
    
    local positionDifference = wrap(-currentPosition)
    
    local newPosition = currentPosition + (positionDifference * pullToTarget) + (currentVelocity * velPosPush)
    local newVelocity = (positionDifference * velPushRate) + (currentVelocity * velocityDecay)
    
    return newPosition, newVelocity
end

return RadianSpring