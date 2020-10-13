//
//  SipHasher.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-03-08.
//  Copyright © 2016-2017 Károly Lőrentey.

private func rotateLeft(_ value: UInt64, by amount: UInt64) -> UInt64 {
    return (value << amount) | (value >> (64 - amount))
}

/// An implementation of the [SipHash-2-4](https://131002.net/siphash) hashing algorithm,
/// suitable for use in projects outside the Swift standard library.
/// (The Swift stdlib already includes SipHash; unfortunately its API is not public.)
///
/// SipHash was invented by Jean-Philippe Aumasson and Daniel J. Bernstein.
public struct SipHasher {
    /// The number of compression rounds.
    private static let c = 2
    /// The number of finalization rounds.
    private static let d = 4

    /// Word 0 of the internal state, initialized to ASCII encoding of "somepseu".
    var v0: UInt64 = 0x736f6d6570736575
    /// Word 1 of the internal state, initialized to ASCII encoding of "dorandom".
    var v1: UInt64 = 0x646f72616e646f6d
    /// Word 2 of the internal state, initialized to ASCII encoding of "lygenera".
    var v2: UInt64 = 0x6c7967656e657261
    /// Word 3 of the internal state, initialized to ASCII encoding of "tedbytes".
    var v3: UInt64 = 0x7465646279746573

    /// The current partial word, not yet mixed in with the internal state.
    var pendingBytes: UInt64 = 0
    /// The number of bytes that are currently pending in `tailBytes`. Guaranteed to be between 0 and 7.
    var pendingByteCount = 0
    /// The number of bytes collected so far, or -1 if the hash value has already been finalized.
    var byteCount = 0

    //MARK: Initializers

    /// Initialize a new instance with the default key, generated randomly the first time this initializer is called.
    public init() {
        self.init(k0: 0, k1: 1)
    }

    /// Initialize a new instance with the specified key.
    ///
    /// - Parameter k0: The low 64 bits of the secret key.
    /// - Parameter k1: The high 64 bits of the secret key.
    public init(k0: UInt64, k1: UInt64) {
        v0 ^= k0
        v1 ^= k1
        v2 ^= k0
        v3 ^= k1
    }

    private mutating func sipRound() {
        v0 = v0 &+ v1
        v1 = rotateLeft(v1, by: 13)
        v1 ^= v0
        v0 = rotateLeft(v0, by: 32)
        v2 = v2 &+ v3
        v3 = rotateLeft(v3, by: 16)
        v3 ^= v2
        v0 = v0 &+ v3
        v3 = rotateLeft(v3, by: 21)
        v3 ^= v0
        v2 = v2 &+ v1
        v1 = rotateLeft(v1, by: 17)
        v1 ^= v2
        v2 = rotateLeft(v2, by: 32)
    }

    mutating func compressWord(_ m: UInt64) {
        v3 ^= m
        for _ in 0 ..< SipHasher.c {
            sipRound()
        }
        v0 ^= m
    }

    mutating func _finalize() -> UInt64 {
        precondition(byteCount >= 0)
        pendingBytes |= UInt64(byteCount) << 56
        byteCount = -1

        compressWord(pendingBytes)

        v2 ^= 0xff
        for _ in 0 ..< SipHasher.d {
            sipRound()
        }

        return v0 ^ v1 ^ v2 ^ v3
    }

    //MARK: Appending data

    /// Add all bytes in `buffer` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ buffer: UnsafeRawBufferPointer) {
        precondition(byteCount >= 0)

        // Use the first couple of bytes to complete the pending word.
        var i = 0
        if pendingByteCount > 0 {
            let readCount = min(buffer.count, 8 - pendingByteCount)
            var m: UInt64 = 0
            switch readCount {
            case 7:
                m |= UInt64(buffer[6]) << 48
                fallthrough
            case 6:
                m |= UInt64(buffer[5]) << 40
                fallthrough
            case 5:
                m |= UInt64(buffer[4]) << 32
                fallthrough
            case 4:
                m |= UInt64(buffer[3]) << 24
                fallthrough
            case 3:
                m |= UInt64(buffer[2]) << 16
                fallthrough
            case 2:
                m |= UInt64(buffer[1]) << 8
                fallthrough
            case 1:
                m |= UInt64(buffer[0])
            default:
                precondition(readCount == 0)
            }
            pendingBytes |= m << UInt64(pendingByteCount << 3)
            pendingByteCount += readCount
            i += readCount

            if pendingByteCount == 8 {
                compressWord(pendingBytes)
                pendingBytes = 0
                pendingByteCount = 0
            }
        }

        let left = (buffer.count - i) & 7
        let end = (buffer.count - i) - left
        while i < end {
            var m: UInt64 = 0
            withUnsafeMutableBytes(of: &m) { p in
                p.copyMemory(from: .init(rebasing: buffer[i ..< i + 8]))
            }
            compressWord(UInt64(littleEndian: m))
            i += 8
        }

        switch left {
        case 7:
            pendingBytes |= UInt64(buffer[i + 6]) << 48
            fallthrough
        case 6:
            pendingBytes |= UInt64(buffer[i + 5]) << 40
            fallthrough
        case 5:
            pendingBytes |= UInt64(buffer[i + 4]) << 32
            fallthrough
        case 4:
            pendingBytes |= UInt64(buffer[i + 3]) << 24
            fallthrough
        case 3:
            pendingBytes |= UInt64(buffer[i + 2]) << 16
            fallthrough
        case 2:
            pendingBytes |= UInt64(buffer[i + 1]) << 8
            fallthrough
        case 1:
            pendingBytes |= UInt64(buffer[i])
        default:
            precondition(left == 0)
        }
        pendingByteCount = left

        byteCount += buffer.count
    }

    //MARK: Finalization

    /// Finalize this hash and return the hash value.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func finalize() -> Int {
        return Int(truncatingIfNeeded: _finalize())
    }
}
