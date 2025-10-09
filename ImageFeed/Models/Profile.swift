struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(username)"
        self.bio = profileResult.bio
    }
}
