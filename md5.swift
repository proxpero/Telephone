// An implementation of md5.
extension Collection where Iterator.Element == UInt8 {

    /// Returns the md5 hash of self.
    public var md5: String {
        return self.md5Digest.lazy.reduce("") {
            var s = String($1, radix: 16)
            if s.characters.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }

    // For reference:
    // https://tools.ietf.org/html/rfc1321
    // https://en.wikipedia.org/wiki/MD5#Pseudocode
    private var md5Digest: [UInt8] {

        typealias Word = UInt32
        typealias Byte = UInt8

        // s specifies the per-round shift amounts
        let s: [Word] = [
            7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
            5, 09, 14, 20, 5, 09, 14, 20, 5, 09, 14, 20, 5, 09, 14, 20,
            4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
            6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
        ]

        // K[i] = abs(sin(i + 1)) * 232 (radians)
        let k: [Word] = [
            0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
            0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
            0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
            0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
            0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
            0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
            0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
            0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
            0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
            0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
            0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
            0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
            0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
            0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
            0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
            0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
        ]

        // Initialize variables
        var a: Word = 0x67452301
        var b: Word = 0xefcdab89
        var c: Word = 0x98badcfe
        var d: Word = 0x10325476
        var message = Array(self)

        // The length of the message before the padding bits were added.
        let length = UInt64(message.count * 8)

        /*
         from RFC 1321:
         Padding is performed as follows: a single "1" bit is appended to the
         message, and then "0" bits are appended so that the length in bits of
         the padded message becomes congruent to 448, modulo 512. In all, at
         least one bit and at most 512 bits are appended.
         */

        // Pre-processing: adding a single 1 bit
        message.append(0x80)

        // append "0" bit until message length in bits ≡ 448 (mod 512)
        repeat {
            message.append(0x0)
        } while (message.count * 8) % 512 != 448

        // A 64-bit representation of b (the length of the message before the
        // padding bits were added) is appended to the result of the previous
        // step.
        for i in (0...7).map({ UInt64($0 * 8) }) {
            message.append(Byte((length >> i) & 0xFF))
        }

        // Divide message into successive 512-bit (64-byte) chunks
        let chunks = (0..<(message.count / 64))
            .map { $0 * 64 }
            .map { Array(message[$0..<$0+64]) }

        // Process each chunk:
        for chunk in chunks {

            // Break chunk into sixteen 32-bit words m[i], 0 ≤ i ≤ 15
            func part(_ index: Int, _ offset: Int, _ shift: Word) -> Word {
                return Word(chunk[4 * index + offset]) << shift
            }
            var m = (0...15).map { idx in
                part(idx, 0, 0) | part(idx, 1, 8) | part(idx, 2, 16) | part(idx, 3, 24)
            }

            // Initialize hash value for this chunk:
            var A = a
            var B = b
            var C = c
            var D = d

            //Main loop:
            for index in k.indices {

                var f: Word = 0
                var g = 0

                switch index {
                case 0...15:
                    f = (B & C) | ((~B) & D)
                    g = index
                case 16...31:
                    f = (B & D) | (C & (~D))
                    g = ((5*index + 1) % 16)
                case 32...47:
                    f = B ^ C ^ D
                    g = ((3*index + 5) % 16)
                case 48...63:
                    f = C ^ (B | (~D))
                    g = ((7*index) % 16)
                default:
                    break
                }

                func rotateLeft(_ word: Word, by amount: Word) -> Word {
                    return ((word << amount) & 0xFFFFFFFF) | (word >> (32 - amount))
                }

                let dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft(A &+ f &+ k[index] &+ m[g], by: s[index])
                A = dTemp
            }

            // Add this chunk's hash to result so far:
            a = a &+ A
            b = b &+ B
            c = c &+ C
            d = d &+ D
        }

        // a append b append c append d
        let result = [a, b, c, d].flatMap { word in
            [Word]([00, 08, 16, 24]).map { Byte((word >> $0) & 0xFF) }
        }

        return result
    }
}

extension String {
    /// Returns the md5 hash of self.
    public var md5: String {
        return self.utf8.md5
    }
}
