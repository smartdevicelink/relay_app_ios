# ![logo](/Readme Files/AppIcon.png) SmartDeviceLink (SDL) iOS Relay

SDL iOS Relay is a tool built for developers building applications
that utilizes SmartDeviceLink for connecting their apps to technologies using
our [SmartDeviceLink Core](https://github.com/smartdevicelink/sdl_core) connected
via USB. This tool allows those developers to test their applications over a TCP/IP connection, allowing developers to easily see debug logs to make development faster
and easier.

### Things To Note
- Make sure that both SDL iOS Relay and your app are connected to the
**same** wifi network.


## Relay Status

#### Start
<img src="/Readme Files/Start.png" width="200px">
> Initial app startup. This state is visible when the app is not connected to
hardware running SDL Core via USB.

#### USB Connected
<img src="/Readme Files/USBConnected.png" width="200px">
> When Relay is initially connected via USB, but the connection isn't complete.

#### EASession Connected
<img src="/Readme Files/EASessionConnected.png" width="200px">
> When the Relay is fully connected via USB, and ready for server start.

#### Relay started
<img src="/Readme Files/ServerStarted.png" width="200px">
> Server is now started, and awating connection.


#### Connected to Relay
<img src="/Readme Files/TCPConnected.png" width="200px">
> Application is correctly connected to Relay, and messages can
now be sent and received.

## How To Start Testing Using Relay

> ###### For all documentation purposes, we will be using our [SDL iOS Library](https://github.com/smartdevicelink/sdl_ios) for code snippets.

To get started, please be sure to use the proxy builder's [TCP/IP initializer](https://github.com/smartdevicelink/sdl_ios/blob/master/SmartDeviceLink-iOS/SmartDeviceLink/SDLProxyFactory.h#L16).
```objective-c
SDLProxy* proxy = [SDLProxyFactory buildSDLProxyWithListener:sdlProxyListenerDelegate
                                                tcpIPAddress:@"1.2.3.4"
                                                        port:@"2776"];
```
> NOTE: Be sure to start the Relay app **before** connecting your application to it.

## Need Help?
If you need general assistance, or have other questions, you can [sign up](http://slack.smartdevicelink.org/) for the [SDL Slack](https://smartdevicelink.slack.com/) and chat with other developers and the maintainers of the project.

## Found a Bug?
If you see a bug, feel free to [post an issue](https://github.com/smartdevicelink/relay_app_ios/issues/new). Please see the [contribution guidelines](https://github.com/smartdevicelink/relay_app_ios/blob/master/CONTRIBUTING.md) before proceeding.

## Want to Help?
If you want to help add more features, please [file a pull request](https://github.com/smartdevicelink/relay_app_ios/compare). Please see the [contribution guidelines](https://github.com/smartdevicelink/relay_app_ios/blob/master/CONTRIBUTING.md) before proceeding.
