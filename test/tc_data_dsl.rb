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
require "dlms_trouble/data_dsl"

class TestDataDSL < Test::Unit::TestCase

    include DLMSTrouble

    def test_init_noSchema                
        assert_equal(nil, DataDSL.new.type)        
    end

    def test_init_multipleDefinition
        assert_raise DataDSLError do
            DataDSL.new do
                nullData("test")
                nullData("testAgain")
            end
        end
        assert_raise DataDSLError do
            DataDSL.nullData("test").nullData("test")
        end
    end

    def test_init_nullData
        DataDSL.new do
            nullData("test")
        end
        DataDSL.nullData("test")
    end

    def test_init_enum
        DataDSL.new do
            enum("test")
        end
        DataDSL.enum("test")        
    end

    def test_init_boolean
        DataDSL.new do
            boolean("test")
        end
        DataDSL.boolean("test")
    end

    def test_init_integer
        DataDSL.new do
            integer("test")
        end
        DataDSL.integer("test")
    end
    def test_init_long
        DataDSL.new do
            long("test")
        end
        DataDSL.long("test")
    end
    def test_init_doubleLong
        DataDSL.new do
            doubleLong("test")
        end
        DataDSL.doubleLong("test")
    end
    def test_init_long64
        DataDSL.new do
            long64("test")
        end
        DataDSL.long64("test")
    end
    
    def test_init_unsigned
        DataDSL.new do
            unsigned("test")
        end
        DataDSL.unsigned("test")
    end
    def test_init_longUnsigned
        DataDSL.new do
            longUnsigned("test")
        end
        DataDSL.longUnsigned("test")
    end
    def test_init_doubleLongUnsigned
        DataDSL.new do
            doubleLongUnsigned("test")
        end
        DataDSL.doubleLongUnsigned("test")
    end    
    def test_init_long64Unsigned
        DataDSL.new do
            long64Unsigned("test")
        end
        DataDSL.long64Unsigned("test")
    end

    def test_init_visibleString
        DataDSL.new do
            visibleString("test")
        end
        DataDSL.visibleString("test")
    end
    def test_init_visibleString_size
        DataDSL.new do
            visibleString("test", size: 5)
        end
        DataDSL.visibleString("test", size: 5)
    end
    def test_init_visibleString_sizeRange
        DataDSL.new do
            visibleString("test", size: 1..5)
        end
        DataDSL.visibleString("test", size: 1..5)
    end

    def test_init_octetString
        DataDSL.new do
            octetString("test")
        end
        DataDSL.octetString("test")
    end
    def test_init_octetString_size
        DataDSL.new do
            octetString("test", size: 5)
        end
        DataDSL.octetString("test", size: 5)
    end
    def test_init_octetString_sizeRange
        DataDSL.new do
            octetString("test", size: 1..5)
        end
        DataDSL.octetString("test", size: 1..5)
    end

    def test_init_array
        DataDSL.new do
            array("test") do
                integer("repeating")
            end
        end
        DataDSL.array("test") do
            integer("repeating")
        end
            
    end
    def test_init_array_multiItem

        assert_raise DataDSLError do
            DataDSL.new do
                array("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DataDSLError do
            DataDSL.array("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_array_size
        DataDSL.new do
            array("test", size: 5) do
                integer("repeating")
            end
        end

        DataDSL.array("test", size: 5) do
            integer("repeating")
        end
    end
    def test_init_array_sizeRange
        DataDSL.new do
            array("test", size: 1..5) do
                integer("repeating")
            end
        end

        DataDSL.array("test", size: 1..5) do
            integer("repeating")
        end
    end
    
    def test_init_compactArray
        DataDSL.new do
            compactArray("test") do
                integer("repeating")
            end
        end

        DataDSL.compactArray("test") do
            integer("repeating")
        end
    end
    def test_init_compactArray_multiItem

        assert_raise DataDSLError do
            DataDSL.new do
                compactArray("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DataDSLError do
            DataDSL.compactArray("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_compactArray_nestedCompact

        assert_raise DataDSLError do
            DataDSL.new do
                compactArray("test") do
                    compactArray("invalid") do
                        integer("repeating")
                    end
                end
            end
        end

        assert_raise DataDSLError do
            DataDSL.compactArray("test") do
                compactArray("invalid") do
                    integer("repeating")
                end
            end            
        end
        
    end
    def test_init_compactArray_size
        DataDSL.new do
            compactArray("test", size: 5) do
                integer("repeating")
            end
        end
    end
    def test_init_compactArray_sizeRange
        DataDSL.new do
            compactArray("test", size: 1..5) do
                integer("repeating")
            end
        end
    end

    def test_init_structure
        DataDSL.new do
            structure("test") do
                integer("one")
                long("two")
                doubleLong("three")
                octetString("four")
            end
        end
    end
    def test_init_structure_repeatFieldName
        
        assert_raise DataDSLError do
            DataDSL.new do
                structure("test") do
                    integer("one")
                    long("one")                
                end
            end
        end

        assert_raise DataDSLError do            
            DataDSL.structure("test") do
                integer("one")
                long("one")                
            end            
        end
        
    end

    def test_init_structure_anon
        assert_true(
            DataDSL.structure do
                integer
                long
            end.anon
        )

        assert_true(
            DataDSL.structure("test") do
                integer
                long
            end.anon
        )

        assert_false(
            DataDSL.structure("test") do
                integer("one")
                long("two")
            end.anon
        )
        
    end

end
