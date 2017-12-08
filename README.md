# NetworkingKit

This is a homemade Networking framework, and this is the networking approach that I preferred. 

## Features
- [x] **APIResource**: Use **APIResource** to capture all api request related content.
- [x] **APIService**: Use **APIService** to load any generic **APIResource**.
- [x] **Error handling**: Proper network error handling.

## Usage
- For a url that returns this json:
```json
{
  "name": "Nan Wang",
  "phone": "+46 000 1111 222"
}
```
- Create model with a failable initialiser that parses a json:
```swift 
struct User {
  let name: String
  let phone: String
}

extension User {
    init?(json: Any) {
        guard
            let jsonDictionary = json as? [String: Any],
            let name = jsonDictionary["name"] as? String,
            let phone = jsonDictionary["phone"] as? String
            else { return nil }
        
        self.name = name
        self.phone = phone
    }
}
```
- Load **APIResource** with **APIService**:
```swift
/// Create an API resource for the **User** model
let resource = APIResource<User>(url: url_to_load, parse: User.init)

/// Create an API service with default shared url session
/// This API service can be dependency injected into any `ViewController` or classes when needed. 
let apiService = APIService()

/// Load resource with API service
apiService.load(resource: resource) { (result) in
    switch result {
    case .success(let user):
    /// Do something with user
    case .failure(let error):
    /// Do something with `NetworkingError`
    }
}
```
