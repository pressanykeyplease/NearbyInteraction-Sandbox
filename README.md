# NearbyInteraction Sandbox

[![Nearby Interaction](https://img.shields.io/badge/Apple-Nearby%20Interaction-lightgrey)](https://developer.apple.com/documentation/nearbyinteraction) [![Multipeer Connectivity](https://img.shields.io/badge/Apple-Multipeer%20Connectivity-lightgrey)]([https://developer.apple.com/documentation/nearbyinteraction](https://developer.apple.com/documentation/multipeerconnectivity))

This tutorial project is made for practicing in [Nearby Interaction framework](https://developer.apple.com/documentation/nearbyinteraction) by Apple. Demo app allows you to stimulate the touch of two devices and show on the screen the name of the device that touched you.

![example](https://github.com/pressanykeyplease/NearbyInteraction-Sandbox/raw/main/NearbyInteraction-Sandbox/Resources/nisandbox-example.gif)

## Limitations
* Nearby Interaction is not supported for real devices in [these countries](https://support.apple.com/HT212274)
* Available for iPhone 11 or later and iPhone SE 2 or later

## Introduction
Supported devices and simulators are able to track distance and direction to other devices after exchanging a special token - [NIDiscoveryToken](https://developer.apple.com/documentation/nearbyinteraction/nidiscoverytoken). There are multiple ways to share this token with another device:
* Core Bluetooth
* Multipeer Connectivity
* Server

In this sandbox only last two ways are tested. You are welcome to contribute and add another ways of token exchanging.
