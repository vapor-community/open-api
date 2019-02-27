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

public struct OpenAPIInfo: Encodable {
    public let title: String
    public let description: String?
    public let version: String
    
    public let termsOfService: URL?
    
    public let contact: OpenAPIContact?
    
    public let license: OpenAPILicense?
}

public struct OpenAPIContact: Encodable {
    public let name: String?
    public let url: String?
    public let email: String?
}

public struct OpenAPILicense: Encodable {
    public let name: String
    public let url: URL
}

public struct OpenAPIServer: Encodable {
    public let url: String
    public let description: String?
    public let variables: [String: OpenAPIServerVariable]
}

public struct OpenAPIServerVariable: Encodable {
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

public struct OpenAPIComponents: Encodable {
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

public struct OpenAPIPath: Encodable {
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

public struct OpenAPIOperation: Encodable {
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

public struct OpenAPIExternalDocs: Encodable {
    public let description: String?
    public let url: URL
}

public struct OpenAPIParameter: Encodable {
    public let name: String
    public let `in`: OpenAPIParameterLocation
    public let description: String?
    public private(set) var required: Bool; #warning(#"TODO: If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false."#)
    public let deprecated: Bool?
    public let allowEmptyValue: Bool?
    public let style: OpenAPIParameterStyle?
    public let explode: Bool?
    public let allowReserved: Bool?
    public let schema: OpenAPISchema?
    public let example: Codable?
    public let examples: [String: OpenAPIExample]?
    public let Encodable: [String: OpenAPIMediaType]?
}

public enum OpenAPIParameterStyle: String, Encodable {
    case matrix, label, form, simple, spaceDelimited
    case pipeDelimited, deepObject
}

public enum OpenAPIParameterLocation: String, Encodable {
    case query, header, path, cookie
}

public struct OpenAPIRequestBody: Encodable {
    public let description: String?
    public let Encodable: [String: OpenAPIMediaType]
    public let requred: Bool?
}

public struct OpenAPIMediaType: Encodable {
    public let schema: OpenAPISchema?
    public let example: Codable
    public let examples: [String: OpenAPIExample]?
    public let encoding: [String: OpenAPIEncoding]?
}

public struct OpenAPIEncoding: Encodable {
    public let EncodableType: String?
    public let headers: [HTTPHeaderName: HTTPHeaderValue]?
    public let style: OpenAPIParameterStyle?
    public let explode: Bool?
    public let allowReserved: Bool?
}

public struct OpenAPIResponses: Encodable {
    public let `default`: OpenAPIResponse?
    public let codeMap: [HTTPStatusCodeString: OpenAPIResponse]?
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encode(self.default, forKey: StringCodingKey(str: "default"))
        try self.codeMap?.forEach { key, value in
            try container.encode(value, forKey: StringCodingKey(str: key.value))
        }
    }
    
    public struct HTTPStatusCodeString: RegexableString {
        static public var regex: String = #"[1-5](X{2}|[0-9]{2})"#
        
        public var value: String
    }
}


private struct StringCodingKey: CodingKey {
    init(str: String) {
        self.init(stringValue: str)!
    }
    
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
    }
}

public struct OpenAPIResponse: Encodable {
    public let description: String
    public let headers: [HTTPHeaderName: HTTPHeaderValue]?
    public let Encodable: [String: OpenAPIMediaType]?
    public let links: [String: OpenAPILink]?
}

public struct OpenAPICallback: Encodable {
    public let callbackMap: [String: OpenAPIPaths]?
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try self.callbackMap?.forEach { key, paths in
            guard paths.pathMap.count == 1 else { return } // This is a little ugly
            try container.encode(paths, forKey: StringCodingKey(str: key))
        }
    }
}

public struct OpenAPIPaths: Encodable {
    internal let pathMap: [OpenAPIPathString: OpenAPIPath]
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try self.pathMap.forEach { (arg) in
            let (key, value) = arg
            try container.encode(value, forKey: StringCodingKey(str: key.value))
        }
    }
}

public protocol OpenAPIExample: Encodable { }

public struct CodableOpenAPIExample<T: Encodable>: OpenAPIExample {
    public let summary: String?
    public let description: String?
    public let value: T
}

public struct ExternalOpenAPIExample: OpenAPIExample {
    public let summary: String?
    public let description: String?
    public let externalValue: URL
}

public struct OpenAPILink: Encodable {
    public let operationRef: String?
    public let operationId: String?
    public let parameters: [String: String]?
    public let requestBody: String?
    public let description: String?
    public let server: OpenAPIServer?
}

public struct OpenAPIHeader: Encodable {
    
}

public struct OpenAPISpec: ResponseEncodable, Encodable {
    public func encodeResponse(for req: HTTPRequest, using ctx: Context) -> EventLoopFuture<HTTPResponse> {
        var res = HTTPResponse()
        do {
            try res.encode(self, as: .json)
        } catch {
            return ctx.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Failed to encode \(OpenAPISpec.self) to response"))
        }
        return ctx.eventLoop.makeSucceededFuture(res)
    }
    
    public let openapi: String = "3.0.0"
    
    public let info: OpenAPIInfo
    
    public let servers: [OpenAPIServer]
    
    public let paths: OpenAPIPaths
    
    public let components: OpenAPIComponents?
    
    public let security: [OpenAPISecurityRequirement]?
    
    public let tags: [OpenAPITag]?
    
    public let externalDocs: OpenAPIExternalDocs?
    
}
