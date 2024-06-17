--!strict
--[[
    Source: https://github.com/probablytukars/LuaQuaternion
    Based on: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
--]]

local ERROR_FORMAT = "%q is not a valid member of RadianSpring."

local pi = math.pi
local tau = pi * 2

local function wrap(x: number): number return ((x + tau) % (2 * tau)) - tau end

local RadianSpring = {_type = "RadianSpring"}

type t_RadianSpring = {
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
	Clock: () -> number,
	
	_clock: () -> number,
	_time: number,
	_position:  number,
	_velocity:  number,
	_target:  number,
	_damping:  number,
	_speed:  number,
	_initial:  number,
}

export type RadianSpring = typeof(setmetatable({} :: t_RadianSpring, RadianSpring))

--[=[
    @class RadianSpring
    @grouporder ["Constructors", "Methods"]
    
    This class represents a RadianSpring, which is used to spring angles.
    This is specifically designed to spring angles towards 0, and supports
    the range [-2pi, 2pi). This gives the angles a useful "double cover" 
    property as it allows you to control the "direction" that the angle 
    travels in, just by adding or subtracting tau (2pi).
    
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


--[=[
    @function
    @group Constructors
    
    Constructs a new RadianSpring at the position specified.
]=]
function RadianSpring.new(initial: number?, damping: number?, speed: number?, clock: (() -> number)?)
	local l_initial = initial or 0
	local l_damping = damping or 1
	local l_speed = speed or 1
	local l_clock = clock or os.clock
	
	local self = {
		_clock = l_clock,
		_time = l_clock(),
		_position = l_initial,
		_velocity = 0 * l_initial,
		_damping = l_damping,
		_speed = l_speed,
		_initial = l_initial
	}
	
	return setmetatable(self :: t_RadianSpring, RadianSpring)
end

--[=[
    @method
    @group Methods
    
    Resets the RadianSprings' position and target to the initial value the
    RadianSpring was created with. Sets the velocity to zero.
]=]
local function Reset(self: RadianSpring)
	local now = self._clock()
	self._position = 0
	self._velocity = 0
	self._time = now
end

RadianSpring.Reset = Reset

--[=[
    @method
    @group Methods
    
    Impulses the RadianSpring, increasing velocity by the amount given.
    This is useful to make something shake.
]=]
local function Impulse(self: RadianSpring, velocity: number)
	self._velocity = self._velocity + velocity
end

RadianSpring.Impulse = Impulse


local function _positionVelocity(self: RadianSpring, now: number)
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

--[=[
    @method
    @group Methods
    Instantly skips the RadianSpring forwards by the given time.
]=]
local function TimeSkip(self: RadianSpring, delta: number)
	local now = self._clock()
	local position, velocity = _positionVelocity(self, now+delta)
	self._position = position
	self._velocity = velocity
	self._time = now
end

RadianSpring.TimeSkip = TimeSkip

function RadianSpring.__index(self: RadianSpring, index)
	if RadianSpring[index] then
		return RadianSpring[index]
	elseif index == "Position" or index == "p" then
		local position, _ = _positionVelocity(self, self._clock())
		return position
	elseif index == "Velocity" or index == "v" then
		local _, velocity = _positionVelocity(self, self._clock())
		return velocity
	elseif index == "Damping" or index == "d" then
		return self._damping
	elseif index == "Speed" or index == "s" then
		return self._speed
	elseif index == "Clock" then
		return self._clock
	end
	error(string.format(ERROR_FORMAT, tostring(index)), 2)
end

function RadianSpring.__newindex(self: RadianSpring, index, value: any)
	local now = self._clock()
	if index == "Position" or index == "p" then
		local _, velocity = _positionVelocity(self, now)
		self._position = wrap(value)
		self._velocity = velocity
		self._time = now
	elseif index == "Velocity" or index == "v" then
		local position, _ = _positionVelocity(self, now)
		self._position = position
		self._velocity = value
		self._time = now
	elseif index == "Damping" or index == "d" then
		local position, velocity = _positionVelocity(self, now)
		self._position = position
		self._velocity = velocity
		self._damping = value
		self._time = now
	elseif index == "Speed" or index == "s" then
		local position, velocity = _positionVelocity(self, now)
		self._position = position
		self._velocity = velocity
		self._speed = value < 0 and 0 or value
		self._time = now
	elseif index == "Clock" then
		local position, velocity = _positionVelocity(self, now)
		self._position = position
		self._velocity = velocity
		self._clock = value
		self._time = value()
	else
		error(string.format(ERROR_FORMAT, tostring(index)), 2)
	end
	
end


return RadianSpring
