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
require "dlms_trouble/dtype_dsl"

class TestDTypeDSL < Test::Unit::TestCase

    include DLMSTrouble

    def test_init_noSchema                
        assert_equal(nil, DTypeDSL.new.type)        
    end

    def test_init_multipleDefinition
        assert_raise DTypeDSLError do
            DTypeDSL.new do
                nullData("test")
                nullData("testAgain")
            end
        end
        assert_raise DTypeDSLError do
            DTypeDSL.nullData("test").nullData("test")
        end
    end

    def test_init_nullData
        DTypeDSL.new do
            nullData("test")
        end
        DTypeDSL.nullData("test")
    end
    
    def test_init_dontCare
        DTypeDSL.new do
            dontCare("test")
        end
        DTypeDSL.dontCare("test")
    end

    def test_init_bcd
        DTypeDSL.new do
            bcd("test")
        end
        DTypeDSL.bcd("test")
    end

    def test_init_dateTime
        DTypeDSL.new do
            dateTime("test")
        end
        DTypeDSL.dateTime("test")
    end
    def test_init_date
        DTypeDSL.new do
            date("test")
        end
        DTypeDSL.date("test")
    end
    def test_init_time
        DTypeDSL.new do
            time("test")
        end
        DTypeDSL.time("test")
    end

    def test_init_enum
        DTypeDSL.new do
            enum("test")
        end
        DTypeDSL.enum("test")        
    end

    def test_init_boolean
        DTypeDSL.new do
            boolean("test")
        end
        DTypeDSL.boolean("test")
    end

    def test_init_integer
        DTypeDSL.new do
            integer("test")
        end
        DTypeDSL.integer("test")
    end
    def test_init_long
        DTypeDSL.new do
            long("test")
        end
        DTypeDSL.long("test")
    end
    def test_init_doubleLong
        DTypeDSL.new do
            doubleLong("test")
        end
        DTypeDSL.doubleLong("test")
    end
    def test_init_long64
        DTypeDSL.new do
            long64("test")
        end
        DTypeDSL.long64("test")
    end
    
    def test_init_unsigned
        DTypeDSL.new do
            unsigned("test")
        end
        DTypeDSL.unsigned("test")
    end
    def test_init_longUnsigned
        DTypeDSL.new do
            longUnsigned("test")
        end
        DTypeDSL.longUnsigned("test")
    end
    def test_init_doubleLongUnsigned
        DTypeDSL.new do
            doubleLongUnsigned("test")
        end
        DTypeDSL.doubleLongUnsigned("test")
    end    
    def test_init_long64Unsigned
        DTypeDSL.new do
            long64Unsigned("test")
        end
        DTypeDSL.long64Unsigned("test")
    end

    def test_init_visibleString
        DTypeDSL.new do
            visibleString("test")
        end
        DTypeDSL.visibleString("test")
    end
    def test_init_visibleString_size
        DTypeDSL.new do
            visibleString("test", size: 5)
        end
        DTypeDSL.visibleString("test", size: 5)
    end
    def test_init_visibleString_sizeRange
        DTypeDSL.new do
            visibleString("test", size: 1..5)
        end
        DTypeDSL.visibleString("test", size: 1..5)
    end

    def test_init_bitString
        DTypeDSL.new do
            bitString("test")
        end
        DTypeDSL.bitString("test")
    end
    def test_init_bitString_size
        DTypeDSL.new do
            bitString("test", size: 5)
        end
        DTypeDSL.bitString("test", size: 5)
    end
    def test_init_bitString_sizeRange
        DTypeDSL.new do
            bitString("test", size: 1..5)
        end
        DTypeDSL.bitString("test", size: 1..5)
    end

    def test_init_octetString
        DTypeDSL.new do
            octetString("test")
        end
        DTypeDSL.octetString("test")
    end
    def test_init_octetString_size
        DTypeDSL.new do
            octetString("test", size: 5)
        end
        DTypeDSL.octetString("test", size: 5)
    end
    def test_init_octetString_sizeRange
        DTypeDSL.new do
            octetString("test", size: 1..5)
        end
        DTypeDSL.octetString("test", size: 1..5)
    end

    def test_init_array
        DTypeDSL.new do
            array("test") do
                integer("repeating")
            end
        end
        DTypeDSL.array("test") do
            integer("repeating")
        end
            
    end
    def test_init_array_multiItem

        assert_raise DTypeDSLError do
            DTypeDSL.new do
                array("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DTypeDSLError do
            DTypeDSL.array("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_array_size
        DTypeDSL.new do
            array("test", size: 5) do
                integer("repeating")
            end
        end

        DTypeDSL.array("test", size: 5) do
            integer("repeating")
        end
    end
    def test_init_array_sizeRange
        DTypeDSL.new do
            array("test", size: 1..5) do
                integer("repeating")
            end
        end

        DTypeDSL.array("test", size: 1..5) do
            integer("repeating")
        end
    end
    
    def test_init_compactArray
        DTypeDSL.new do
            compactArray("test") do
                integer("repeating")
            end
        end

        DTypeDSL.compactArray("test") do
            integer("repeating")
        end
    end
    def test_init_compactArray_multiItem

        assert_raise DTypeDSLError do
            DTypeDSL.new do
                compactArray("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DTypeDSLError do
            DTypeDSL.compactArray("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_compactArray_nestedCompact

        assert_raise DTypeDSLError do
            DTypeDSL.new do
                compactArray("test") do
                    compactArray("invalid") do
                        integer("repeating")
                    end
                end
            end
        end

        assert_raise DTypeDSLError do
            DTypeDSL.compactArray("test") do
                compactArray("invalid") do
                    integer("repeating")
                end
            end            
        end
        
    end
    def test_init_compactArray_size
        DTypeDSL.new do
            compactArray("test", size: 5) do
                integer("repeating")
            end
        end
    end
    def test_init_compactArray_sizeRange
        DTypeDSL.new do
            compactArray("test", size: 1..5) do
                integer("repeating")
            end
        end
    end

    def test_init_structure
        DTypeDSL.new do
            structure("test") do
                integer("one")
                long("two")
                doubleLong("three")
                octetString("four")
            end
        end
    end
    def test_init_structure_repeatFieldName
        
        assert_raise DTypeDSLError do
            DTypeDSL.new do
                structure("test") do
                    integer("one")
                    long("one")                
                end
            end
        end

        assert_raise DTypeDSLError do            
            DTypeDSL.structure("test") do
                integer("one")
                long("one")                
            end            
        end
        
    end

    def test_init_structure_anon
        assert_true(
            DTypeDSL.structure do
                integer
                long
            end.anon
        )

        assert_true(
            DTypeDSL.structure("test") do
                integer
                long
            end.anon
        )

        assert_false(
            DTypeDSL.structure("test") do
                integer("one")
                long("two")
            end.anon
        )
        
    end

end
