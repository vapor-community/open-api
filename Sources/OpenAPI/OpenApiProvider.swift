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

public protocol RegexableString: LosslessStringConvertible, Hashable {
    
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
    public let summary: String?
    public let description: String?
    public let get: OpenAPIOperation?
    public let put: OpenAPIOperation?
    public let post: OpenAPIOperation?
    public let delete: OpenAPIOperation?
    public let options: OpenAPIOperation?
    public let head: OpenAPIOperation?
    public let patch: OpenAPIOperation?
    public let trace: OpenAPIOperation?
    public let servers: [OpenAPIServer]?
    public let parameters: [OpenAPIParameter]?
}

public struct OpenAPIOperation: Content {
    public let tags: [String]?
    public let summary: String?
    public let description: String?
    public let externalDocs: OpenAPIExternalDocs?
    public let operationId: String
    public let parameters: [OpenAPIParameter]?
    public let requestBody: OpenAPIRequestBody?
    public let responses: OpenAPIResponses
    public let callbacks: [String: OpenAPICallback]?
    public let deprecated: Bool?
    public let security: [OpenAPISecurityRequirement]?
    public let servers: [OpenAPIServer]?
}

public struct OpenAPIExternalDocs: Content {
    public let description: String?
    public let url: URL
}

public struct OpenAPIParameter: Content {
    public let name: String
    public let `in`: OpenAPIParameterLocation
    public let description: String?
    public private(set) var required: Bool; #warning(#"TODO: If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false."#)
    public let deprecated: Bool?
    public let allowEmptyValue: Bool
}

public enum OpenAPIParameterLocation: String, Content {
    case query, header, path, cookie
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
