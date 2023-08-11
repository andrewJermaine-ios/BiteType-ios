import UIKit



protocol ResponseObservable: AnyObject {
    var user: String? { get }
    var eventDate: Date? { get }
    
    
    func addObserver(observer: ResponseObserver)
    func removeObserver(observer: ResponseObserver)
    func notifyObservers(withMessage: String?)
}
protocol ResponseObserver: AnyObject {
    func notifyResponseReceived(fromObserverable: ResponseObservable, event: ResponseEvent?, withMessage: String?)
}

protocol ResponseEvent {
    var user: String { get }
    var date: Date { get }
}


class AiResponse: ResponseObservable {
    var user: String?
    var eventDate: Date?
    private var observers: [ResponseObserver] = []
    
    func addObserver(observer: ResponseObserver) {
        if observers.contains(where: {$0 === observer}) == false {
            observers.append(observer)
        }
    }
    
    func removeObserver(observer: ResponseObserver) {
        if let index = observers.firstIndex(where: {$0 === observer}) {
            observers.remove(at: index)
        }
    }
    
    func notifyObservers(withMessage: String?) {
        let event = getResponseEvent()
        observers.forEach { (observer) in
            observer.notifyResponseReceived(fromObserverable: self, event: event, withMessage: withMessage)
        }
    }
    
    private func getResponseEvent() -> ResponseEvent? {
        var event: ResponseEvent?
        if let user = self.user, let date = self.eventDate {
            event = ResponseData(user: user, date: date)
        }
        return event
    }
    
    func startDietQuery(user: String) {
        self.user = user
        self.eventDate = Date()
        
        notifyObservers(withMessage: "Diet Query has been started!")
    }
    
    
    func startImageQuery() {
        self.eventDate = Date()
        notifyObservers(withMessage: "Image Query has been started!")

    }
    
}
fileprivate struct ResponseData: ResponseEvent {
    var user: String
    var date: Date
}

class PullController: ResponseObserver {
    
    private var user: String?
    private var queryDate: String?
    
    weak var observable: ResponseObservable? {
        willSet {
            observable?.removeObserver(observer: self)
            
            if let value = newValue {
                value.addObserver(observer: self)
            }
        }
    }
    
    func notifyResponseReceived(fromObserverable: ResponseObservable,event: ResponseEvent?, withMessage: String?) {
        self.user = fromObserverable.user
        self.queryDate = event?.date.description(with: .current)
        
        print("Pull controller:", user!, queryDate!, withMessage!)
    }
}

class PushController: ResponseObserver {
    
    
    private var user: String?
    private var queryDate: String?
    
    private weak var observable: ResponseObservable?
    
    init(withObservable observable: ResponseObservable) {
        self.observable = observable
        self.observable?.addObserver(observer: self)
    }
    
    func cleanup() {
        observable?.removeObserver(observer: self)
    }
    func notifyResponseReceived(fromObserverable: ResponseObservable, event: ResponseEvent?, withMessage: String?) {
        self.user = fromObserverable.user
        self.queryDate = fromObserverable.eventDate?.description(with: .current)
        
        print("Push controller:", user!, queryDate!, withMessage!)
    }
}


let thisResponse = AiResponse() // create your response object
let pullController = PullController() //create pull
pullController.observable = thisResponse

let pushController = PushController(withObservable: thisResponse) //create push

thisResponse.startDietQuery(user: "Andrew")
thisResponse.startImageQuery()

 
protocol AiQueryBuilder {
    func query( _ message: String)
}

struct AiQuery {
    let builder: AiQueryBuilder
    
    func myQuery(_ mealType: String?, _ fatIntake: String?, _ carbIntake: String?, _ proteinIntake: String?) {
        let message = "Please make me a daily \(mealType ?? "")-based meal plan, with \(fatIntake ?? "")g of fat, \(carbIntake ?? "")g of carbs, and \(proteinIntake ?? "")g of protein"
        
        builder.query(message)
    }
}
struct MainQuery: AiQueryBuilder {
    func query(_ message: String) {
        print(message)

    }
}

var fullQuery = AiQuery(builder: MainQuery())
fullQuery.myQuery("Standard", "108", "162", "404")
