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

In your checkout controller or wherever else you handle payments, create the OPPPaymentProvider variable and initialize it with test mode, e.g. in the viewDidLoad method:

```
 override func viewDidLoad() {

    super.viewDidLoad()
    
    let provider = OPPPaymentProvider(mode: .test)
    
    }
```


## Set Up Your Server

To start working with hyperpay SDK, you should expose two APIs on your backend for your app to communicate with:

**Endpoint 1:** Creating a checkout ID,

**Endpoint 2:** Getting result of payment.


##Request Checkout ID

Your app should request a checkout ID from your server. This example uses our sample integration server; please adapt it to use your own backend API.


##Collect and validate shopper payment details

First you need to create an OPPPaymentParams object and initialize it with collected shopper payment details, it's required for processing a transaction.

Use fabric initializers to create an appropriate subclass of OPPPaymentParams. See code sample for credit card payment params:

```
do {
    let params = try OPPCardPaymentParams(checkoutID: checkoutID, paymentBrand: "VISA", holder: holderName, number: cardNumber, expiryMonth: month, expiryYear: year, cvv: CVV)

    // Set shopper result URL
    params.shopperResultURL = "com.companyname.appname.payments://result"
} catch let error as NSError {
    // See error.code (OPPErrorCode) and error.localizedDescription to identify the reason of failure
}
```

You can also validate each parameter separately before creating an OPPPaymentParams object.
iOS SDK provides convenience validation methods for each payment parameter. See code sample for card number validation:

```
if !OPPCardPaymentParams.isNumberValid("4200 0000 0000 0000", luhnCheck: true) {
    // display error that card number is invalid
}
```

##Submit a transaction

Create a transaction with the collected valid payment parameters. Then submit it using OPPPaymentProvider method and implement the callback.

Check type of the transaction returned in the callback:

if it's synchronous payment, you can immediately request payment result from your server,

otherwise transaction will contain redirect url, shopper should be redirected to this URL to pass additional checks on payment provider side (e.g. pass 3D Secure check

```
let transaction = OPPTransaction(paymentParams: params)
provider.submitTransaction(transaction) { (transaction, error) in
    guard let transaction = transaction else {
        // Handle invalid transaction, check error
        return
    }

    if transaction.type == .asynchronous {
         // Open transaction.redirectURL in Safari browser to complete the transaction
    } else if transaction.type == .synchronous {
        // Send request to your server to obtain transaction status
    } else {
        // Handle the error
    }
}
```

##Request Payment Status

Finally your app should request the payment status from your server (again, adapt this example to your own setup).

To get resourcePath you should make additional request to the server.

```
self.provider.requestCheckoutInfo(withCheckoutID: checkoutId, completionHandler: { (checkoutInfo, error) in
    guard let resourcePath = checkoutInfo?.resourcePath else {
        // Handle error
        return
    }    

    // Use resourcePath for getting transaction status
})
```


##Go to Production

1. Talk to your account manager to get the live credentials.

2. Adjust the server type to LIVE in your initialization of OPPPaymentProvider.

``let provider = OPPPaymentProvider(mode: OPPProviderMode.live)``

3. Change your backend to use the correct API endpoints and credentials.
