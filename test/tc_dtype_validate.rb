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
        data = DNullData.new
        assert_equal(true,DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_enum

        dsl = DTypeSchema.enum
        data = DEnum.new(42)
        assert_equal(true,DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_octetString

        dsl = DTypeSchema.octetString
        data = DOctetString.new("hello")        
        assert_equal(true,DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_octetString_size

        dsl = DTypeSchema.octetString(size: 5)
        
        # test the boundary        
        data = DOctetString.new("hello ")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
    end

    def test_validate_octetString_sizeRange

        dsl = DTypeSchema.octetString(size: 5)
        
        # test the maximum boundary
        data = DOctetString.new("hello ")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
        # test the minimum boundary
        data = DOctetString.new("")
        assert_equal(false, DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_array

        dsl = DTypeSchema.array do
            integer
        end
        data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5))

        assert_equal(true, DTypeValidate.new(dsl).validate(data))

    end

    def test_validate_array_size

        dsl = DTypeSchema.array(size: 5) do
            integer
        end

        # test boundary
        data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5),DInteger.new(6))
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
    end
    
    def test_validate_array_sizeRange
        
        dsl = DTypeSchema.array(size: 1..6) do
            integer
        end
        
        # test the maximum boundary        
        data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5),DInteger.new(6))
        assert_equal(false, DTypeValidate.new(dsl).validate(data))
        
        # test the minimum boundary
        data = DArray.new
        assert_equal(false, DTypeValidate.new(dsl).validate(data))

    end

    def test_to_data_nullData
        dsl = DTypeSchema.nullData
        input = nil        
        assert_equal(DNullData.new, DTypeValidate.new(dsl).to_data(input))
    end

    # note this converts from the Ruby definition of boolean (i.e. everything is true, nil or FalseClass is false)
    def test_to_data_boolean
        dsl = DTypeSchema.boolean
        assert_equal(DBoolean.new(true), DTypeValidate.new(dsl).to_data(true))
        assert_equal(DBoolean.new(false), DTypeValidate.new(dsl).to_data(false))
    end

    def test_to_data_enum
        dsl = DTypeSchema.enum
        assert_equal(DEnum.new(42), DTypeValidate.new(dsl).to_data(42))

        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data(-1)            
        end
        assert_raise DTypeValidateError do
            DTypeValidate.new(dsl).to_data(0x100)
        end
    end

    def test_to_data_octetString
        dsl = DTypeSchema.octetString
        assert_equal(DOctetString.new("hello"), DTypeValidate.new(dsl).to_data("hello"))
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
        assert_equal(DVisibleString.new("hello"), DTypeValidate.new(dsl).to_data("hello"))
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

        expected = DStructure.new(
            DNullData.new,
            DInteger.new(42),
            DStructure.new(
                DOctetString.new("hello")
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
         
        expected = DArray.new(
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
                )
            ),
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
                )
            ),
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
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
         
        expected = DCompactArray.new(
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
                )
            ),
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
                )
            ),
            DStructure.new(
                DNullData.new,
                DInteger.new(42),
                DStructure.new(
                    DOctetString.new("hello")
                )
            )
        )
    
        assert_equal(expected, DTypeValidate.new(dsl).to_data(input))
    
    end
    
end
