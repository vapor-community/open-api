import Vapor

func x(_ r: Routes) throws {
    r.get(.catchall) { (req, ctx) -> String in
        return ""
    }.openApi()
}

extension Route {
    @discardableResult
    func openApi() -> Route {
        return self
    }
}
