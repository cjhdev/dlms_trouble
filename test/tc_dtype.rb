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
require "dlms_trouble/dtype"

class TestDtype < Test::Unit::TestCase

    include DLMSTrouble

    def test_from_axdr_bcd
        assert_equal(DType::BCD.new(42), DType.from_axdr(StringIO.new("\x0D\x2A")))        
    end

    def test_from_axdr_array

        assert_equal(DType::Array.new(
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42)                
            ),
            DType.from_axdr(StringIO.new("\x01\x06\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a\x0f\x2a"))             
        )
        
    end

    def test_from_axdr_bitstring

        assert_equal(DType::BitString.new(false,true,false,true,false,true,false,true), DType.from_axdr(StringIO.new("\x04\x08\x55")))
        assert_equal(DType::BitString.new(false,true,false,true,false,true,false), DType.from_axdr(StringIO.new("\x04\x07\x54")))
        assert_equal(DType::BitString.new(false,false,false,false,false,false,false,false), DType.from_axdr(StringIO.new("\x04\x08\x00")))
        assert_equal(DType::BitString.new(true,true,true,true,true,true,true,true,false), DType.from_axdr(StringIO.new("\x04\x09\xff\x00")))

        assert_raise DType::DTypeError do

            assert_equal(DType::BitString.new(false,true,false,true,false,true,false), DType.from_axdr(StringIO.new("\x04\x07\x55")))

        end

    end

    def test_from_axdr_boolean

        assert_equal(DType::Boolean.new(false), DType.from_axdr(StringIO.new("\x03\x00")))
        assert_equal(DType::Boolean.new(true), DType.from_axdr(StringIO.new("\x03\x01")))
        assert_equal(DType::Boolean.new(true), DType.from_axdr(StringIO.new("\x03\x1f")))

    end

    def test_from_axdr_compact_array

        assert_equal(
            DType::CompactArray.new(
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42),
                DType::Integer.new(42)                
            ),
            DType.from_axdr(StringIO.new("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a"))
        )

        assert_equal(
            DType::CompactArray.new(
                DType::Structure.new(
                    DType::Array.new(
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42)
                    ),
                    DType::OctetString.new("hello world")
                ),
                DType::Structure.new(
                    DType::Array.new(
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42)
                    ),
                    DType::OctetString.new("hello world")
                ),
                DType::Structure.new(
                    DType::Array.new(
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42),
                        DType::Integer.new(42)
                    ),
                    DType::OctetString.new("")
                )
            ),
            DType.from_axdr(StringIO.new("\x13\x02\x02\x01\x00\x06\x0F\x09\x2B\x2a\x2a\x2a\x2a\x2a\x2a\x0bhello world\x2a\x2a\x2a\x2a\x2a\x2a\x0bhello world\x2a\x2a\x2a\x2a\x2a\x2a\x00"))
        )

    end

    def test_from_axdr_visible_string

        assert_equal(DType::VisibleString.new("hello world"), DType.from_axdr(StringIO.new("\x0a\x0bhello world")))

    end

    def test_from_axdr_dont_care

        assert_equal(DType::DontCare.new, DType::DontCare.from_axdr(StringIO.new("\xff")))
        
    end

    def test_from_axdr_double_long

        assert_equal(DType::DoubleLong.new(-42), DType.from_axdr(StringIO.new("\x05\xFF\xFF\xFF\xD6")))

    end

    def test_from_axdr_double_long_unsigned

        assert_equal(DType::DoubleLongUnsigned.new(42), DType.from_axdr(StringIO.new("\x06\x00\x00\x00\x2A")))

    end

    def test_from_axdr_enum

        assert_equal(DType::Enum.new(42), DType.from_axdr(StringIO.new("\x16\x2A")))

    end

    def test_from_axdr_float32

        assert_equal(DType::Float32.new(42.1), DType.from_axdr(StringIO.new("\x17\x42\x28\x66\x66")))

    end

    def test_from_axdr_float64

        assert_equal(DType::Float64.new(42.1), DType.from_axdr(StringIO.new("\x18\x40\x45\x0C\xCC\xCC\xCC\xCC\xCD")))

    end

    def test_from_axdr_integer

        assert_equal(DType::Integer.new(-42), DType.from_axdr(StringIO.new("\x0f\xD6")))

    end

    def test_from_axdr_floating_point

        assert_equal(DType::FloatingPoint.new(42.1), DType.from_axdr(StringIO.new("\x07\x42\x28\x66\x66")))

    end

    def test_from_axdr_long

        assert_equal(DType::Long.new(-42), DType.from_axdr(StringIO.new("\x10\xFF\xD6")))

    end

    def test_from_axdr_long64

        assert_equal(DType::Long64.new(-42), DType.from_axdr(StringIO.new("\x14\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xD6")))

    end

    def test_from_axdr_long64_unsigned

        assert_equal(DType::Long64Unsigned.new(42), DType.from_axdr(StringIO.new("\x15\x00\x00\x00\x00\x00\x00\x00\x2A")))

    end

    def test_from_axdr_long_unsigned

        assert_equal(DType::LongUnsigned.new(42), DType.from_axdr(StringIO.new("\x12\x00\x2A")))

    end

    def test_from_axdr_nullData

        assert_equal(DType::NullData.new, DType.from_axdr(StringIO.new("\x00")))
        
    end

    def test_from_axdr_octetstring

        assert_equal(DType::OctetString.new("hello world"), DType.from_axdr(StringIO.new("\x09\x0bhello world")))

    end

    def test_from_axdr_octetstring_zero

        assert_equal(DType::OctetString.new(""), DType.from_axdr(StringIO.new("\x09\x00")))

    end

    def test_from_axdr_structure

        assert_equal(
            DType::Structure.new(
                DType::NullData.new,
                DType::Boolean.new(false),
                DType::OctetString.new("hello"),
                DType::Structure.new(
                    DType::NullData.new,
                    DType::Boolean.new(false),
                    DType::OctetString.new("hello"),
                )
            ),
            DType.from_axdr(StringIO.new("\x02\x04\x00\x03\x00\x09\x05hello\x02\x03\x00\x03\x00\x09\x05hello"))
        )

    end

    def test_from_axdr_unsigned

        assert_equal(DType::Unsigned.new(42), DType.from_axdr(StringIO.new("\x11\x2A")))

    end

    def test_from_axdr_utf8

        assert_equal(DType::UTF8String.new("hello world"), DType.from_axdr(StringIO.new("\x0c\x0bhello world")))

    end
    
end
