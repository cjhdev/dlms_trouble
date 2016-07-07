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
require "dlms_trouble/data"

class TestData < Test::Unit::TestCase

    include DLMSTrouble

    def test_sizeSize

        assert_equal(1, Data::sizeSize(0))
        assert_equal(1, Data::sizeSize(0x7f))
        assert_equal(2, Data::sizeSize(0x80))
        assert_equal(2, Data::sizeSize(0xff))
        assert_equal(3, Data::sizeSize(0x100))
        assert_equal(4, Data::sizeSize(0x10000))
        assert_equal(5, Data::sizeSize(0x1000000))
        assert_equal(6, Data::sizeSize(0x100000000))
        
    end

    def test_putSize

        assert_equal("\x00".force_encoding("ASCII-8BIT"), Data::putSize(0))
        assert_equal("\x7F".force_encoding("ASCII-8BIT"), Data::putSize(0x7f))
        assert_equal("\x81\x80".force_encoding("ASCII-8BIT"),Data::putSize(0x80))
        assert_equal("\x81\xff".force_encoding("ASCII-8BIT"), Data::putSize(0xff))
        assert_equal("\x82\x01\x00".force_encoding("ASCII-8BIT"), Data::putSize(0x100))
        assert_equal("\x83\x01\x00\x00".force_encoding("ASCII-8BIT"), Data::putSize(0x10000))
        assert_equal("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT"), Data::putSize(0x1000000))
        assert_equal("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), Data::putSize(0x100000000))
        assert_equal("\x86\x01\x00\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), Data::putSize(0x10000000000))

    end

    def test_getSize!

        assert_equal(0, Data::getSize!("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x7f, Data::getSize!("\x7f".force_encoding("ASCII-8BIT")))
        assert_equal(0x80, Data::getSize!("\x81\x80".force_encoding("ASCII-8BIT")))
        assert_equal(0xff, Data::getSize!("\x81\xff".force_encoding("ASCII-8BIT")))
        assert_equal(0x100, Data::getSize!("\x82\x01\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x10000, Data::getSize!("\x83\x01\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x1000000, Data::getSize!("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x100000000, Data::getSize!("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT")))

        assert_raise(Data::EncodingError) do
            Data::getSize!("\x80".force_encoding("ASCII-8BIT"))
        end
    end

    def test_to_axdr

        assert_equal("\x00".force_encoding("ASCII-8BIT"), Data::DNullData.new.to_axdr)

        assert_equal("\x01\x06\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a".force_encoding("ASCII-8BIT"), 
            Data::DArray.new(
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42)                
            ).to_axdr        
        )

        assert_equal("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a".force_encoding("ASCII-8BIT"), 
            Data::DCompactArray.new(
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42)                
            ).to_axdr        
        )
        
         assert_equal("\x02\x04\x00\x03\x00\x09\x05hello\x02\x03\x00\x03\x00\x09\x05hello".force_encoding("ASCII-8BIT"), 
            Data::DStructure.new(
                Data::DNullData.new,
                Data::DBoolean.new(false),
                Data::DOctetString.new("hello"),
                Data::DStructure.new(
                    Data::DNullData.new,
                    Data::DBoolean.new(false),
                    Data::DOctetString.new("hello"),
                )
            ).to_axdr        
        )

        assert_equal("\x03\x00".force_encoding("ASCII-8BIT"), Data::DBoolean.new(false).to_axdr)
        assert_equal("\x03\x01".force_encoding("ASCII-8BIT"), Data::DBoolean.new(true).to_axdr)

        assert_equal("\x05\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT"), Data::DDoubleLong.new(-42).to_axdr)
        assert_equal("\x06\x00\x00\x00\x2A".force_encoding("ASCII-8BIT"), Data::DDoubleLongUnsigned.new(42).to_axdr)
        assert_equal("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT"), Data::DFloatingPoint.new(42.1).to_axdr)

        assert_equal("\x09\x05hello".force_encoding("ASCII-8BIT"), Data::DOctetString.new("hello").to_axdr)
        assert_equal("\x0a\x05world".force_encoding("ASCII-8BIT"), Data::DVisibleString.new("world").to_axdr)

        assert_equal("\x0f\xD6".force_encoding("ASCII-8BIT"), Data::DInteger.new(-42).to_axdr)
        assert_equal("\x10\xFF\xD6".force_encoding("ASCII-8BIT"), Data::DLong.new(-42).to_axdr)
        assert_equal("\x11\x2A".force_encoding("ASCII-8BIT"), Data::DUnsigned.new(42).to_axdr)
        assert_equal("\x12\x00\x2A".force_encoding("ASCII-8BIT"), Data::DLongUnsigned.new(42).to_axdr)

        assert_equal("\x14\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT"), Data::DLong64.new(-42).to_axdr)
        assert_equal("\x15\x00\x00\x00\x00\x00\x00\x00\x2A".force_encoding("ASCII-8BIT"), Data::DLong64Unsigned.new(42).to_axdr)
        assert_equal("\x16\x2A".force_encoding("ASCII-8BIT"), Data::DEnum.new(42).to_axdr)
        assert_equal("\x17\x42\x28\x66\x66".force_encoding("ASCII-8BIT"), Data::DFloat32.new(42.1).to_axdr)
        assert_equal("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD".force_encoding("ASCII-8BIT"), Data::DFloat64.new(42.1).to_axdr)

        #assert_equal("\x07\xe0\x01\x01\x05\x00\x00\x00\x00\x80\x00\x08",Data::DDateTime.new(Time.new(2016)).to_axdr)

    end

    def test_from_axdr!

        assert_equal(Data::DNullData.new, Data::DType.from_axdr!("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DBoolean.new(false), Data::DType.from_axdr!("\x03\x00".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DBoolean.new(true), Data::DType.from_axdr!("\x03\x01".force_encoding("ASCII-8BIT")))

        assert_equal(Data::DDoubleLong.new(-42), Data::DType.from_axdr!("\x05\xFF\xFF\xFF\xD6".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DDoubleLongUnsigned.new(42), Data::DType.from_axdr!("\x06\x00\x00\x00\x2A".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DFloatingPoint.new(42.1), Data::DType.from_axdr!("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DFloat32.new(42.1), Data::DType.from_axdr!("\x07\x42\x28\x66\x66".force_encoding("ASCII-8BIT")))
        assert_equal(Data::DFloat64.new(42.1), Data::DType.from_axdr!("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD".force_encoding("ASCII-8BIT")))

        assert_equal(Data::DArray.new(
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42)                
            ),
            Data::DType.from_axdr!("\x01\x06\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a".force_encoding("ASCII-8BIT"))             
        )

        assert_equal(
            Data::DCompactArray.new(
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42),
                Data::DInteger.new(42)                
            ),
            Data::DType.from_axdr!("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a".force_encoding("ASCII-8BIT"))
        )
        
        assert_equal(
            Data::DStructure.new(
                Data::DNullData.new,
                Data::DBoolean.new(false),
                Data::DOctetString.new("hello"),
                Data::DStructure.new(
                    Data::DNullData.new,
                    Data::DBoolean.new(false),
                    Data::DOctetString.new("hello"),
                )
            ),
            Data::DType.from_axdr!("\x02\x04\x00\x03\x00\x09\x05hello\x02\x03\x00\x03\x00\x09\x05hello".force_encoding("ASCII-8BIT"))
        )

    end



end
