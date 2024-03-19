# GlassEffect

This effect allows you to transform the geometry of your regular, rectangular SwiftUI `View`s into quadrilateral segments ⏢.

The shader uses bilinear interpolation to map pixel positions to the output via `View.distortionEffect`.

![output]()

## How To Use It?

Use as a Swift Package.

Use a [`View.geometryEffect` modifier](). At a minimum, you should be able to run the effect by supplying a normal map texture image. For best results, be sure to use high-quality normal maps.

## Why?

I made it mostly for myself as an exercise in my recent `SwiftUI` + `Metal` research. Its an early version of the package. At this point the APIs has not been crafted very carefully and you can ...

Feel free to use it, feel free to contribute (fix issues, share ideas), and feel free to hit me up [@czajnikowski](https://twitter.com/czajnikowski) 👋
