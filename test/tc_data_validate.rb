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
require "dlms_trouble/data_validate"

class TestDataValidate < Test::Unit::TestCase

    include DLMSTrouble

    def test_init_noSchema

        assert_raise do
            DSLOps.new
        end
        
    end

    def test_validate_null

        dsl = DataDSL.nullData
        data = DNullData.new
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_validate_enum

        dsl = DataDSL.enum
        data = DEnum.new(42)
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_validate_octetString

        dsl = DataDSL.octetString
        data = DOctetString.new("hello")        
        assert_true(DataValidate.validate(data, dsl))

    end

    def test_validate_octetString_size

        dsl = DataDSL.octetString(size: 5)
        
        # test the boundary
        assert_raise DataValidateError do
            data = DOctetString.new("hello ")
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_validate_octetString_sizeRange

        dsl = DataDSL.octetString(size: 5)
        
        # test the maximum boundary
        assert_raise DataValidateError do
            data = DOctetString.new("hello ")
            assert_true(DataValidate.validate(data, dsl))
        end

        # test the minimum boundary
        assert_raise DataValidateError do
            data = DOctetString.new("")
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_validate_array

        dsl = DataDSL.array do
            integer
        end
        data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5))

        assert_true(DataValidate.validate(data, dsl))

    end

    def test_validate_array_size

        dsl = DataDSL.array(size: 5) do
            integer
        end

        # test the maximum boundary
        assert_raise DataValidateError do
            data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5),DInteger.new(6))
            assert_true(DataValidate.validate(data, dsl))
        end

    end
    
    def test_validate_array_sizeRange
        
        dsl = DataDSL.array(size: 1..6) do
            integer
        end
        
        # test the maximum boundary
        assert_raise DataValidateError do
            data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5),DInteger.new(6))
            assert_true(DataValidate.validate(data, dsl))
        end

        # test the minimum boundary
        assert_raise DataValidateError do
            data = DArray.new
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_to_data_nullData
        dsl = DataDSL.nullData
        input = nil        
        assert_equal(DNullData.new, DataValidate.to_data(input, dsl))
    end

    # note this converts from the Ruby definition of boolean (i.e. everything is true, nil or FalseClass is false)
    def test_to_data_boolean
        dsl = DataDSL.boolean
        assert_equal(DBoolean.new(true), DataValidate.to_data(true, dsl))
        assert_equal(DBoolean.new(false), DataValidate.to_data(false, dsl))
    end

    def test_to_data_enum
        dsl = DataDSL.enum
        assert_equal(DEnum.new(42), DataValidate.to_data(42, dsl))

        assert_raise DataValidateError do
            DataValidate.to_data(-1, dsl)            
        end
        assert_raise DataValidateError do
            DataValidate.to_data(0x100, dsl)
        end
    end

    def test_to_data_octetString
        dsl = DataDSL.octetString
        assert_equal(DOctetString.new("hello"), DataValidate.to_data("hello", dsl))
    end

    def test_do_data_octetString_sizeRange
        dsl = DataDSL.octetString(size: 1..5)
        assert_raise DataValidateError do
            DataValidate.to_data("", dsl)
        end
        assert_raise DataValidateError do
            DataValidate.to_data("hello ", dsl)
        end
    end

    def test_to_data_visibleString
        dsl = DataDSL.octetString
        assert_equal(DVisibleString.new("hello"), DataValidate.to_data("hello", dsl))
    end

    def test_to_data_structure

        dsl = DataDSL.structure do
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
            
        assert_equal(expected, DataValidate.to_data(input, dsl))

    end

    def test_to_data_array

        dsl = DataDSL.array do
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
    
        assert_equal(expected, DataValidate.to_data(input, dsl))

    end
    
end
