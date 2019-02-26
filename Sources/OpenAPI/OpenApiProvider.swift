import Vapor

public final class OpenApiProvider: Provider {
    public func register(_ s: inout Services) throws {
        
    }
}

public struct OpenAPIDefaults {
    public let info: OpenAPIInfo

}

public struct OpenApiService {
    public let info: OpenAPIInfo

    var routes: [Route]
    
    func getOpenAPISpec() -> Codable {
        fatalError()
    }
}

public struct OpenAPIInfo: Content {
    public let title: String
    public let description: String?
    public let version: String
    
    public let termsOfService: URL?
    
    public let contact: OpenAPIContact?
    
    public let license: OpenAPILicense?
}

public struct OpenAPIContact: Content {
    public let name: String?
    public let url: String?
    public let email: String?
}

public struct OpenAPILicense: Content {
    public let name: String
    public let url: URL
}

public struct OpenAPIServer: Content {
    public let url: String
    public let description: String?
    public let variables: [String: OpenAPIServerVariable]
}

public struct OpenAPIServerVariable: Content {
    public let `enum`: [String]?
    public let `default`: String
    public let description: String?
}

public protocol RegexableString: LosslessStringConvertible {
    
    static var regex: String { get }
    
    var value: String { get set }
    
    init?(_ description: String)
    
    var description: String { get }
}

extension RegexableString {
    public init?(_ description: String) {
        guard let _ = description.range(of: Self.regex, options: .regularExpression) else { return nil }
        self.value = description
    }
    
    public var description: String {
        return value
    }
}

extension Dictionary where Key: RegexableString {
    subscript (string: String) -> Value? {
        get {
            guard let key = Key.init(string) else { return nil }
            return self[key]
        }
        set {
            guard let key = Key.init(string) else { return }; #warning("This should probably throw an error or something")
            self[key] = newValue
        }
    }
}

public struct OpenAPIKeyString: RegexableString {
    public static var regex: String = #"^[a-zA-Z0-9\.\-_]+$"#
    
    public var value: String
}

public struct OpenAPIComponents: Content {
    public let schemas: [OpenAPIKeyString: OpenAPISchema]?
    public let responses: [OpenAPIKeyString: OpenAPIResponse]?
    public let parameters: [OpenAPIKeyString: OpenAPIParameter]?
    public let examples: [OpenAPIKeyString: OpenAPIExample]?
    public let requestBodies: [OpenAPIKeyString: OpenAPIExample]?
    public let headers: [OpenAPIKeyString: OpenAPIHeader]?
    public let securitySchemes: [OpenAPIKeyString: OpenAPISecurityScheme]?
    public let links: [OpenAPIKeyString: OpenAPILink]?
    public let callbacks: [OpenAPIKeyString: OpenAPICallback]?
}

public struct OpenAPIPathString: RegexableString {
    public static var regex: String = #"\/.*"#
    
    public var value: String
}

public struct OpenAPIPath: Content {
    
}


public struct OpenAPISpec: Content {
    public let openapi: String = "3.0.0"
    
    public let info: OpenAPIInfo
    
    public let servers: [OpenAPIServer]
    
    public let paths: [OpenAPIPathString: OpenAPIPath]
    
    public let components: OpenAPIComponents?
    
    public let security: [OpenAPISecurityRequirement]?
    
    public let tags: [OpenAPITag]?
    
    public let externalDocs: OpenAPIExternalDocs?
    
}
