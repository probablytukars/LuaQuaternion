// v1.5.1
/*
    Source: https://github.com/probablytukars/LuaQuaternion
    Based on: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
*/

interface QuaternionSpring {
    Reset(self: QuaternionSpring, target: Quaternion?);
    Impulse(self: QuaternionSpring, velocity: Vector3);
    TimeSkip(self: QuaternionSpring, delta: number);
    
    Position: Quaternion;
    p: Quaternion;
    Velocity: Vector3;
    v: Vector3;
    Target: Quaternion;
    t: Quaternion;
    Damping: number;
    d: number;
    Speed: number;
    s: number;
    Clock(): number;
}

interface QuaternionSpringConstructor {
    new(initial: Quaternion, damping: number, speed: number, clock: () => number): QuaternionSpring
}

declare const QuaternionSpring: QuaternionSpringConstructor;
export = QuaternionSpring