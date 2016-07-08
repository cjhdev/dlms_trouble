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

        dsl = DataDSL.nullData("test")
        data = DNullData.new
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_evaluate_enum

        dsl = DataDSL.enum("test")
        data = DEnum.new(42)
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_evaluate_octetString

        dsl = DataDSL.octetString("test")
        data = DOctetString.new("hello")        
        assert_true(DataValidate.validate(data, dsl))

    end

    def test_evaluate_octetString_size

        dsl = DataDSL.octetString("test", size: 5)
        
        # test the boundary
        assert_raise DataValidateError do
            data = DOctetString.new("hello ")
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_evaluate_octetString_sizeRange

        dsl = DataDSL.octetString("test", size: 5)
        
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

    def test_evaluate_array

        dsl = DataDSL.array("test") do
            integer("repeatingItem")
        end
        data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5))

        assert_true(DataValidate.validate(data, dsl))

    end

    def test_evaluate_array_size

        dsl = DataDSL.array("test", size: 5) do
            integer("repeatingItem")
        end

        # test the maximum boundary
        assert_raise DataValidateError do
            data = DArray.new(DInteger.new(0),DInteger.new(1),DInteger.new(2),DInteger.new(3),DInteger.new(4),DInteger.new(5),DInteger.new(6))
            assert_true(DataValidate.validate(data, dsl))
        end

    end
    
    def test_evaluate_array_sizeRange
        
        dsl = DataDSL.array("test", size: 1..6) do
            integer("repeatingItem")
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
        dsl = DataDSL.nullData("test")
        input = nil        
        assert_equal(DNullData.new, DataValidate.to_data(input, dsl))
    end

    # note this converts from the Ruby definition of boolean (i.e. everything is true, nil or FalseClass is false)
    def test_to_data_boolean
        dsl = DataDSL.boolean("test")        
        assert_equal(DBoolean.new(true), DataValidate.to_data(true, dsl))
        assert_equal(DBoolean.new(false), DataValidate.to_data(false, dsl))
    end

    def test_to_data_enum
        dsl = DataDSL.enum("test")
        assert_equal(DEnum.new(42), DataValidate.to_data(42, dsl))

        assert_raise DataValidateError do
            DataValidate.to_data(-1, dsl)            
        end
        assert_raise DataValidateError do
            DataValidate.to_data(0x100, dsl)
        end
    end

    def test_to_data_octetString
        dsl = DataDSL.octetString("test")
        assert_equal(DOctetString.new("hello"), DataValidate.to_data("hello", dsl))
    end

    def test_to_data_visibleString
        dsl = DataDSL.octetString("test")
        assert_equal(DVisibleString.new("hello"), DataValidate.to_data("hello", dsl))
    end

    def test_to_data_structure

        dsl = DataDSL.structure("test") do
            nullData("one")
            integer("two")
            structure("three") do
                octetString("four")
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
    
end
