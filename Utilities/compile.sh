#!/bin/sh

./gyb --line-directive '' -o ../Sources/SwiftCheck/Cartesian.swift ../Templates/Cartesian.swift.gyb
./gyb --line-directive '' -o ../Tests/SwiftCheckTests/CartesianSpec.swift ../Templates/CartesianSpec.swift.gyb
