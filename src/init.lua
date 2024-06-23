local Quaternion = require(script.Quaternion)
local QuaternionSpring = require(script.QuaternionSpring)
local RadianSpring = require(script.RadianSpring)
local Spring = require(script.Spring)

export type Quaternion = Quaternion.Quaternion
export type QuaternionSpring = QuaternionSpring.QuaternionSpring
export type RadianSpring = RadianSpring.RadianSpring

export type nlerpable = Spring.nlerpable
export type Spring<T = nlerpable> = Spring.Spring<T>

return {
	Quaternion = Quaternion,
	QuaternionSpring = QuaternionSpring,
	RadianSpring = RadianSpring,
	Spring = Spring
}