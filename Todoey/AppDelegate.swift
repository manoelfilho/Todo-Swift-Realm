import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //para descobrir o local onde os dados estao salvos:
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
//        Simples teste para cadastro de dados com Real
//        let data = Data()
//        data.name = "Jose"
//        data.age = 35
//
//        do {
//            let realm = try Realm()
//
//            try realm.write {
//                realm.add(data)
//            }
//
//        }catch{
//            print("error init realm \(error)")
//        }
        // final teste
        
        return true
    }


}

