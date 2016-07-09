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
require "dlms_trouble/dtype_decode"

class TestDTypeDecode < Test::Unit::TestCase

    include DLMSTrouble

    def test_from_axdr

        assert_equal(DNullData.new, DTypeDecode.from_axdr("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(DDontCare.new, DTypeDecode.from_axdr("\xFF".force_encoding("ASCII-8BIT")))

        assert_equal(DEnum.new(42), DTypeDecode.from_axdr("\x16\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(DBCD.new(42), DTypeDecode.from_axdr("\x0D\x2A".force_encoding("ASCII-8BIT")))
        
        assert_equal(DBoolean.new(false), DTypeDecode.from_axdr("\x03\x00".force_encoding("ASCII-8BIT")))
        assert_equal(DBoolean.new(true), DTypeDecode.from_axdr("\x03\x01".force_encoding("ASCII-8BIT")))
        assert_equal(DBoolean.new(true), DTypeDecode.from_axdr("\x03\x1f".force_encoding("ASCII-8BIT")))

        assert_equal(DInteger.new(-42), DTypeDecode.from_axdr("\x0f\xD6".force_encoding("ASCII-8BIT")))
        assert_equal(DLong.new(-42), DTypeDecode.from_axdr("\x10\xFF\xD6".force_encoding("ASCII-8BIT")))
        assert_equal(DDoubleLong.new(-42), DTypeDecode.from_axdr("\x05\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT")))
        assert_equal(DLong64.new(-42), DTypeDecode.from_axdr("\x14\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT")))

        assert_equal(DUnsigned.new(42), DTypeDecode.from_axdr("\x11\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(DLongUnsigned.new(42), DTypeDecode.from_axdr("\x12\x00\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(DDoubleLongUnsigned.new(42), DTypeDecode.from_axdr("\x06\x00\x00\x00\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(DLong64Unsigned.new(42), DTypeDecode.from_axdr("\x15\x00\x00\x00\x00\x00\x00\x00\x2A".force_encoding("ASCII-8BIT")))

        assert_equal(DFloatingPoint.new(42.1), DTypeDecode.from_axdr("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(DFloat32.new(42.1), DTypeDecode.from_axdr("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(DFloat64.new(42.1), DTypeDecode.from_axdr("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD".force_encoding("ASCII-8BIT")))

        assert_equal(DOctetString.new("hello world"), DTypeDecode.from_axdr("\x09\x0bhello world"))
        assert_equal(DVisibleString.new("hello world"), DTypeDecode.from_axdr("\x0a\x0bhello world"))

        assert_equal(DArray.new(
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42)                
            ),
            DTypeDecode.from_axdr("\x01\x06\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a".force_encoding("ASCII-8BIT"))             
        )

        assert_equal(
            DCompactArray.new(
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42)                
            ),
            DTypeDecode.from_axdr("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a".force_encoding("ASCII-8BIT"))
        )
        
        assert_equal(
            DStructure.new(
                DNullData.new,
                DBoolean.new(false),
                DOctetString.new("hello"),
                DStructure.new(
                    DNullData.new,
                    DBoolean.new(false),
                    DOctetString.new("hello"),
                )
            ),
            DTypeDecode.from_axdr("\x02\x04\x00\x03\x00\x09\x05hello\x02\x03\x00\x03\x00\x09\x05hello".force_encoding("ASCII-8BIT"))

        )

    end


end
