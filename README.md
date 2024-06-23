# LuaQuaternion

LuaQuaternion is a fully featured library for utilizing quaternions in luau.
To use in lua projects you will need to manually remove all type information.

If you are using this project in an external editor, you can install this library using `npm i @rbxts/luaquaternion`.

To import within roblox-ts, you can do the following:

```ts
// Just import Quaternion
import { Quaternion } from "@rbxts/luaquaternion"

// Import them all (star imports don't work for some unexpected reasons)
import { Quaternion, QuaternionSpring, RadianSpring, Spring } from "@rbxts/luaquaternion"
```

This project also supports roblox-ts via .d.ts files.

# Documentation

The latest documentation is available [here](https://probablytukars.github.io/LuaQuaternion/), and contains information on how to use each function, alongside details of what each function does.

You can find older documentation in the releases section of this repository, and 

## IMPORTANT INFORMATION
The order of Quaternions in this library is X,Y,Z,W, NOT W,X,Y,Z. If you plan to use translate this code into a target language, please ensure you are using the correct order.

# License

This project is licensed under the MIT license.