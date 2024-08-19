//
//  ContentView.swift
//  PullToRefresh
//
//  Created by Sajed Shaikh on 17/08/24.
//

import SwiftUI

struct User: Codable {
    
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

struct UserViewModel: Identifiable {
    var id = UUID().uuidString
    var user: User
}

class UserViewModel2: ObservableObject {
    @Published var users = [
        UserViewModel(
            user: User(name: "Sajed", email: "hello@gmail.com")
        )
    ]
    
    func refreshUsers() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let newUsers = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    self.users.append(contentsOf: newUsers.compactMap({
                        return UserViewModel(user: $0)
                    }))
                }
            } catch {
                print(error)
            }
            
        }
        
        task.resume()
        
    }
    
}

struct ContentView: View {
    
    @ObservedObject var viewModel = UserViewModel2()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, content: {
                List(viewModel.users) { userVM in
                    Text(userVM.user.name)
                        .font(.title)
                        .bold()
                    Text(userVM.user.email)
                        .font(.body)
                }.refreshable {
                    self.viewModel.refreshUsers()
                }
            }).navigationTitle("Friend List")
        }
    }
}

#Preview {
    ContentView()
}
