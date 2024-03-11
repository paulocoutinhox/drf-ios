import SwiftUI

func doLogin() {
    let loginData = [
        "username": "admin",
        "password": "admin"
    ]
    
    APIClient.shared.request(endpoint: "token/", method: "post", parameters: loginData) { (result: Result<APIResponse<LoginToken>, Error>) in
        switch result {
        case .success(let response):
            if let data = response.data {
                APIClient.shared.setAuthToken(data.access)
                print("Login Token: ", data.access)
                
                doGetCustomer()
            } else {
                print("Login Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case .failure(let error):
            print("Login Error: ", error)
        }
    }
}

func doGetCustomer() {
    APIClient.shared.request(endpoint: "customer/1", method: "get") { (result: Result<APIResponse<Customer>, Error>) in
        switch result {
        case .success(let response):
            if let data = response.data {
                print("Customer: ", data)
                
                doGetCustomers()
            } else {
                print("Get Customer Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case .failure(let error):
            print("Error: ", error)
        }
    }
}

func doGetCustomers() {
    APIClient.shared.request(endpoint: "customer/", method: "get", isList: true) { (result: Result<APIResponse<[Customer]>, Error>) in
        switch result {
        case .success(let response):
            if let data = response.data {
                print("Response data: ", data)
            } else {
                print("Get Customers Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case .failure(let error):
            print("Error: ", error)
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("PyAA - Test")
            Button {
                doLogin()
            } label: {
                Text("Make Request")
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
