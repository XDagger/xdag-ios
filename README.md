# xdag-ios
XDAG iOS Wallet 

## Status
[![Throughput Graph](https://graphs.waffle.io/XDagger/xdag-ios/throughput.svg)](https://waffle.io/XDagger/xdag-ios/metrics/throughput)


## Building

1. git clone sources
```
git clone git@github.com:XDagger/xdag-ios.git

```
2. run pod install in project root directory.
```
pod install

```

3. Open `.xcworkspace`


## URI scheme for QRCode 

> URI scheme for making xdag payments

```
 xdagurn = "xdag:" xdagaddress [ "?" xdagparams ]
 xdagaddress = *base64
 xdagparams  = xdagparam [ "&" xdagparams ]

 ```

 ## Requirements

 - iOS 8.0+ / macOS 10.10+ 
 - xcode 9
 - Swift 4.0
