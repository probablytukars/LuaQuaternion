local replicatedStorage = game:GetService("ReplicatedStorage")
local Quaternion = require(replicatedStorage.Quaternion)
type Quaternion = Quaternion.Quaternion

local ERROR_FORMAT = "%q is not a valid member of QuaternionSpring."

export type QuaternionSpring = {
    new: (initial: Quaternion, damping: number, speed: number, clock: () -> number) -> QuaternionSpring,
    Impulse: (self: QuaternionSpring, velocity: Vector3) -> nil,
    TimeSkip: (self: QuaternionSpring, delta: number) -> nil,
    
    Position: Quaternion,
    p: Quaternion,
    Velocity: Vector3,
    v: Vector3,
    Target: Quaternion,
    t: Quaternion,
    Damping: number,
    d: number,
    Speed: number,
    s: number,
    Clock: () -> number
}

--[=[
    @class QuaternionSpring
    @grouporder ["Constructors", "Methods"]
    
    This class represents a rotational spring using Quaternions.
    Velocity is a Vector3 where the magnitude is the angle, and the unit
    is the axis (if angle is > 0).
    
    This is lazily evaluated meaning it only updates when indexed.
]=]
--[=[
    The current position (rotation) at the given clock time. 
    Assigning the position will change the spring to have that position.
    
    @prop Position nlerpable
--]=]
--[=[
    @prop p nlerpable
    @alias Position
--]=]
--[=[
    The current velocity. Assigning the velocity will change the spring to have 
    that velocity. The velocity should be in the axis with angle magnitude
    format, where the magnitude represents the angle, and the unit of that
    vector (if magnitude is > 0) represents the axis of rotation.
    The zero vector represents no velocity.
    
    @prop Velocity nlerpable
--]=]
--[=[
    @prop v nlerpable
    @alias Velocity
--]=]
--[=[
    The current target. Assigning the target will change the spring to have 
    that target.
    
    @prop Target nlerpable
--]=]
--[=[
    @prop t nlerpable
    @alias Target
--]=]
--[=[
    The current damper, defaults to 1. At 1 the spring is critically damped. 
    At less than 1, it will be underdamped, and thus, bounce, and at over 1, 
    it will be critically damped.
    
    @prop Damping number
--]=]
--[=[
    @prop d number
    @alias Damping
--]=]
--[=[
    The speed, defaults to 1, but should be between [0, infinity)
    
    @prop Speed number
--]=]
--[=[
    @prop s number
    @alias Speed
--]=]
--[=[
    @prop Clock
--]=]
local QuaternionSpring = {_type = "QuaternionSpring"}

function QuaternionSpring.new(initial: Quaternion, damping: number, speed: number, clock: () -> number)
    initial = initial or Quaternion.identity
    damping = damping or 1
    speed = speed or 1
    clock = clock or os.clock
    
    return setmetatable({
        _clock = clock;
        _time = clock();
        _position = initial;
        _velocity = Vector3.new();
        _target = initial;
        _damping = damping;
        _speed = speed;
    }, QuaternionSpring)
end

function QuaternionSpring:Impulse(velocity: Vector3)
    self.Velocity = self.Velocity + velocity
end

function QuaternionSpring:TimeSkip(delta: number)
    local now = self._clock()
    local position, velocity = self:_positionVelocity(now+delta)
    self._position = position
    self._velocity = velocity
    self._time0 = now
end

function QuaternionSpring:__index(index)
    if QuaternionSpring[index] then
        return QuaternionSpring[index]
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



function QuaternionSpring:__newindex(index, value)
    local now = self._clock()
    if index == "Position" or index == "p" then
        local _, velocity = self:_positionVelocity(now)
        self._position = value
        self._velocity = velocity
        self._time0 = now
    elseif index == "Velocity" or index == "v" then
        local position, _ = self:_positionVelocity(now)
        self._position = position
        self._velocity = value
        self._time0 = now
    elseif index == "Target" or index == "t" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._target = value
        self._time0 = now
    elseif index == "Damping" or index == "d" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._damping = value
        self._time0 = now
    elseif index == "Speed" or index == "s" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._speed = value < 0 and 0 or value
        self._time0 = now
    elseif index == "Clock" then
        local position, velocity = self:_positionVelocity(now)
        self._position = position
        self._velocity = velocity
        self._clock = value
        self._time0 = value()
    else
        error(string.format(ERROR_FORMAT, tostring(index)), 2)
    end
end

function QuaternionSpring:_positionVelocity(now)
    local currentRotation = self._position
    local currentVelocity = self._velocity
    local targetRotation = self._target
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
        local exponential = math.exp(-dampingFactor * deltaTime)
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
    
    local posQuat = currentRotation:Slerp(targetRotation, pullToTarget)
    local newPosition = posQuat:Integrate(currentVelocity, velPosPush)
    
    local difQuat = currentRotation:Difference(targetRotation)
    local axis, angle = difQuat:ToAxisAngle()
    local velPush = (axis * angle) * velPushRate
    local velDecay = currentVelocity * velocityDecay
    
    local newVelocity = velPush + velDecay
    
    return newPosition, newVelocity
end






return QuaternionSpring
