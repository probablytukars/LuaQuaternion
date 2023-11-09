// v1.3.0

interface WrappedSpring {
    Reset(self: WrappedSpring, target: number?);
    Impulse(self: WrappedSpring, velocity: number);
    TimeSkip(self: WrappedSpring, delta: number);
    
    Position: number;
    p: number;
    Velocity: number;
    v: number;
    Target: number;
    t: number;
    Damping: number;
    d: number;
    Speed: number;
    s: number;
    Clock(): number;
}

interface WrappedSpringConstructor {
    new(initial: number, damping: number, speed: number, min: number, max: number, clock: () => number): Spring
}

declare const WrappedSpring: WrappedSpringConstructor;
export = WrappedSpring