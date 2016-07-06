require "test/unit"
require "dlms_trouble/dsl"
require "dlms_trouble/axdr"

class TestDSL < Test::Unit::TestCase

    include DLMSTrouble

    def test_evaluate_null
    
        schema = DSL.new do            
            nullData("test")
        end

        schema.evaluate(AXDR::DNullData.new)
        
        assert_raise DSLError do
            schema.evaluate(42)
        end
        
    end

    def test_evaluate_enum
    
        schema = DSL.new do            
            enum("test")
        end

        schema.evaluate(AXDR::DEnum.new(42))

        assert_raise DSLError do
            schema.evaluate(nil)
        end
        
    end

    def test_evaluate_octetString
    
        schema = DSL.new do            
            octetString("test")
        end

        schema.evaluate(AXDR::DOctetString.new("hello"))

        assert_raise DSLError do
            schema.evaluate(42)
        end
        
    end

    def test_evaluate_octetString_size

        schema = DSL.new do            
            octetString("test", size: 5)
        end

        schema.evaluate(AXDR::DOctetString.new("hello"))

        # test the boundary
        assert_raise DSLError do
            schema.evaluate("hello ")
        end

    end

    def test_evaluate_octetString_sizeRange

        schema = DSL.new do            
            octetString("test", size: 1..5)
        end

        schema.evaluate(AXDR::DOctetString.new("hello"))

        # test the maximum boundary
        assert_raise DSLError do
            schema.evaluate("hello ")
        end

        # test the minimum boundary
        assert_raise DSLError do
            schema.evaluate("")
        end

    end

    def test_evaluate_array

        schema = DSL.new do            
            array("test") do
                integer("repeatingItem")
            end
        end

        schema.evaluate(AXDR::DArray.new(AXDR::DInteger.new(0),AXDR::DInteger.new(1),AXDR::DInteger.new(2),AXDR::DInteger.new(3),AXDR::DInteger.new(4),AXDR::DInteger.new(5)))

    end

    def test_evaluate_array_size

        schema = DSL.new do            
            array("test", size: 6) do
                integer("repeatingItem")
            end
        end

        schema.evaluate(AXDR::DArray.new(AXDR::DInteger.new(0),AXDR::DInteger.new(1),AXDR::DInteger.new(2),AXDR::DInteger.new(3),AXDR::DInteger.new(4),AXDR::DInteger.new(5)))
        
        # test the maximum boundary
        assert_raise DSLError do
            schema.evaluate(AXDR::DArray.new(AXDR::DInteger.new(0),AXDR::DInteger.new(1),AXDR::DInteger.new(2),AXDR::DInteger.new(3),AXDR::DInteger.new(4),AXDR::DInteger.new(5),AXDR::DInteger.new(6)))
        end

    end
    
    def test_evaluate_array_sizeRange

        schema = DSL.new do            
            array("test", size: 1..6) do
                integer("repeatingItem")
            end
        end

        schema.evaluate(AXDR::DArray.new(AXDR::DInteger.new(0),AXDR::DInteger.new(1),AXDR::DInteger.new(2),AXDR::DInteger.new(3),AXDR::DInteger.new(4),AXDR::DInteger.new(5)))
        
        # test the maximum boundary
        assert_raise DSLError do
            schema.evaluate(AXDR::DArray.new(AXDR::DInteger.new(0),AXDR::DInteger.new(1),AXDR::DInteger.new(2),AXDR::DInteger.new(3),AXDR::DInteger.new(4),AXDR::DInteger.new(5),AXDR::DInteger.new(6)))
        end

        # test the minimum boundary
        assert_raise DSLError do
            schema.evaluate(AXDR::DArray.new)
        end

    end
    
end
