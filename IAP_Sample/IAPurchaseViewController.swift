//
//  IAPurchaseViewController.swift
//  IAP_Sample
//
//  Created by Anas Zaheer on 08/12/17.
//  Copyright © 2017 nfnlabs. All rights reserved.
//

import UIKit
import StoreKit

class IAPurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var PRODUCT_ID =  "com.xxx.IAP_sample" //Get it from iTunes connect
    var SHARED_SECRET = "eaexxxxxxxxxxxxxxxcfr45" //Get it from iTunes connect
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    //MARK: - Outlets
    @IBOutlet weak var btnPurchase: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var lblPurchaseDone: UILabel!
    var loaderView: LoaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let isPurchased = UserDefaults.standard.value(forKey: "isPurchased") as? Bool, isPurchased == true{
            //TODO:Product is purchased and make sure the functionality/availability of purchased product */
            lblPurchaseDone.isHidden = false
            self.btnPurchase.isHidden = true
            self.btnRestore.isHidden = true
        }
        else{
            /* Product is not purchased */
            lblPurchaseDone.isHidden = true
            self.fetchAvailableProducts()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnPurchase.layer.cornerRadius = 10
    }
    
    // MARK: - Fetch all available IAP products which is created in iTunes connect.
    func fetchAvailableProducts()  {
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            PRODUCT_ID
        )
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    @IBAction func btnPurchaseOnClick(_ sender: UIButton) {
        purchaseProduct(product: iapProducts[0])
    }

    // MARK: - Restore purchases
    @IBAction func btnRestoreOnClick(_ sender: UIButton) {
        showLoaderView(with: "Restoring...")
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        hideLoader()
        //TODO: Product is restored and make sure the functionality/availability of purchased product */
        UserDefaults.standard.set(true, forKey: "isPurchased")
        lblPurchaseDone.text = "Pro Version Restored."
        lblPurchaseDone.isHidden = false
        btnPurchase.isHidden = true
        btnRestore.isHidden = true
        self.present(Utilities().showAlertContrller(title: "Restore Success", message: "You've successfully restored your purchase!"), animated: true, completion: nil)
    }
    
    // MARK: - Make purchase of a product
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseProduct(product: SKProduct) {
        if self.canMakePurchases() {
            showLoaderView(with: "Purchasing...")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("Product to Purchase: \(product.productIdentifier)")
            productID = product.productIdentifier
        }
            // IAP Purchases disabled on the Device
        else{
            self.present(Utilities().showAlertContrller(title: "Oops!", message: "Purchases are disabled in your device!"), animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0{
            iapProducts = response.products
            let purchasingProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = purchasingProduct.priceLocale
            let price = numberFormatter.string(from: purchasingProduct.price)
            
            // Show description
            btnPurchase.setTitle("Get " + purchasingProduct.localizedDescription + " for \(price!)", for: .normal)
        }
        
    }
    
    // MARK: - IAP payment queue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    hideLoader()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if productID == PRODUCT_ID {
                        UserDefaults.standard.set(true, forKey: "isPurchased")
                        lblPurchaseDone.text = "Pro version PURCHASED!"
                        lblPurchaseDone.isHidden = false
                        btnPurchase.isHidden = true
                        btnRestore.isHidden = true
                        self.present(Utilities().showAlertContrller(title: "Purchase Success", message: "You've successfully purchased"), animated: true, completion: nil)
                    }
                case .failed:
                    hideLoader()
                    if trans.error != nil{
                        self.present(Utilities().showAlertContrller(title: "Purchase failed!", message: trans.error!.localizedDescription), animated: true, completion: nil)
                        print(trans.error!)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default: break
                }
            }
        }
    }
    
    //MARK: - Show / Hide loader for purchase and restore
    func showLoaderView(with title:String){
        loaderView = LoaderView.instanceFromNib()
        loaderView?.lblLoaderTitle.text = title
        loaderView?.frame = self.view.frame
        self.view.addSubview(loaderView!)
    }
    
    func hideLoader(){
        if loaderView != nil{
            loaderView?.removeFromSuperview()
        }
    }
    
}

