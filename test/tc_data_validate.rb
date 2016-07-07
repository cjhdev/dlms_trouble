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
        data = Data::DNullData.new
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_evaluate_enum

        dsl = DataDSL.enum("test")
        data = Data::DEnum.new(42)
        assert_true(DataValidate.validate(data, dsl))
        
    end

    def test_evaluate_octetString

        dsl = DataDSL.octetString("test")
        data = Data::DOctetString.new("hello")        
        assert_true(DataValidate.validate(data, dsl))

    end

    def test_evaluate_octetString_size

        dsl = DataDSL.octetString("test", size: 5)
        
        # test the boundary
        assert_raise DataValidateError do
            data = Data::DOctetString.new("hello ")
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_evaluate_octetString_sizeRange

        dsl = DataDSL.octetString("test", size: 5)
        
        # test the maximum boundary
        assert_raise DataValidateError do
            data = Data::DOctetString.new("hello ")
            assert_true(DataValidate.validate(data, dsl))
        end

        # test the minimum boundary
        assert_raise DataValidateError do
            data = Data::DOctetString.new("")
            assert_true(DataValidate.validate(data, dsl))
        end

    end

    def test_evaluate_array

        dsl = DataDSL.array("test") do
            integer("repeatingItem")
        end
        data = Data::DArray.new(Data::DInteger.new(0),Data::DInteger.new(1),Data::DInteger.new(2),Data::DInteger.new(3),Data::DInteger.new(4),Data::DInteger.new(5))

        assert_true(DataValidate.validate(data, dsl))

    end

    def test_evaluate_array_size

        dsl = DataDSL.array("test", size: 5) do
            integer("repeatingItem")
        end

        # test the maximum boundary
        assert_raise DataValidateError do
            data = Data::DArray.new(Data::DInteger.new(0),Data::DInteger.new(1),Data::DInteger.new(2),Data::DInteger.new(3),Data::DInteger.new(4),Data::DInteger.new(5),Data::DInteger.new(6))
            assert_true(DataValidate.validate(data, dsl))
        end

    end
    
    def test_evaluate_array_sizeRange
        
        dsl = DataDSL.array("test", size: 1..6) do
            integer("repeatingItem")
        end
        
        # test the maximum boundary
        assert_raise DataValidateError do
            data = Data::DArray.new(Data::DInteger.new(0),Data::DInteger.new(1),Data::DInteger.new(2),Data::DInteger.new(3),Data::DInteger.new(4),Data::DInteger.new(5),Data::DInteger.new(6))
            assert_true(DataValidate.validate(data, dsl))
        end

        # test the minimum boundary
        assert_raise DataValidateError do
            data = Data::DArray.new
            assert_true(DataValidate.validate(data, dsl))
        end

    end
    
end
