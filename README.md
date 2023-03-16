# DCSTecorbHyperPay

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)]()
[![iOS](https://img.shields.io/badge/Platform-iOS-purpel.svg?style=flat)](https://developer.apple.com/ios/)
[![Swift 5](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![HyperPay](https://img.shields.io/badge/HyperPay-red.svg?style=flat)](https://www.hyperpay.com/en/integration-guides/)


This Demo will help you through the integration of a native payment experience in your application.

Accepting payment in your app involves 4 steps:

**1. Preparing checkout** (configure with amount, currency and other information),

**2. Collecting shopper payment details,**

**3. Creating and submitting transaction,**

**4. Requesting payment result.**

iOS SDK provide tools to help you with steps 2 and 3.

For steps 1 and 4 you will need to communicate to your own backend API. These steps are not included in SDK API due to security reasons.

## Install SDK

**1.Drag and drop** OPPWAMobile.xcframework **to the "Frameworks" folder** of your project.
Make sure "Copy items if needed" is checked.

2. Check **"Frameworks, Libraries, and Embedded Content"** section under the general settings tab of your application's target. **Ensure** the Embed dropdown has **Embed and Sign** selected for the framework.


**You can now import the framework with:**

``#import <OPPWAMobile/OPPWAMobile.h>``

3. Import sdk in **header file**

``
override func viewDidLoad() {
    super.viewDidLoad()
    let provider = OPPPaymentProvider(mode: .test)
}``

## Set Up Your Server

To start working with hyperpay SDK, you should expose two APIs on your backend for your app to communicate with:

**Endpoint 1:** Creating a checkout ID,
**Endpoint 2:** Getting result of payment.




