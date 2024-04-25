// v1.5.0
/*
    SOURCE: https://github.com/Quenty/NevermoreEngine/tree/main/src/spring
    [MIT LICENSE]
*/

type nlerpable = number | Vector2 | Vector3 | UDim | UDim2

interface Spring {
    Reset(self: Spring, target: nlerpable?);
    Impulse(self: Spring, velocity: nlerpable);
    TimeSkip(self: Spring, delta: number);
    
    Position: nlerpable;
    p: nlerpable;
    Velocity: nlerpable;
    v: nlerpable;
    Target: nlerpable;
    t: nlerpable;
    Damping: number;
    d: number;
    Speed: number;
    s: number;
    Clock(): number;
}

interface SpringConstructor {
    new(initial: nlerpable, damping: number, speed: number, clock: () => number): Spring
}

declare const Spring: SpringConstructor;
export = Spring