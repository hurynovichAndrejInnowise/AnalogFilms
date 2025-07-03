import Foundation
import Swinject

enum ContainerFactory {
    
    // MARK: - Static Methods
    
    static func createContainer() -> Container {
        let assembler = Assembler([ServiceAssembler()])
        return assembler.resolver as! Container
    }
}
