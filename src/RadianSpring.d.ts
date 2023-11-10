// v1.3.0

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