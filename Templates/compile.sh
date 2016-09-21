#!/bin/sh

wget https://github.com/apple/swift/raw/master/utils/gyb
wget https://github.com/apple/swift/raw/master/utils/gyb.py
chmod +x gyb

./gyb -o ../Sources/Cartesian.swift Cartesian.swift.gyb

rm gyb
rm gyb.py
rm gyb.pyc
