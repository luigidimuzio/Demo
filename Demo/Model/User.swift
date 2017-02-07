//
//  User.swift
//  Carcierge
//
//  Created by Mattia Bugossi on 23/07/15.
//  Copyright (c) 2015 Carcierge Technology. All rights reserved.
//

import CoreData
import Parse
import Alamofire
import DeviceKit
import CryptoSwift
import BringgTracking

class User: _User {

    struct UserRegistrationModel {
        var firstName: String?
        var lastName: String?
        var email: String?
        var phoneNumber: String?
        var carMake: String?
        var carYear: String?
        var carModel: String?
        var carTrim: String?
        var oilQuarters: Double?
        var parseCarObject: PFObject?
        var avatarURL: String?
    }
    
    static var userRegistrationModel = UserRegistrationModel(firstName: nil, lastName: nil, email: nil, phoneNumber: nil, carMake: nil, carYear: nil, carModel: nil, carTrim: nil, oilQuarters: nil, parseCarObject: nil, avatarURL: nil)
    
    var requiresCarSizeExtra = false
    
    var wasADelaershipCustomer = false
    
    var appboyExternalId: String?
    
    var fullName: String {
        return User.currentUser()!.firstName! + " " + User.currentUser()!.lastName!
    }
    
    class func currentUser() -> User? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName())
        var result: User? = nil
        do {
            result = try sharedModelController.managedObjectContext!.fetch(fetchRequest).first as? User
        } catch {}
        
        return result
    }
    
    class func tryFetchCurrentUserWithEmail(_ email: String, andPhoneNumber phone: String? = nil, completion: CompletionHandler = nil) {
        let query = PFQuery(className: "Users").whereKey("email", contains: email)
        
        if let phoneNumber = phone {
            query.whereKey("phoneNumber", contains: phoneNumber)
        }
        
        query.findObjectsInBackground { (users, error) -> Void in
            if error == nil {
                if let usersList = users , usersList.count > 0 {
                    self.saveCurrentUserFromPFObject(usersList.first!)
                    completion?(nil)
                    return
                }
            }
            
            completion?(NSError(domain: "User not found", code: 0, userInfo: nil))
        }
    }
    
    class func createCurrentUser(_ completion: CompletionHandler = nil) {
        var user: User
        if let currentUser = User.currentUser() {
            user = currentUser
        } else {
            user = User(managedObjectContext: sharedModelController.managedObjectContext!)
        }
        
        user.firstName = User.userRegistrationModel.firstName
        user.lastName = User.userRegistrationModel.lastName
        user.email = User.userRegistrationModel.email
        user.phoneNumber = User.userRegistrationModel.phoneNumber
        
        if (user.firstName!).characters.count > 4 {
            let index = user.firstName!.characters.index(user.firstName!.startIndex, offsetBy: 4)
            user.personalCoupon = user.firstName!.substring(to: index).uppercased() + String(Int(arc4random_uniform(100)))
        } else {
            user.personalCoupon = "ABCD" + String(Int(arc4random_uniform(1000)))
        }
        
        let car = Car(managedObjectContext: sharedModelController.managedObjectContext!)
        car.make = User.userRegistrationModel.carMake
        car.year = User.userRegistrationModel.carYear
        car.model = User.userRegistrationModel.carModel
        car.trim = User.userRegistrationModel.carTrim
        car.engineOilQuarters = User.userRegistrationModel.oilQuarters as NSNumber?
        user.addCarsObject(car)
        
        user.createOrUpdateCustomerOnBringg { error in
            if error == nil {
                let parseUser = PFObject(className: "Users")
                parseUser.setValue(car.make!, forKey: "carMake")
                parseUser.setValue(car.year!, forKey: "carYear")
                parseUser.setValue(car.model!, forKey: "carModel")
                parseUser.setValue(car.trim!, forKey: "carTrim")
                parseUser.setValue(car.engineOilQuarters!, forKey: "carOilQuarters")
                parseUser.setValue(user.firstName!, forKey: "firstName")
                parseUser.setValue(user.lastName!, forKey: "lastName")
                parseUser.setValue(user.email!, forKey: "email")
                parseUser.setValue(user.phoneNumber!, forKey: "phoneNumber")
                parseUser.setValue(user.bringgId!, forKey: "bringgId")
                parseUser.setValue(user.personalCoupon!, forKey: "personalCoupon")
                parseUser.setValue(user.wasADelaershipCustomer, forKey: "wasADealershipCustomer")

                let carRelation = parseUser.relation(forKey: "car")
                carRelation.add(User.userRegistrationModel.parseCarObject!)
                
                parseUser.saveInBackground { (succeded, error) in
                    user.parseUserId = parseUser.objectId
                    user.managedObjectContext?.saveAndAssertSuccess()
                    
                    let coupon = PFObject(className: "Coupons")
                    coupon.setValue(20, forKey: "value")
                    coupon.setValue(true, forKey: "newUserOnly")
                    coupon.setValue(user.personalCoupon!, forKey: "code")
                    coupon.setValue(user.parseUserId, forKey: "fromUser")
                    coupon.setValue("$20 OFF YOUR FIRST ORDER", forKey: "title")
                    coupon.setValue(true, forKey: "hasToRegenerate")
                    coupon.saveInBackground()
                    
                    completion?(error as NSError?)
                }
            } else {
                completion?(error as NSError?)
            }
        }
        
        AnalyticsManager.sharedInstance.trackCustomEvent(.signupComplete)
        setupAnalyticsForUser(user)

    }
    
    class func saveCarEditing(_ completion: CompletionHandler = nil) {
        User.currentUser()!.removeCars(User.currentUser()!.cars)
        let car = Car(managedObjectContext: sharedModelController.managedObjectContext!)
        car.make = User.userRegistrationModel.carMake
        car.year = User.userRegistrationModel.carYear
        car.model = User.userRegistrationModel.carModel
        car.trim = User.userRegistrationModel.carTrim
        car.engineOilQuarters = User.userRegistrationModel.oilQuarters as NSNumber?

        User.currentUser()!.addCarsObject(car)
        
        let parseUser = PFObject(withoutDataWithClassName: "Users", objectId: User.currentUser()!.parseUserId)
        parseUser.setValue(car.make!, forKey: "carMake")
        parseUser.setValue(car.year!, forKey: "carYear")
        parseUser.setValue(car.model!, forKey: "carModel")
        parseUser.setValue(car.trim!, forKey: "carTrim")
        parseUser.setValue(car.engineOilQuarters!, forKey: "carOilQuarters")
        let carRelation = parseUser.relation(forKey: "car")

        do {
            let oldCars = try carRelation.query().findObjects()
            for car in oldCars {
                carRelation.remove(car)
            }
        } catch _ {

        }

        carRelation.add(User.userRegistrationModel.parseCarObject!)
        
        parseUser.saveInBackground { (succeded, error) in
            User.currentUser()!.managedObjectContext?.saveAndAssertSuccess()
            completion?(error as NSError?)
        }
    }
    
    class func saveCard(_ card: Card, withCustomerId customerId: String, completion: CompletionHandler = nil) {
        User.currentUser()!.stripeCustomerId = customerId
        User.currentUser()!.removeCards(User.currentUser()!.cards)
        
        let last4Digits = card.number!.substring(from: card.number!.characters.index(card.number!.startIndex, offsetBy: 12))
        card.lastFourDigits = last4Digits
        User.currentUser()?.addCardsObject(card)

        let parseUser = PFObject(withoutDataWithClassName: "Users", objectId: User.currentUser()!.parseUserId)
        parseUser.setValue(last4Digits, forKey: "cardLastFourDigits")
        parseUser.setValue(customerId, forKey: "customerId")
        parseUser.saveInBackground { (succeded, error) in
            User.currentUser()!.managedObjectContext?.saveAndAssertSuccess()
            completion?(error as NSError?)
        }
    }

    class func updateAppVersionOnParse() {
        let device = Device()
        let systemVersion = device.systemVersion
        let deviceName = device.description
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber,
            let buildVersionNumber = Bundle.main.buildVersionNumber {
            save(appVersion: releaseVersionNumber, buildNumber: buildVersionNumber, systemVersion: systemVersion, deviceName: deviceName)
        }
    }

    class func save(appVersion verion: String, buildNumber: String, systemVersion: String, deviceName: String, completion: CompletionHandler = nil) {
        let parseUser = PFObject(withoutDataWithClassName: "Users", objectId: User.currentUser()!.parseUserId)
        parseUser.setValue(verion, forKey: "appVersion")
        parseUser.setValue(buildNumber, forKey: "appBuild")
        parseUser.setValue(systemVersion, forKey: "systemVersion")
        parseUser.setValue(deviceName, forKey: "deviceName")
        parseUser.saveInBackground { (succeded, error) in
            User.currentUser()!.managedObjectContext?.saveAndAssertSuccess()
            completion?(error as NSError?)
        }
    }
    
    class func saveCurrentUserFromPFObject(_ parseUser: PFObject) {
        var user: User
        if let currentUser = User.currentUser() {
            user = currentUser
        } else {
            user = User(managedObjectContext: sharedModelController.managedObjectContext!)
        }
        
        user.parseUserId = parseUser.objectId
        user.bringgId = parseUser.object(forKey: "bringgId") as? String
        user.stripeCustomerId = parseUser.object(forKey: "customerId") as? String
        
        user.firstName = parseUser.object(forKey: "firstName") as? String
        user.lastName = parseUser.object(forKey: "lastName") as? String
        user.email = parseUser.object(forKey: "email") as? String
        user.phoneNumber = parseUser.object(forKey: "phoneNumber") as? String
        user.personalCoupon = parseUser.object(forKey: "personalCoupon") as? String

        user.appboyExternalId = parseUser.object(forKey: "appboyId") as? String

        let userCars = parseUser.relation(forKey: "car")

        do {
            let userCar = try userCars.query().findObjects().first

            user.removeCars(user.cars)
            let car = Car(managedObjectContext: sharedModelController.managedObjectContext!)
            car.make = userCar?.object(forKey: "MakeName") as? String //parseUser.objectForKey("carMake") as? String
            car.year = userCar?.object(forKey: "ModelYear") as? String //parseUser.objectForKey("carYear") as? Stringpo
            car.model = userCar?.object(forKey: "ModelName") as? String //parseUser.objectForKey("carModel") as? String
            car.trim = userCar?.object(forKey: "Trim") as? String //parseUser.objectForKey("carTrim") as? String
            if let carExtraIsRequired = userCar?.object(forKey: "RequiredCarSizeExtra") as? String {
                user.requiresCarSizeExtra = carExtraIsRequired == "true"
            }
            car.engineOilQuarters = Double(userCar?.object(forKey: "PartUnitsEngineOil") as! String) as NSNumber? //parseUser.objectForKey("carOilQuarters") as? Double

            user.addCarsObject(car)
        } catch _ {
            
        }
        
        user.removeCards(user.cards)
        let card = Card(managedObjectContext: sharedModelController.managedObjectContext!)
        card.lastFourDigits = parseUser.object(forKey: "cardLastFourDigits") as? String
        user.addCardsObject(card)
        
        ModelController.sharedInstance.managedObjectContext!.saveAndAssertSuccess()
        
        
        setupAnalyticsForUser(user)

    }
    
    class func updateAppboyExternalIdOnParse(_ appboyId: String, completion: CompletionHandler = nil) {
        let parseUser = PFObject(withoutDataWithClassName: "Users", objectId: User.currentUser()!.parseUserId)
        parseUser.setValue(appboyId, forKey: "appboyId")
        parseUser.saveInBackground { (succeded, error) in
            completion?(error)
        }
    }
            
    class func setupAnalyticsForUser(_ user: User) {
        
        
        if let appboyId = user.appboyExternalId {
            AnalyticsManager.sharedInstance.userId = user.parseUserId
            AnalyticsManager.sharedInstance.appboyUserId = appboyId
            AnalyticsManager.sharedInstance.userEmail = user.email
            AnalyticsManager.sharedInstance.userPhone = user.phoneNumber
            AnalyticsManager.sharedInstance.userFirstName = user.firstName
            AnalyticsManager.sharedInstance.userLastName = user.lastName
            
        } else if let phoneNumber = user.phoneNumber {
            
            var appboyId = user.parseUserId
            
            Alamofire.request(DryveAPI.Router.getAppboyId(phoneNumber: phoneNumber)).responseJSON { response in

                if let responseDictionary = response.result.value as? [String: AnyObject],
                    let appboyExternalId = responseDictionary["external_id"] as? String {
                    appboyId = appboyExternalId
                    updateAppboyExternalIdOnParse(appboyExternalId)
                }
                
                User.currentUser()?.appboyExternalId = appboyId
                AnalyticsManager.sharedInstance.userId = user.parseUserId
                AnalyticsManager.sharedInstance.appboyUserId = appboyId
                AnalyticsManager.sharedInstance.userEmail = user.email
                AnalyticsManager.sharedInstance.userPhone = user.phoneNumber
                AnalyticsManager.sharedInstance.userFirstName = user.firstName
                AnalyticsManager.sharedInstance.userLastName = user.lastName
            }
        }
        
    }
    
    func logout() {
        managedObjectContext!.delete(User.currentUser()!)
//        managedObjectContext!.deleteObject(Request.createOrFetchCurrentRequest())
        managedObjectContext!.saveAndAssertSuccess()
    }
    
    class func searchIfAlreadyExisting(_ savingIfExisting: Bool = false, completion: @escaping (Bool) -> ()) {
        let query = PFQuery(className: "Users").whereKey("phoneNumber", contains: userRegistrationModel.phoneNumber!)
        query.findObjectsInBackground { (users, error) -> Void in
            if error == nil {
                if let usersList = users , usersList.count > 0 {
                    if savingIfExisting {
                        self.saveCurrentUserFromPFObject(usersList.first!)
                    }
                    completion(true)
                    return
                }
            }
            
            completion(false)
        }
    }
    
    func getBringgCustomer(_ phoneNumber: String, completion: @escaping ([String: AnyObject]?) -> Void) {
        
        let phoneString = bringgURLParamForPhoneNumber(phoneNumber)
        
        let timestamp = Date().timeIntervalSince1970
        let params: [String: Any] = [
            "timestamp": "\(Int(timestamp))",
            "company_id": Configuration.shared.bringgCompanyId,
            "access_token": Configuration.shared.bringgAccessToken,
            ]
        
        let (query, signature) = signatureForParameters(params)
        
        Alamofire.request("http://developer-api.bringg.com/partner_api/customers/phone/"+phoneString+"?\(query)&signature=\(signature)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<300).responseJSON {
            response in
            switch response.result {
            case .success(let JSON):
                if let data = JSON as? [String: AnyObject] {
                    let customer = data["customer"] as! [String: AnyObject]
                    completion(customer)
                    return
                }
            case .failure(let err):
                print(err)
                completion(nil)
                return
            }
            completion(nil)
        }
        
    }
    
    func createOrUpdateCustomerOnBringg(_ completion: CompletionHandler = nil) {
        //look for an existing BringgCustomer
        getBringgCustomer(phoneNumber!) { [weak self] foundCustomer in
            if let customer = foundCustomer {
                //customer with this phone already exists
                self?.bringgId = String((customer["id"] as! Int))
                self?.wasADelaershipCustomer = true
                self?.updateCustomerOnBringg(completion)
            } else {
                self?.createCustomerOnBringg(completion)
            }
        }
    }
    
    func createCustomerOnBringg(_ completion: CompletionHandler = nil) {
        let timestamp = Date().timeIntervalSince1970
        let phoneString = bringgURLParamForPhoneNumber(phoneNumber!)

        let initialParam: [String: Any] = [
            "name": "\(firstName!) \(lastName!)",
            "phone": "\(phoneString)",
            "timestamp": "\(Int(timestamp))",
            "company_id": Configuration.shared.bringgCompanyId,
            "access_token": Configuration.shared.bringgAccessToken,
            "confirmation_code": "98123",
            "allow_login": true
        ]
        
        let (_, signature) = signatureForParameters(initialParam)
        var finalParam = initialParam
        finalParam["signature"] = signature
        
        Alamofire.request("http://developer-api.bringg.com/partner_api/customers", method: .post, parameters: finalParam, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let JSON):
                if let data = JSON as? [String: AnyObject] {
                    let customer = data["customer"] as! [String: AnyObject]
                    self.bringgId = String((customer["id"] as! Int))
                    completion?(nil)
                }
            case .failure(_):
                completion?(NSError(domain: "Error Creating Customer on Bringg", code: 1, userInfo: nil))
            }
        }
    }

    func updateCustomerOnBringg(_ completion: CompletionHandler = nil) {
        let timestamp = Date().timeIntervalSince1970

        let phoneString = bringgURLParamForPhoneNumber(phoneNumber!)
        
        let initialParam: [String: Any] = [
//            "id": bringgId!,
            "name": "\(firstName!) \(lastName!)",
//            "phone": "\(phoneString)",
            "timestamp": "\(Int(timestamp))",
            "company_id": Configuration.shared.bringgCompanyId,
            "access_token": Configuration.shared.bringgAccessToken,
//            "allow_login": true
            "confirmation_code": "98123"
        ]

        let (_, signature) = signatureForParameters(initialParam)
        var finalParam = initialParam
        finalParam["signature"] = signature

        Alamofire.request("http://api.bringg.com/partner_api/customers/\(bringgId!)", method: .patch, parameters: finalParam, encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
            switch response.result {
            case .success(let JSON):
                if let data = JSON as? [String: Any] {
                    let customer = data["customer"] as! [String: Any]
                    self.bringgId = String((customer["id"] as! Int))
                    completion?(nil)
                }
            case .failure(_):
                completion?(NSError(domain: "Error updating Customer on Bringg", code: 1, userInfo: nil))
            }
        }
    }
    
    func fetchOrderHistory(_ completion: CompletionHandlerWithOrders = nil) {
        let user = PFObject(withoutDataWithClassName: "Users", objectId: parseUserId!)
        let fuelQuery = PFQuery(className: "Requests").whereKey("user", equalTo: user).whereKey("status", equalTo: "done").whereKeyExists("fuelType")
        let washQuery = PFQuery(className: "Requests").whereKey("user", equalTo: user).whereKey("status", equalTo: "done").whereKeyExists("carWashType")
        let oilQuery = PFQuery(className: "Requests").whereKey("user", equalTo: user).whereKey("status", equalTo: "done").whereKeyExists("oilType")

        let query = PFQuery.orQuery(withSubqueries: [fuelQuery, washQuery, oilQuery])

        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {
            (orders, error) -> Void in
            /*if let ordersArray = orders as? [PFObject] {
                for order in ordersArray {
                    
                }
            }*/

            (completion?(orders, error))!
        }
    }
        
    func signatureForParameters(_ param: [String : Any]) -> (String, String) {
        let arrayParam = [] + param
        var query: String = ""
        for index in 0 ..< arrayParam.count {
            if let boolValue = arrayParam[index].1 as? Bool , arrayParam[index].1 as? Int == 0 || arrayParam[index].1 as? Int == 1 {
                query += arrayParam[index].0 + "=" + "\(boolValue)" + "&"
                continue
            }
            if let stringValue = arrayParam[index].1 as? String {
                query += arrayParam[index].0 + "=" + stringValue.encodeURIComponent()! + "&"
            } else {
                query += arrayParam[index].0 + "=\(arrayParam[index].1)&"
            }
        }
        let realQuery = query.substring(to: query.characters.index(before: query.endIndex))
        
        var msgBuff = [UInt8]()
        msgBuff += realQuery.utf8
        
        let hmac: [UInt8] = try! HMAC(key: Configuration.shared.bringgKey, variant: .sha1).authenticate(msgBuff)
        let hmacResult = hmac.toHexString()
        
        return (realQuery, hmacResult)
    }
    
    func bringgURLParamForPhoneNumber(_ string: String) -> String {
        //------
        //temporary solution
        //(310)-435-3710 -> 310-435-3710
        return string.components(separatedBy: "-").map {
            $0.replacingOccurrences(of: "(", with: "")
            }.map {
                $0.replacingOccurrences(of: ")", with: "")
            }.joined(separator: "-").replacingOccurrences(of: " ", with: "-")
        //------
    }

    
}

extension String {
    
    func replaceCharacters(_ characters: String, toSeparator: String) -> String {
        let characterSet = CharacterSet(charactersIn: characters)
        let components = self.components(separatedBy: characterSet)
        let result = components.joined(separator: "")
        return result
    }
    
    func wipeCharacters(_ characters: String) -> String {
        return self.replaceCharacters(characters, toSeparator: "")
    }
}
