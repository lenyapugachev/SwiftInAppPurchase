//
//  PaymentRequestHandler.swift
//  IAPMaster
//
//  Created by Suraphan on 11/30/2558 BE.
//  Copyright © 2558 irawd. All rights reserved.
//


import StoreKit

public enum TransactionResult {
    case Purchased(productId: String,transaction:SKPaymentTransaction,paymentQueue:SKPaymentQueue)
    case Restored(productId: String,transaction:SKPaymentTransaction,paymentQueue:SKPaymentQueue)
    case NothingToDo
    case Failed(error: NSError)
}
public typealias AddPaymentCallback = (_ result: TransactionResult) -> ()

public class PaymentRequestHandler: NSObject,SKPaymentTransactionObserver {

    
    private var addPaymentCallback: AddPaymentCallback?
    private var incompleteTransaction : [SKPaymentTransaction] = []
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func addPayment(product: SKProduct,userIdentifier:String?, addPaymentCallback: @escaping AddPaymentCallback){
        
        self.addPaymentCallback = addPaymentCallback
        
        let payment = SKMutablePayment(product: product)
        if userIdentifier != nil {
            payment.applicationUsername = userIdentifier!
        }
        SKPaymentQueue.default().add(payment)
    }

    func restoreTransaction(userIdentifier:String?,addPaymentCallback: @escaping AddPaymentCallback){
        
        self.addPaymentCallback = addPaymentCallback
        if userIdentifier != nil {
           SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: userIdentifier)
        }else{
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
    }
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
    
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                if (addPaymentCallback != nil){
                    addPaymentCallback!(.Purchased(productId: transaction.payment.productIdentifier, transaction: transaction, paymentQueue: queue))
                }else{
                    incompleteTransaction.append(transaction)
                }
                
            case .failed:
                if (addPaymentCallback != nil){
                    addPaymentCallback!(.Failed(error: transaction.error! as NSError))
                }
                queue.finishTransaction(transaction)
               
            case .restored:
                if (addPaymentCallback != nil){
                    addPaymentCallback!(.Restored(productId: transaction.payment.productIdentifier, transaction: transaction, paymentQueue: queue))
                }else{
                    incompleteTransaction.append(transaction)
                }

            case .purchasing:
                // In progress: do nothing
                break
            case .deferred:
                break
            }

        }
    }
    
    
    func checkIncompleteTransaction(addPaymentCallback: @escaping AddPaymentCallback){
     
        self.addPaymentCallback = addPaymentCallback
        let queue = SKPaymentQueue.default()
        for transaction in self.incompleteTransaction {
            
            switch transaction.transactionState {
            case .purchased:
                addPaymentCallback(.Purchased(productId: transaction.payment.productIdentifier, transaction: transaction, paymentQueue: queue))
                
            case .restored:
                addPaymentCallback(.Restored(productId: transaction.payment.productIdentifier, transaction: transaction, paymentQueue: queue))
                
            default:
                break
            }
        }
        self.incompleteTransaction.removeAll()
    }
}
