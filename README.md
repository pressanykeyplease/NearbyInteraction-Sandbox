# NearbyInteraction Sandbox

[![Nearby Interaction](https://img.shields.io/badge/Apple-Nearby%20Interaction-lightgrey)](https://developer.apple.com/documentation/nearbyinteraction)
[![Multipeer Connectivity](https://img.shields.io/badge/Apple-Multipeer%20Connectivity-lightgrey)](https://developer.apple.com/documentation/multipeerconnectivity)

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

## Multipeer Connectivity Transport
We can use Apple's [Multipeer Connectivity](https://developer.apple.com/documentation/multipeerconnectivity) framework to exchange `NIDiscoveryToken` and all the following data messages. Exchange algorithm may look like that:
* Create and establish `MCSession` between two devices
* Create `NISession` object
* Send `nearbySession?.discoveryToken` via `MCSession`
* Run `NISession` using received token
* Receive distance updates using NISession delegate method
* As soon as distance gets smaller than some threshold value ("Touch" event) - send any data message to another device.

Important: MultipeerConnectivity has some issues under the hood, which may affect the connection. Sometimes it is impossible to establish a connection for first attempt. If connection is getting established slowly or not getting established, "tap phones" event is not going to work.

## Server Transport
This is the preferred way to exchange `NIDiscoveryToken`. You need your own backend for this type of transport and also you need to manage users' locations. Exchange algorithm is the following:
* Create `NISession` object
* Send `nearbySession?.discoveryToken` to your backend
* Download other user's token from server (which also was uploaded)
* Run `NISession` using downloaded token

This algorithm works good if you have two users. If you have a lot of users, you don't need to download all tokens from the server. A good workaround may be to manage user's GPS location and download tokens only for users, which are in close proximity.
