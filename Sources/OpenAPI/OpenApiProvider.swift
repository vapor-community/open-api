import Vapor

public final class OpenAPIProvider: Provider {
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

private protocol OpenAPIParamterBase: Encodable {
    var `in`: OpenAPIParameterLocation { get }
    var description: String? { get }
    var required: Bool { get }
    var deprecated: Bool? { get }
    var allowEmptyValue: Bool? { get }
    var style: OpenAPIParameterStyle? { get }
    var explode: Bool? { get }
    var allowReserved: Bool? { get }
    var schema: OpenAPISchema? { get }
    var example: Codable? { get }
    var examples: [String: OpenAPIExample]? { get }
    var content: [String: OpenAPIMediaType]? { get }
}

public struct OpenAPIParameter: OpenAPIParamterBase {
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
    public let content: [String: OpenAPIMediaType]?
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
        try container.encode(self.default, forKey: StringCodingKey("default"))
        try self.codeMap?.forEach { (arg) in
            try container.encode(arg.1, forKey: StringCodingKey(arg.0.value))
        }
    }
    
    public struct HTTPStatusCodeString: RegexableString {
        static public var regex: String = #"[1-5](X{2}|[0-9]{2})"#
        
        public var value: String
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
            try container.encode(paths, forKey: StringCodingKey(key))
        }
    }
}

public struct OpenAPIPaths: Encodable {
    internal let pathMap: [OpenAPIPathString: OpenAPIPath]
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try self.pathMap.forEach { (arg) in
            let (key, value) = arg
            try container.encode(value, forKey: StringCodingKey(key.value))
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

public struct OpenAPIHeader: OpenAPIParamterBase {
    public let `in`: OpenAPIParameterLocation = .header
    public let description: String?
    public private(set) var required: Bool; #warning(#"TODO: If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false."#)
    public let deprecated: Bool?
    public let allowEmptyValue: Bool?
    public let style: OpenAPIParameterStyle? = .simple
    public let explode: Bool? = false
    public let allowReserved: Bool? = nil
    public let schema: OpenAPISchema?
    public let example: Codable?
    public let examples: [String: OpenAPIExample]?
    public let content: [String: OpenAPIMediaType]?
}

public struct OpenAPITag: Encodable {
    public let name: String
    public let description: String?
    public let externalDocs: OpenAPIExternalDocs?
}

public protocol OpenAPISchemaProtocol: Encodable {
    var title: String? { get }
    var multipleOf: Double? { get }
    var maximum: Double? { get }
    var exclusiveMaximum: Double? { get }
    var minimum: Double? { get }
    var exclusiveMinimum: Double? { get }
    var maxLength: Int? { get }
    var minLength: Int? { get }
    var pattern: String? { get }
    var maxItems: Int? { get }
    var minItems: Int? { get }
    var uniqueItems: Bool? { get }
    var maxProperties: Int? { get }
    var minProperties: Int? { get }
    var required: Bool? { get }
    var `enum`: [EncodableWrapper]? { get }
    var type: String? { get }
    var allOf: OpenAPISchemaProtocol? { get }
    var oneOf: OpenAPISchemaProtocol? { get }
    var anyOf: OpenAPISchemaProtocol? { get }
    var not: OpenAPISchemaProtocol? { get }
    var items: OpenAPISchemaProtocol? { get }
    var properties: OpenAPISchemaProtocol? { get }
    var additionalProperties: OpenAPISchemaProtocol? { get }; #warning("Can also be a boolean")
    var description: String? { get }
    var format: OpenAPIDataType? { get }
    var `default`: EncodableWrapper? { get }
    var nullable: Bool? { get }
    var discriminator: OpenAPIDiscriminator? { get }
    var readOnly: Bool? { get }
    var writeOnly: Bool? { get }
    var xml: OpenAPIXML? { get }
    var externalDocs: OpenAPIExternalDocs? { get }
    var example: OpenAPIExample? { get }
    var deprecated: Bool? { get }
}

public struct OpenAPISchema: OpenAPISchemaProtocol {
    public let title: String?
    public let multipleOf: Double?
    public let maximum: Double?
    public let exclusiveMaximum: Double?
    public let minimum: Double?
    public let exclusiveMinimum: Double?
    public let maxLength: Int?
    public let minLength: Int?
    public let pattern: String?
    public let maxItems: Int?
    public let minItems: Int?
    public let uniqueItems: Bool?
    public let maxProperties: Int?
    public let minProperties: Int?
    public let required: Bool?
    public let `enum`: [EncodableWrapper]?
    public let type: String?
    public let allOf: OpenAPISchemaProtocol?
    public let oneOf: OpenAPISchemaProtocol?
    public let anyOf: OpenAPISchemaProtocol?
    public let not: OpenAPISchemaProtocol?
    public let items: OpenAPISchemaProtocol?
    public let properties: OpenAPISchemaProtocol?
    public let additionalProperties: OpenAPISchemaProtocol?; #warning("Can also be a boolean")
    public let description: String?
    public let format: OpenAPIDataType?
    public let `default`: EncodableWrapper?
    public let nullable: Bool?
    public let discriminator: OpenAPIDiscriminator?
    public let readOnly: Bool?
    public let writeOnly: Bool?
    public let xml: OpenAPIXML?
    public let externalDocs: OpenAPIExternalDocs?
    public let example: OpenAPIExample?
    public let deprecated: Bool?
}

public enum OpenAPIDataType: String, Encodable {
    case integer, long, float, double, string, byte, binary, boolean, date, dateTime, password
}

public struct OpenAPIDiscriminator: Encodable {
    public let propertyName: String
    public let mapping: [String: String]
}

public struct OpenAPIXML: Encodable {
    public let name: String?
    public let namespace: String?
    public let prefix: String?
    public let attribute: Bool?
    public let wrapped: Bool?
}

public enum OpenAPISecuritySchemeType: String, Encodable {
    case apiKey, http, oauth2, openIdConnect
}

public protocol OpenAPISecurityScheme: Encodable {
    var type: OpenAPISecuritySchemeType { get }
    var description: String? { get }
}

public struct OpenAPISecuritySchemeAPIKey: OpenAPISecurityScheme {
    public enum Location: String, Encodable {
        case query, header, cookie
    }
    public let type: OpenAPISecuritySchemeType = .apiKey
    public let description: String?
    public let name: String
    public let `in`: OpenAPISecuritySchemeAPIKey.Location
}

public struct OpenAPISecuritySchemeHTTP: OpenAPISecurityScheme {
    public enum Scheme: String, Encodable {
        case basic, bearer, digest, hoba, mutual, negotiate, oauth, scramSha1 = "scram-sha-1", scramSha256 = "scram-sha-256", vapid
    }
    public let type: OpenAPISecuritySchemeType = .http
    public let description: String?
    public let scheme: OpenAPISecuritySchemeHTTP.Scheme
    public let bearerFormat: String?
}

public struct OpenAPISecuritySchemeOAuth2: OpenAPISecurityScheme {
    public struct Flows: Encodable {
        public struct URLFlow: Encodable {
            public let refreshUrl: String?
            public let scopes: [String : String]
            public let authorizationUrl: String
        }
        public struct BaseFlow: Encodable {
            public let refreshUrl: String?
            public let scopes: [String : String]
        }
        public struct TokenFlow: Encodable {
            public let refreshUrl: String?
            public let scopes: [String : String]
            public let tokenUrl: String
        }
        public struct TokenUrlFlow: Encodable {
            public let refreshUrl: String?
            public let scopes: [String : String]
            public let tokenUrl: String
            public let authorizationUrl: String
        }
        
        public let implicit: URLFlow?
        public let password: TokenFlow?
        public let clientCredentials: TokenFlow?
        public let authorizationCode: TokenUrlFlow?
    }
    public let type: OpenAPISecuritySchemeType = .oauth2
    public let description: String?
    public let flows: OpenAPISecuritySchemeOAuth2.Flows
}

public struct OpenAPISecuritySchemeOpenIdConnect: OpenAPISecurityScheme {
    public let type: OpenAPISecuritySchemeType = .openIdConnect
    public let description: String?
    public let openIdConnectUrl: String
}

public struct OpenAPISecurityRequirement: Encodable {
    public let name: String
    public let value: [String]
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encode(self.value, forKey: .init(name))
    }
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
