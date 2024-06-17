// v1.5.2
/*
    Source: https://github.com/probablytukars/LuaQuaternion
    [MIT LICENSE]
*/

interface Quaternion {
    fromAxisAngle(axis: Vector3, angle: number): Quaternion;
    fromAxisAngleFast(axis: Vector3, angle: number): Quaternion;
    fromEulerVector(eulerVector: Vector3): Quaternion;
    fromCFrame(cframe: CFrame): Quaternion;
    fromCFrameFast(cframe: CFrame): Quaternion;
    fromMatrix(vX: Vector3, vY: Vector3, vZ: Vector3?): Quaternion;
    fromMatrixFast(vX: Vector3, vY: Vector3, vZ: Vector3?): Quaternion;
    lookAt(from: Vector3, lookAt: Vector3, up: Vector3?): Quaternion;
    fromEulerAnglesXYZ(rx: number, ry: number, rz: number): Quaternion;
    Angles(rx: number, ry: number, rz: number): Quaternion;
    fromEulerAnglesYXZ(rx: number, ry: number, rz: number): Quaternion;
    fromOrientation(rx: number, ry: number, rz: number): Quaternion;
    fromEulerAngles(rx: number, ry: number, rz: number, rotationOrder: Enum.RotationOrder?): Quaternion;
    fromVector(vector: Vector3, W: number?): Quaternion;
    RandomQuaternion(seed: number): () => Quaternion;
    
    X: number;
    Y: number;
    Z: number;
    W: number;
    Unit: Quaternion;
    Magnitude: number;
    
    Exp(q0: Quaternion): Quaternion;
    ExpMap(q0: Quaternion, q1: Quaternion): Quaternion;
    ExpMapSym(q0: Quaternion, q1: Quaternion): Quaternion;
    Log(q0: Quaternion): Quaternion;
    LogMap(q0: Quaternion, q1: Quaternion): Quaternion;
    LogMapSym(q0: Quaternion, q1: Quaternion): Quaternion;
    Length(q0: Quaternion): number;
    LengthSquared(q0: Quaternion): number;
    Hypot(q0: Quaternion): number;
    Normalize(q0: Quaternion): Quaternion;
    IsUnit(q0: Quaternion, epsilon: number): boolean;
    Dot(q0: Quaternion, q1: Quaternion): number;
    Conjugate(q0: Quaternion): Quaternion;
    Inverse(q0: Quaternion): Quaternion;
    Negate(q0: Quaternion): Quaternion;
    Difference(q0: Quaternion, q1: Quaternion): Quaternion;
    Distance(q0: Quaternion, q1: Quaternion): number;
    DistanceSym(q0: Quaternion, q1: Quaternion): number;
    DistanceChord(q0: Quaternion, q1: Quaternion): number;
    DistanceAbs(q0: Quaternion, q1: Quaternion): number;
    Slerp(q0: Quaternion, q1: Quaternion, alpha: number): Quaternion;
    IdentitySlerp(q1: Quaternion, alpha: number): Quaternion;
    SlerpFunction(q0: Quaternion, q1: Quaternion): (alpha: number) => Quaternion;
    Intermediates(q0: Quaternion, q1: Quaternion, n: number, includeEndpoints: boolean?): {Quaternion};
    Derivative(q0: Quaternion, rate: Vector3):  Quaternion;
    Integrate(q0: Quaternion, rate: Vector3, timestep: number): Quaternion;
    AngularVelocity(q0: Quaternion, q1: Quaternion, timestep: number): Vector3;
    MinimalRotation(q0: Quaternion, q1: Quaternion): Quaternion;
    ApproxEq(q0: Quaternion, q1: Quaternion, epsilon: number): boolean;
    IsNaN(q0: Quaternion): boolean;

    ToCFrame(q0: Quaternion, position: Vector3?): CFrame;
    ToAxisAngle(q0: Quaternion): (Vector3, number);
    ToEulerVector(q0: Quaternion): Vector3;
    ToEulerAnglesXYZ(q0: Quaternion): (number, number, number);
    ToEulerAnglesYXZ(q0: Quaternion): (number, number, number);
    ToOrientation(q0: Quaternion): (number, number, number);
    ToEulerAngles(q0: Quaternion, rotationOrder: Enum.RotationOrder?): (number, number, number);
    ToMatrix(q0: Quaternion): (number, number, number, number, number, number, number, number, number);
    ToMatrixVectors(q0: Quaternion): (Vector3, Vector3, Vector3);
    Vector(q0: Quaternion): Vector3;
    Scalar(q0: Quaternion): number;
    Imaginary(q0: Quaternion): Quaternion;
    GetComponents(q0: Quaternion): (number, number, number, number);
    components(q0: Quaternion): (number, number, number, number);
    ToString(q0: Quaternion, decimalPlaces: number?): string;
}

interface QuaternionConstructor {
    new(qX: number?, qY: number?, qZ: number?, qW: number?): Quaternion;
    identity: Quaternion;
    zero: Quaternion;
}

declare const Quaternion: QuaternionConstructor;
export = Quaternion
