# Copyright (c) 2016 Cameron Harper
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "test/unit"
require "dlms_trouble/axdr"

class TestAXDR < Test::Unit::TestCase

    include DLMSTrouble

    def test_sizeSize

        assert_equal(1, AXDR::sizeSize(0))
        assert_equal(1, AXDR::sizeSize(0x7f))
        assert_equal(2, AXDR::sizeSize(0x80))
        assert_equal(2, AXDR::sizeSize(0xff))
        assert_equal(3, AXDR::sizeSize(0x100))
        assert_equal(4, AXDR::sizeSize(0x10000))
        assert_equal(5, AXDR::sizeSize(0x1000000))
        assert_equal(6, AXDR::sizeSize(0x100000000))
        
    end

    def test_putSize

        assert_equal("\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0))
        assert_equal("\x7F".force_encoding("ASCII-8BIT"), AXDR::putSize(0x7f))
        assert_equal("\x81\x80".force_encoding("ASCII-8BIT"),AXDR::putSize(0x80))
        assert_equal("\x81\xff".force_encoding("ASCII-8BIT"), AXDR::putSize(0xff))
        assert_equal("\x82\x01\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x100))
        assert_equal("\x83\x01\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x10000))
        assert_equal("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x1000000))
        assert_equal("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x100000000))
        assert_equal("\x86\x01\x00\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x10000000000))

    end

    def test_getSize!

        assert_equal(0, AXDR::getSize!("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x7f, AXDR::getSize!("\x7f".force_encoding("ASCII-8BIT")))
        assert_equal(0x80, AXDR::getSize!("\x81\x80".force_encoding("ASCII-8BIT")))
        assert_equal(0xff, AXDR::getSize!("\x81\xff".force_encoding("ASCII-8BIT")))
        assert_equal(0x100, AXDR::getSize!("\x82\x01\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x10000, AXDR::getSize!("\x83\x01\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x1000000, AXDR::getSize!("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x100000000, AXDR::getSize!("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT")))

        assert_raise(AXDR::EncodingError) do
            AXDR::getSize!("\x80".force_encoding("ASCII-8BIT"))
        end
    end

    def test_to_axdr

        assert_equal("\x00".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DNullData.new))

        # technically an array should be the same type repeating
        assert_equal("\x01\x04\x00\x03\x00\x09\x05hello\x01\x03\x00\x03\x00\x09\x05hello".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(
            AXDR::DArray.new([
                AXDR::DNullData.new,
                AXDR::DBoolean.new(false),
                AXDR::DOctetString.new("hello"),
                AXDR::DArray.new([
                    AXDR::DNullData.new,
                    AXDR::DBoolean.new(false),
                    AXDR::DOctetString.new("hello"),
                ])
            ])        
        ))

         assert_equal("\x02\x04\x00\x03\x00\x09\x05hello\x02\x03\x00\x03\x00\x09\x05hello".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(
            AXDR::DStructure.new([
                AXDR::DNullData.new,
                AXDR::DBoolean.new(false),
                AXDR::DOctetString.new("hello"),
                AXDR::DStructure.new([
                    AXDR::DNullData.new,
                    AXDR::DBoolean.new(false),
                    AXDR::DOctetString.new("hello"),
                ])
            ])        
        ))

        assert_equal("\x03\x00".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DBoolean.new(false)))
        assert_equal("\x03\x01".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DBoolean.new(true)))

        assert_equal("\x05\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DDoubleLong.new(-42)))
        assert_equal("\x06\x00\x00\x00\x2A".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DDoubleLongUnsigned.new(42)))
        assert_equal("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DFloatingPoint.new(42.1)))

        assert_equal("\x09\x05hello".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DOctetString.new("hello")))
        assert_equal("\x0a\x05world".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DVisibleString.new("world")))

        assert_equal("\x0f\xD6".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DInteger.new(-42)))
        assert_equal("\x10\xFF\xD6".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DLong.new(-42)))
        assert_equal("\x11\x2A".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DUnsigned.new(42)))
        assert_equal("\x12\x00\x2A".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DLongUnsigned.new(42)))

        assert_equal("\x14\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DLong64.new(-42)))
        assert_equal("\x15\x00\x00\x00\x00\x00\x00\x00\x2A".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DLong64Unsigned.new(42)))
        assert_equal("\x16\x2A".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DEnum.new(42)))
        assert_equal("\x17\x42\x28\x66\x66".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DFloat32.new(42.1)))
        assert_equal("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD".force_encoding("ASCII-8BIT"), AXDR::DType.to_axdr(AXDR::DFloat64.new(42.1)))

    end

    def test_from_axdr!

        assert_equal(AXDR::DNullData.new, AXDR::DType.from_axdr!("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DBoolean.new(false), AXDR::DType.from_axdr!("\x03\x00".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DBoolean.new(true), AXDR::DType.from_axdr!("\x03\x01".force_encoding("ASCII-8BIT")))

        assert_equal(AXDR::DDoubleLong.new(-42), AXDR::DType.from_axdr!("\x05\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DDoubleLongUnsigned.new(42), AXDR::DType.from_axdr!("\x06\x00\x00\x00\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DFloatingPoint.new(42.1), AXDR::DType.from_axdr!("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DFloat32.new(42.1), AXDR::DType.from_axdr!("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(AXDR::DFloat64.new(42.1), AXDR::DType.from_axdr!("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD".force_encoding("ASCII-8BIT")))

    end

end
