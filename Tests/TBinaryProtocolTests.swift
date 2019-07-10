//
//  TBinaryProtocolTests.swift
//  Thrift
//
//  Created by Christopher Simpson on 8/18/16.
//
//

import XCTest
import Foundation
@testable import Thrift

/// Testing Binary protocol read/write against itself
/// Uses separate read/write transport/protocols
class TBinaryProtocolTests: XCTestCase {
    var transport: TMemoryBufferTransport = TMemoryBufferTransport(flushHandler: {
        $0.reset(readBuffer: $1)
    })

    var proto: TBinaryProtocol!

    override func setUp() {
        super.setUp()
        proto = TBinaryProtocol(on: transport)
        transport.reset()
    }

    override func tearDown() {
        super.tearDown()
        transport.reset()
    }

    func testInt8WriteRead() {
        let writeVal: UInt8 = 250
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: UInt8 = (try? proto.read()) ?? 0
        XCTAssertEqual(writeVal, readVal, "Error with UInt8, wrote \(writeVal) but read \(readVal)")
    }

    func testInt16WriteRead() {

        let writeVal: Int16 = 12312
        try? proto.write(writeVal)
        try? transport.flush()
        let readVal: Int16 = (try? proto.read()) ?? 0
        XCTAssertEqual(writeVal, readVal, "Error with Int16, wrote \(writeVal) but read \(readVal)")
    }

    func testInt32WriteRead() {
        let writeVal: Int32 = 2029234
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: Int32 = (try? proto.read()) ?? 0
        XCTAssertEqual(writeVal, readVal, "Error with Int32, wrote \(writeVal) but read \(readVal)")
    }

    func testInt64WriteRead() {
        let writeVal: Int64 = 234234981374134
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: Int64 = (try? proto.read()) ?? 0
        XCTAssertEqual(writeVal, readVal, "Error with Int64, wrote \(writeVal) but read \(readVal)")
    }

    func testDoubleWriteRead() {
        let writeVal: Double = 3.1415926
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: Double = (try? proto.read()) ?? 0.0
        XCTAssertEqual(writeVal, readVal, "Error with Double, wrote \(writeVal) but read \(readVal)")
    }

    func testBoolWriteRead() {
        let writeVal: Bool = true
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: Bool = (try? proto.read()) ?? false
        XCTAssertEqual(writeVal, readVal, "Error with Bool, wrote \(writeVal) but read \(readVal)")
    }

    func testStringWriteRead() {
        let writeVal: String = "Hello World"
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: String!
        do {
            readVal = try proto.read()
        }
        catch let error {
            XCTAssertFalse(true, "Error reading \(error)")
            return
        }

        XCTAssertEqual(writeVal, readVal, "Error with String, wrote \(writeVal) but read \(String(describing: readVal))")
    }

    func testDataWriteRead() {
        let writeVal: Data = "Data World".data(using: .utf8)!
        try? proto.write(writeVal)
        try? transport.flush()

        let readVal: Data = (try? proto.read()) ?? "Goodbye World".data(using: .utf8)!
        XCTAssertEqual(writeVal, readVal, "Error with Data, wrote \(writeVal) but read \(readVal)")
    }

    func testStructWriteRead() {
        let msg = "Test Protocol Error"
        let writeVal = TApplicationError(error: .protocolError, message: msg)
        do {
            try writeVal.write(to: proto)
            try? transport.flush()

        }
        catch let error {
            XCTAssertFalse(true, "Caught Error attempting to write \(error)")
        }

        do {
            let readVal = try TApplicationError.read(from: proto)
            XCTAssertEqual(readVal.error.thriftErrorCode, writeVal.error.thriftErrorCode, "Error case mismatch, expected \(readVal.error) got \(writeVal.error)")
            XCTAssertEqual(readVal.message, writeVal.message, "Error message mismatch, expected \(String(describing: readVal.message)) got \(String(describing: writeVal.message))")
        }
        catch let error {
            XCTAssertFalse(true, "Caught Error attempting to read \(error)")
        }
    }

	func testStructWrite() {
		let writeVal = OttXcCommunity(id: 124, name: "Community name", customDescription: "Long description", isActive: true)
		do {
			try writeVal.write(to: proto)
			try? transport.flush()

		}
		catch let error {
			XCTAssertFalse(true, "Caught Error attempting to write \(error)")
		}

		do {
			let readVal = try OttXcCommunity.read(from: proto)
			XCTAssertEqual(readVal.customDescription, writeVal.customDescription, "Description mismatch, expected \(readVal.customDescription) got \(writeVal.customDescription)")
		}
		catch let error {
			XCTAssertFalse(true, "Caught Error attempting to read \(error)")
		}
	}

    static var allTests: [(String, (TBinaryProtocolTests) -> () throws -> Void)] {
        return [
            ("testInt8WriteRead", testInt8WriteRead),
            ("testInt16WriteRead", testInt16WriteRead),
            ("testInt32WriteRead", testInt32WriteRead),
            ("testInt64WriteRead", testInt64WriteRead),
            ("testDoubleWriteRead", testDoubleWriteRead),
            ("testBoolWriteRead", testBoolWriteRead),
            ("testStringWriteRead", testStringWriteRead),
            ("testDataWriteRead", testDataWriteRead),
            ("testStructWriteRead", testStructWriteRead),
			("testStructWrite", testStructWrite)
        ]
    }


}

public final class OttXcCommunity: Codable {

	// MARK: - Properties

	public var id: Int64?
	public var name: String?
	public var customDescription: String?
	public var isActive: Bool?

	// MARK: - Initializers

	public init() { }
	public init(id: Int64?, name: String?, customDescription: String?, isActive: Bool?) {
		self.id = id
		self.name = name
		self.customDescription = customDescription
		self.isActive = isActive
	}

}

public func ==(lhs: OttXcCommunity, rhs: OttXcCommunity) -> Bool {
	return
		(lhs.id == rhs.id) &&
			(lhs.name == rhs.name) &&
			(lhs.customDescription == rhs.customDescription) &&
			(lhs.isActive == rhs.isActive)
}

extension OttXcCommunity: CustomStringConvertible {

	public var description : String {
		var desc = "OttXcCommunity("
		desc += "id=\(String(describing: self.id)),"
		desc += "name=\(String(describing: self.name)),"
		desc += "description=\(String(describing: self.customDescription)),"
		desc += "isActive=\(String(describing: self.isActive))"
		desc += ")"
		return desc
	}

}

extension OttXcCommunity: Hashable {

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(name)
		hasher.combine(customDescription)
		hasher.combine(isActive)
	}

}

extension OttXcCommunity: TStruct {

	public static var fieldIds: [String: Int32] {
		return ["id": 1, "name": 2, "description": 3, "isActive": 4, ]
	}

	public static var structName: String { return "OttXcCommunity" }

	public static func read(from sourceProtocol: TProtocol) throws -> OttXcCommunity {
		_ = try sourceProtocol.readStructBegin()
		var id: Int64?
		var name: String?
		var customDescription: String?
		var isActive: Bool?

		fields: while true {

			let (_, fieldType, fieldID) = try sourceProtocol.readFieldBegin()

			switch (fieldID, fieldType) {
			case (_, .stop):            break fields
			case (1, .i64):             id = try Int64.read(from: sourceProtocol)
			case (2, .string):           name = try String.read(from: sourceProtocol)
			case (3, .string):           customDescription = try String.read(from: sourceProtocol)
			case (4, .bool):            isActive = try Bool.read(from: sourceProtocol)
			case let (_, unknownType):  try sourceProtocol.skip(type: unknownType)
			}

			try sourceProtocol.readFieldEnd()
		}

		try sourceProtocol.readStructEnd()

		return OttXcCommunity(id: id, name: name, customDescription: customDescription, isActive: isActive)
	}

}
