/*
    Source: https://github.com/probablytukars/LuaQuaternion
    [MIT LICENSE]
*/

interface Quaternion {
    X: number;
    Y: number;
    Z: number;
    W: number;
    Unit: Quaternion;
    Magnitude: number;
    
    Add(this: Quaternion, q1: Quaternion):  Quaternion;
	Sub(this: Quaternion, q1: Quaternion): Quaternion;
	Mul(this: Quaternion, q1: Quaternion): Quaternion;
	Scale(this: Quaternion, scale: number): Quaternion;
	MulCFrameR(this: Quaternion, cframe: CFrame):  CFrame;
	MulCFrameL(this: Quaternion, cframe: CFrame):  CFrame;
	RotateVector(this: Quaternion, vector: Vector3):  Vector3;
	CombineImaginary(this: Quaternion, vector: Vector3):  Quaternion;
	Div(this: Quaternion, q1: Quaternion):  Quaternion;
	ScaleInv(this: Quaternion, scale: number): Quaternion;
	Unm(this: Quaternion): Quaternion;
	Pow(this: Quaternion, power: number): Quaternion;
	Len(this: Quaternion): number;
	Lt(this: Quaternion, q1: Quaternion): boolean;
	Le(this: Quaternion, q1: Quaternion): boolean;
	Eq(this: Quaternion, q1: Quaternion): boolean;
    
    Exp(this: Quaternion): Quaternion;
    ExpMap(this: Quaternion, q1: Quaternion): Quaternion;
    ExpMapSym(this: Quaternion, q1: Quaternion): Quaternion;
    Log(this: Quaternion): Quaternion;
    LogMap(this: Quaternion, q1: Quaternion): Quaternion;
    LogMapSym(this: Quaternion, q1: Quaternion): Quaternion;
    Length(this: Quaternion): number;
    LengthSquared(this: Quaternion): number;
    Hypot(this: Quaternion): number;
    Normalize(this: Quaternion): Quaternion;
    IsUnit(this: Quaternion, epsilon: number): boolean;
    Dot(this: Quaternion, q1: Quaternion): number;
    Conjugate(this: Quaternion): Quaternion;
    Inverse(this: Quaternion): Quaternion;
    Negate(this: Quaternion): Quaternion;
    Difference(this: Quaternion, q1: Quaternion): Quaternion;
    Distance(this: Quaternion, q1: Quaternion): number;
    DistanceSym(this: Quaternion, q1: Quaternion): number;
    DistanceChord(this: Quaternion, q1: Quaternion): number;
    DistanceAbs(this: Quaternion, q1: Quaternion): number;
    Slerp(this: Quaternion, q1: Quaternion, alpha: number): Quaternion;
    IdentitySlerp(q1: Quaternion, alpha: number): Quaternion;
    SlerpFunction(this: Quaternion, q1: Quaternion): (alpha: number) => Quaternion;
    Intermediates(this: Quaternion, q1: Quaternion, n: number, includeEndpoints?: boolean): {Quaternion};
    Derivative(this: Quaternion, rate: Vector3):  Quaternion;
    Integrate(this: Quaternion, rate: Vector3, timestep: number): Quaternion;
    AngularVelocity(this: Quaternion, q1: Quaternion, timestep: number): Vector3;
    MinimalRotation(this: Quaternion, q1: Quaternion): Quaternion;
    ApproxEq(this: Quaternion, q1: Quaternion, epsilon: number): boolean;
    IsNaN(this: Quaternion): boolean;

    ToCFrame(this: Quaternion, position?: Vector3): CFrame;
    ToAxisAngle(this: Quaternion): LuaTuple<[Vector3, number]>;
    ToEulerVector(this: Quaternion): Vector3;
    ToEulerAnglesXYZ(this: Quaternion): LuaTuple<[number, number, number]>;
    ToEulerAnglesYXZ(this: Quaternion): LuaTuple<[number, number, number]>;
    ToOrientation(this: Quaternion): LuaTuple<[number, number, number]>;
    ToEulerAngles(this: Quaternion, rotationOrder?: Enum.RotationOrder): LuaTuple<[number, number, number]>;
    ToMatrix(this: Quaternion): LuaTuple<[number, number, number, number, number, number, number, number, number]>;
    ToMatrixVectors(this: Quaternion): LuaTuple<[Vector3, Vector3, Vector3]>;
    Vector(this: Quaternion): Vector3;
    Scalar(this: Quaternion): number;
    Imaginary(this: Quaternion): Quaternion;
    GetComponents(this: Quaternion): LuaTuple<[number, number, number, number]>;
    components(this: Quaternion): LuaTuple<[number, number, number, number]>;
    ToString(this: Quaternion, decimalPlaces?: number): string;
}

interface QuaternionConstructor {
    new: (qX?: number, qY?: number, qZ?: number, qW?: number) => Quaternion;
    fromAxisAngle: (axis: Vector3, angle: number) => Quaternion;
    fromAxisAngleFast: (axis: Vector3, angle: number) => Quaternion;
    fromEulerVector: (eulerVector: Vector3) => Quaternion;
    fromCFrame: (cframe: CFrame) => Quaternion;
    fromCFrameFast: (cframe: CFrame) => Quaternion;
    fromMatrix: (vX: Vector3, vY: Vector3, vZ?: Vector3) => Quaternion;
    fromMatrixFast: (vX: Vector3, vY: Vector3, vZ?: Vector3) => Quaternion;
    lookAt: (from: Vector3, lookAt: Vector3, up?: Vector3) => Quaternion;
    fromEulerAnglesXYZ: (rx: number, ry: number, rz: number) => Quaternion;
    Angles: (rx: number, ry: number, rz: number) => Quaternion;
    fromEulerAnglesYXZ: (rx: number, ry: number, rz: number) => Quaternion;
    fromOrientation: (rx: number, ry: number, rz: number) => Quaternion;
    fromEulerAngles: (rx: number, ry: number, rz: number, rotationOrder?: Enum.RotationOrder) => Quaternion;
    fromVector: (vector: Vector3, W?: number) => Quaternion;
    RandomQuaternion: (seed: number) => () => Quaternion;

    identity: Quaternion;
    zero: Quaternion;
}

declare const Quaternion: QuaternionConstructor;
export = Quaternion
