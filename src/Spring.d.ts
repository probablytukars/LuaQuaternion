/*
    Source: https://github.com/probablytukars/LuaQuaternion
    Based on: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
*/

type nlerpable = number | Vector2 | Vector3 | UDim | UDim2

interface Spring<T = nlerpable> {
    Reset(this: Spring, target: T?);
    Impulse(this: Spring, velocity: T);
    TimeSkip(this: Spring, delta: number);
    
    Position: T;
    p: T;
    Velocity: T;
    v: T;
    Target: T;
    t: T;
    Damping: number;
    d: number;
    Speed: number;
    s: number;
    Clock(): number;
}

interface SpringConstructor<T = nlerpable> {
    new: (initial: T, damping: number, speed: number, clock: () => number) => Spring;
}

declare const Spring: SpringConstructor;
export = Spring
