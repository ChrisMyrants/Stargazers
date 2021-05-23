import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var interactor: StargazersListInteractor? = nil
    var networkManager: NetworkManager? = nil

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let page = StargazersListPage()
        
        window?.rootViewController = page
        window?.makeKeyAndVisible()
        
        networkManager = NetworkManager()
        interactor = StargazersListInteractor(networkManager: networkManager!, page: page)
    }
    
}

