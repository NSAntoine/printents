# printents

A CommandLine tool that prints the entitlements of an .app bundle or any executable on device, demonstrating the AppSandbox private framework.
usage: `printents <path>`, ie `printents /Application/Safari.app` or `printents /usr/libexec/locationd`

## Compiling
To compile, run `clang main.m -F/System/Library/PrivateFrameworks -framework AppSandbox -framework Foundation -fobjc-arc`
## Options
`-f, --format`: speciifes the format of the output, of which there is 3:

- `NSDictionary`
- `JSON`
- `XML`

