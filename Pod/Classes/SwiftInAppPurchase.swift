//
//  SwiftInAppPurchase.swift
//  Pods
//
//  Created by Suraphan on 12/13/2558 BE.
//
//

import Foundation
import StoreKit

public class SwiftInAppPurchase: NSObject {
    
    public static let sharedInstance = SwiftInAppPurchase()
    
    public let productRequestHandler:ProductRequestHandler
    public let paymentRequestHandler:PaymentRequestHandler
    public let receiptRequestHandler:ReceiptRequestHandler
    
    override init() {
        self.productRequestHandler = ProductRequestHandler.init()
        self.paymentRequestHandler = PaymentRequestHandler.init()
        self.receiptRequestHandler = ReceiptRequestHandler.init()
        super.init()
    }
    
    deinit{
    }
    public func setProductionMode(isProduction:Bool){
        self.receiptRequestHandler.isProduction = isProduction
    }
    public func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    public func receiptURL() -> NSURL {
        return self.receiptRequestHandler.receiptURL()
    }
    
    //  MARK: - Product
    public func productForIdentifier(productIdentifier:String) -> SKProduct{
        return self.productRequestHandler.products[productIdentifier]!
    }
    public func requestProducts(productIDS:Set<String>,completion:@escaping RequestProductCallback){
        self.productRequestHandler.requestProduc(productIds: productIDS, requestCallback: completion)
    }
    //  MARK: - Purchase
    public func addPayment(productIDS: String,userIdentifier:String?, addPaymentCallback: @escaping AddPaymentCallback){
        let product = self.productRequestHandler.products[productIDS]
        if product != nil {
            self.paymentRequestHandler.addPayment(product: product!, userIdentifier: userIdentifier, addPaymentCallback: addPaymentCallback)
        }else{
            addPaymentCallback(.Failed(error: NSError.init(domain: "AddPayment Unknow Product identifier", code: 0, userInfo: nil)))
        }
    }
    //  MARK: - Restore
    public func restoreTransaction(userIdentifier:String?,addPaymentCallback: @escaping AddPaymentCallback){
        self.paymentRequestHandler.restoreTransaction(userIdentifier: userIdentifier, addPaymentCallback: addPaymentCallback)
    }
    public func checkIncompleteTransaction(addPaymentCallback: @escaping AddPaymentCallback){
        self.paymentRequestHandler.checkIncompleteTransaction(addPaymentCallback: addPaymentCallback)
    }
    //  MARK: - Receipt
    public func refreshReceipt(requestCallback: @escaping RequestReceiptCallback){
        self.receiptRequestHandler.refreshReceipt(requestCallback: requestCallback)
    }
    public func verifyReceipt(autoRenewableSubscriptionsPassword:String?,receiptVerifyCallback:@escaping ReceiptVerifyCallback){
        self.receiptRequestHandler.verifyReceipt(autoRenewableSubscriptionsPassword: autoRenewableSubscriptionsPassword, receiptVerifyCallback: receiptVerifyCallback)
    }
}
