import SwiftUI

func doLogin() {
    let loginData = [
        "username": "admin",
        "password": "admin",
    ]

    APIClient.shared.request(endpoint: "token/", method: "post", parameters: loginData, type: .single) { (result: Result<Response<ResponseAuthToken>, Error>) in
        switch result {
        case let .success(response):
            if let data = response.data {
                APIClient.shared.setAuthToken(data.access)
                print("Login Token: ", data.access)

                doGetCustomer()
            } else {
                print("Login Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case let .failure(error):
            print("Login Error: ", error)
        }
    }
}

func doGetCustomer() {
    APIClient.shared.request(endpoint: "customer/1", method: "get", type: .single) { (result: Result<Response<Customer>, Error>) in
        switch result {
        case let .success(response):
            if let data = response.data {
                print("Customer: ", data)

                doGetCustomers()
            } else {
                print("Get Customer Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case let .failure(error):
            print("Error: ", error)
        }
    }
}

func doGetCustomers() {
    APIClient.shared.request(endpoint: "customer/", method: "get", type: .list) { (result: Result<Response<[Customer]>, Error>) in
        switch result {
        case let .success(response):
            if let data = response.data {
                print("Response data: ", data)
            } else {
                print("Get Customers Response: ", response.httpCode, " - ", response.success, " - ", response.message ?? "", " - ", response.errors ?? [])
            }
        case let .failure(error):
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
            Text("Django Rest Framework - Test")
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
