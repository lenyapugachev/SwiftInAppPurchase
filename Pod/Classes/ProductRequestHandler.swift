//
//  ProductRequestHandler.swift
//  IAPMaster
//
//  Created by Suraphan on 11/30/2558 BE.
//  Copyright © 2558 irawd. All rights reserved.
//
import StoreKit

public typealias RequestProductCallback = (_ products: [SKProduct]?,_ invalidIdentifiers:[String]?,_ error:NSError?) -> ()

public class ProductRequestHandler: NSObject,SKProductsRequestDelegate {
    
    private var requestCallback: RequestProductCallback?
    var products: [String: SKProduct] = [:]
    
    override init() {
        super.init()
    }
    deinit {
        
    }
    func addProduct(product: SKProduct) {
        products[product.productIdentifier] = product
    }

    func requestProduc(productIds: Set<String>, requestCallback: @escaping RequestProductCallback){
        self.requestCallback = requestCallback
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest.delegate = self
        productRequest.start()
    }
    // MARK: SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        for product in response.products{
            addProduct(product: product)
        }
        requestCallback!(response.products, response.invalidProductIdentifiers, nil)
    }

    public func requestDidFinish(_ request: SKRequest) {
        print(request)
    }
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        requestCallback!(nil, nil, error as NSError)
    }
    
}
