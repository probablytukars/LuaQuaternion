// v1.5.1
/*
    Source: https://github.com/probablytukars/LuaQuaternion
    Based on: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
*/

interface RadianSpring {
    Reset(self: RadianSpring, target: number?);
    Impulse(self: RadianSpring, velocity: number);
    TimeSkip(self: RadianSpring, delta: number);
    
    Position: number;
    p: number;
    Velocity: number;
    v: number;
    Damping: number;
    d: number;
    Speed: number;
    s: number;
    Clock(): number;
}

interface RadianSpringConstructor {
    new(initial: number, damping: number, speed: number, min: number, max: number, clock: () => number): Spring
}

declare const RadianSpring: RadianSpringConstructor;
export = RadianSpring