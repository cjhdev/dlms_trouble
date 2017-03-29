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
require "dlms_trouble/dtype_validate"

class TestDTypeValidate < Test::Unit::TestCase

    include DLMSTrouble

    def test_validate_null

        dsl = DTypeSchema.nullData
        data = DType::NullData.new
        assert_equal(true,DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_enum

        dsl = DTypeSchema.enum
        data = DType::Enum.new(42)
        assert_equal(true,DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_octetString

        dsl = DTypeSchema.octetString
        data = DType::OctetString.new("hello")        
        assert_equal(true,DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_octetString_size

        dsl = DTypeSchema.octetString(size: 5)
        
        # test the boundary        
        data = DType::OctetString.new("hello ")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_octetString_sizeRange

        dsl = DTypeSchema.octetString(size: 5)
        
        # test the maximum boundary
        data = DType::OctetString.new("hello ")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
        # test the minimum boundary
        data = DType::OctetString.new("")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_array

        dsl = DTypeSchema.array do
            integer
        end
        data = DType::Array.new(DType::Integer.new(0),DType::Integer.new(1),DType::Integer.new(2),DType::Integer.new(3),DType::Integer.new(4),DType::Integer.new(5))

        assert_equal(true, DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_array_size

        dsl = DTypeSchema.array(size: 5) do
            integer
        end

        # test boundary
        data = DType::Array.new(DType::Integer.new(0),DType::Integer.new(1),DType::Integer.new(2),DType::Integer.new(3),DType::Integer.new(4),DType::Integer.new(5),DType::Integer.new(6))
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
    end
    
    def test_validate_array_sizeRange
        
        dsl = DTypeSchema.array(size: 1..6) do
            integer
        end
        
        # test the maximum boundary        
        data = DType::Array.new(DType::Integer.new(0),DType::Integer.new(1),DType::Integer.new(2),DType::Integer.new(3),DType::Integer.new(4),DType::Integer.new(5),DType::Integer.new(6))
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
        # test the minimum boundary
        data = DType::Array.new
        assert_equal(false, DTypeValidate.new(dsl).validate(data))

    end

    def test_to_data_nullData
        dsl = DTypeSchema.nullData
        input = nil        
        assert_equal(DType::NullData.new, DTypeValidate.new(dsl).to_data(input))
    end

    # note this converts from the Ruby definition of boolean (i.e. everything is true, nil or FalseClass is false)
    def test_to_data_boolean
        dsl = DTypeSchema.boolean
        assert_equal(DType::Boolean.new(true), DTypeValidate.new(dsl).to_data(true))
        assert_equal(DType::Boolean.new(false), DTypeValidate.new(dsl).to_data(false))
    end

    def test_to_data_enum
        dsl = DTypeSchema.enum
        assert_equal(DType::Enum.new(42), DTypeValidate.new(dsl).to_data(42))

        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data(-1)            
        end
        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data(0x100)
        end
    end

    def test_to_data_octetString
        dsl = DTypeSchema.octetString
        assert_equal(DType::OctetString.new("hello"), DTypeValidate.new(dsl).to_data("hello"))
    end

    def test_do_data_octetString_sizeRange
        dsl = DTypeSchema.octetString(size: 1..5)
        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data("")
        end
        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data("hello ")
        end
    end

    def test_to_data_visibleString
        dsl = DTypeSchema.octetString
        assert_equal(DType::VisibleString.new("hello"), DTypeValidate.new(dsl).to_data("hello"))
    end

    def test_to_data_structure

        dsl = DTypeSchema.structure do
            nullData
            integer
            structure do
                octetString
            end
        end

        input = [
            nil,
            42,
            [
                "hello"
            ]
        ]

        expected = DType::Structure.new(
            DType::NullData.new,
            DType::Integer.new(42),
            DType::Structure.new(
                DType::OctetString.new("hello")
            )
        )
            
        assert_equal(expected, DTypeValidate.new(dsl).to_data(input))

    end

    def test_to_data_array

        dsl = DTypeSchema.array do
            structure do
                nullData
                integer
                structure do
                    octetString
                end
            end
        end

        input = [        
            [
                nil,
                42,
                [
                    "hello"
                ]
            ],
            [
                nil,
                42,
                [
                    "hello"
                ]
            ],
            [
                nil,
                42,
                [
                    "hello"
                ]
            ]
        ]
         
        expected = DType::Array.new(
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            ),
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            ),
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            )
        )
    
        assert_equal(expected, DTypeValidate.new(dsl).to_data(input))

    end

    def test_to_data_compactArray

        dsl = DTypeSchema.compactArray do
            structure do
                nullData
                integer
                structure do
                    octetString
                end
            end
        end

        input = [        
            [
                nil,
                42,
                [
                    "hello"
                ]
            ],
            [
                nil,
                42,
                [
                    "hello"
                ]
            ],
            [
                nil,
                42,
                [
                    "hello"
                ]
            ]
        ]
         
        expected = DType::CompactArray.new(
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            ),
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            ),
            DType::Structure.new(
                DType::NullData.new,
                DType::Integer.new(42),
                DType::Structure.new(
                    DType::OctetString.new("hello")
                )
            )
        )
    
        assert_equal(expected, DTypeValidate.new(dsl).to_data(input))
    
    end
    
end
