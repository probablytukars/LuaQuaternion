--!strict
--[[
    Source: https://github.com/probablytukars/LuaQuaternion
    Based on: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
--]]

local ERROR_FORMAT = "%q is not a valid member of Spring."

export type nlerpable = number | Vector2 | Vector3 | UDim | UDim2

local Spring = {_type = "Spring"}

type t_Spring<T = nlerpable> = {
	new: (initial: T, damping: number, speed: number, clock: () -> number) -> Spring<T>,
	Reset: (target: T?) -> nil,
	Impulse: (self: Spring<T>, velocity: T) -> nil,
	TimeSkip: (self: Spring<T>, delta: number) -> nil,
	
	Position: T,
	p: T,
	Velocity: T,
	v: T,
	Target: T,
	t: T,
	Damping: number,
	d: number,
	Speed: number,
	s: number,
	Clock: () -> number,
	
	_clock: () -> number,
	_time: number,
	_position: T,
	_velocity: T,
	_target: T,
	_damping: number,
	_speed: number,
	_initial: T,
}

export type Spring<T = nlerpable> = typeof(setmetatable({} :: t_Spring<T>, Spring))


--[=[
    @class Spring
    @grouporder ["Constructors", "Methods"]
    
    This class represents a spring, which can handle any object which is
    n-lerpable (numbers, Vector3s, etc).
    
    This is lazily evaluated meaning it only updates when indexed.
]=]
--[=[
    @prop Position nlerpable
    
    The current position at the given clock time. 
    Assigning the position will change the spring to have that position.
]=]
--[=[
    @prop p nlerpable
    @alias Position
]=]
--[=[
    @prop Velocity nlerpable
    
    The current velocity. Assigning the velocity will change the spring to have 
    that velocity.
]=]
--[=[
    @prop v nlerpable
    @alias Velocity
]=]
--[=[
    @prop Target nlerpable
    
    The current target. Assigning the target will change the spring to have 
    that target.
]=]
--[=[
    @prop t nlerpable
    @alias Target
]=]
--[=[
    @prop Damping number
    
    The current damper, defaults to 1. At 1 the spring is critically damped. 
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
    
    Constructs a new Spring at the position and target specified, of type <T>.
]=]
function Spring.new<T>(initial: T, damping: number?, speed: number?, clock: (() -> number)?)
	local l_damping = damping or 1
	local l_speed = speed or 1
	local l_clock = clock or os.clock
	
	local self = {
		_clock = l_clock;
		_time = l_clock();
		_position = initial;
		_velocity = ((initial :: any) * 0) :: T;
		_target = initial;
		_damping = l_damping;
		_speed = l_speed;
		_initial = initial;
	}
	
	return setmetatable(self :: t_Spring<T>, Spring)
end

--[=[
    @method
    @group Methods
    
    Resets the springs' position and target to the target value provided, or 
    to the initial value the spring was created with if target is not specified.
    Sets the velocity to zero.
]=]
local function Reset(self: Spring, target: nlerpable?)
	local now = self._clock()
	local setTo = target or self._initial
	self._position = setTo
	self._target = setTo
	self._velocity = 0 * (setTo :: any)
	self._time = now
end

Spring.Reset = Reset

--[=[
    @method
    @group Methods
    
    Impulses the spring, increasing velocity by the amount given.
    This is useful to make something shake.
]=]
local function Impulse<T>(self: Spring<T>, velocity: T)
	self._velocity = (self._velocity :: any) + velocity
end

Spring.Impulse = Impulse

local function _positionVelocity(self: Spring, now: number)
	local currentPosition = self._position
	local currentVelocity = self._velocity
	local targetPosition = self._target
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
	
	local positionDifference = targetPosition :: any - currentPosition
	
	local newPosition = 
		currentPosition + 
		positionDifference * pullToTarget + 
		currentVelocity :: any * velPosPush
	
	local newVelocity =
		positionDifference * velPushRate +
		currentVelocity :: any * velocityDecay
	
	return newPosition, newVelocity
end


--[=[
    @method
    @group Methods
    Instantly skips the spring forwards by the given time.
]=]
local function TimeSkip(self: Spring, delta: number)
	local now = self._clock()
	local position, velocity = _positionVelocity(self, now+delta)
	self._position = position
	self._velocity = velocity
	self._time = now
end

Spring.TimeSkip = TimeSkip


function Spring.__index(self: Spring, index)
	if Spring[index] then
		return Spring[index]
	elseif index == "Position" or index == "p" then
		local position, _ = _positionVelocity(self, self._clock())
		return position
	elseif index == "Velocity" or index == "v" then
		local _, velocity = _positionVelocity(self, self._clock())
		return velocity
	elseif index == "Target" or index == "t" then
		return self._target
	elseif index == "Damping" or index == "d" then
		return self._damping
	elseif index == "Speed" or index == "s" then
		return self._speed
	elseif index == "Clock" then
		return self._clock
	end
	error(string.format(ERROR_FORMAT, tostring(index)), 2)
end

function Spring.__newindex(self: Spring, index, value: any)
	local now = self._clock()
	if index == "Position" or index == "p" then
		local _, velocity = _positionVelocity(self, now)
		self._position = value
		self._velocity = velocity
		self._time = now
	elseif index == "Velocity" or index == "v" then
		local position, _ = _positionVelocity(self, now)
		self._position = position
		self._velocity = value
		self._time = now
	elseif index == "Target" or index == "t" then
		local position, velocity = _positionVelocity(self, now)
		self._position = position
		self._velocity = velocity
		self._target = value
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



return Spring
