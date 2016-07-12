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
require "dlms_trouble/dtype_schema"

class TestDTypeSchema < Test::Unit::TestCase

    include DLMSTrouble

    def test_init_noSchema                
        assert_equal(nil, DTypeSchema.new.type)        
    end

    def test_init_multipleDefinition
        assert_raise DTypeSchemaError do
            DTypeSchema.new do
                nullData("test")
                nullData("testAgain")
            end
        end
        assert_raise DTypeSchemaError do
            DTypeSchema.nullData("test").nullData("test")
        end
    end

    def test_init_nullData
        DTypeSchema.new do
            nullData("test")
        end
        DTypeSchema.nullData("test")
    end
    
    def test_init_dontCare
        DTypeSchema.new do
            dontCare("test")
        end
        DTypeSchema.dontCare("test")
    end

    def test_init_bcd
        DTypeSchema.new do
            bcd("test")
        end
        DTypeSchema.bcd("test")
    end

    def test_init_dateTime
        DTypeSchema.new do
            dateTime("test")
        end
        DTypeSchema.dateTime("test")
    end
    def test_init_date
        DTypeSchema.new do
            date("test")
        end
        DTypeSchema.date("test")
    end
    def test_init_time
        DTypeSchema.new do
            time("test")
        end
        DTypeSchema.time("test")
    end

    def test_init_enum
        DTypeSchema.new do
            enum("test")
        end
        DTypeSchema.enum("test")        
    end

    def test_init_boolean
        DTypeSchema.new do
            boolean("test")
        end
        DTypeSchema.boolean("test")
    end

    def test_init_integer
        DTypeSchema.new do
            integer("test")
        end
        DTypeSchema.integer("test")
    end
    def test_init_long
        DTypeSchema.new do
            long("test")
        end
        DTypeSchema.long("test")
    end
    def test_init_doubleLong
        DTypeSchema.new do
            doubleLong("test")
        end
        DTypeSchema.doubleLong("test")
    end
    def test_init_long64
        DTypeSchema.new do
            long64("test")
        end
        DTypeSchema.long64("test")
    end
    
    def test_init_unsigned
        DTypeSchema.new do
            unsigned("test")
        end
        DTypeSchema.unsigned("test")
    end
    def test_init_longUnsigned
        DTypeSchema.new do
            longUnsigned("test")
        end
        DTypeSchema.longUnsigned("test")
    end
    def test_init_doubleLongUnsigned
        DTypeSchema.new do
            doubleLongUnsigned("test")
        end
        DTypeSchema.doubleLongUnsigned("test")
    end    
    def test_init_long64Unsigned
        DTypeSchema.new do
            long64Unsigned("test")
        end
        DTypeSchema.long64Unsigned("test")
    end

    def test_init_visibleString
        DTypeSchema.new do
            visibleString("test")
        end
        DTypeSchema.visibleString("test")
    end
    def test_init_visibleString_size
        DTypeSchema.new do
            visibleString("test", size: 5)
        end
        DTypeSchema.visibleString("test", size: 5)
    end
    def test_init_visibleString_sizeRange
        DTypeSchema.new do
            visibleString("test", size: 1..5)
        end
        DTypeSchema.visibleString("test", size: 1..5)
    end

    def test_init_bitString
        DTypeSchema.new do
            bitString("test")
        end
        DTypeSchema.bitString("test")
    end
    def test_init_bitString_size
        DTypeSchema.new do
            bitString("test", size: 5)
        end
        DTypeSchema.bitString("test", size: 5)
    end
    def test_init_bitString_sizeRange
        DTypeSchema.new do
            bitString("test", size: 1..5)
        end
        DTypeSchema.bitString("test", size: 1..5)
    end

    def test_init_octetString
        DTypeSchema.new do
            octetString("test")
        end
        DTypeSchema.octetString("test")
    end
    def test_init_octetString_size
        DTypeSchema.new do
            octetString("test", size: 5)
        end
        DTypeSchema.octetString("test", size: 5)
    end
    def test_init_octetString_sizeRange
        DTypeSchema.new do
            octetString("test", size: 1..5)
        end
        DTypeSchema.octetString("test", size: 1..5)
    end

    def test_init_array
        DTypeSchema.new do
            array("test") do
                integer("repeating")
            end
        end
        DTypeSchema.array("test") do
            integer("repeating")
        end
            
    end
    def test_init_array_multiItem

        assert_raise DTypeSchemaError do
            DTypeSchema.new do
                array("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DTypeSchemaError do
            DTypeSchema.array("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_array_size
        DTypeSchema.new do
            array("test", size: 5) do
                integer("repeating")
            end
        end

        DTypeSchema.array("test", size: 5) do
            integer("repeating")
        end
    end
    def test_init_array_sizeRange
        DTypeSchema.new do
            array("test", size: 1..5) do
                integer("repeating")
            end
        end

        DTypeSchema.array("test", size: 1..5) do
            integer("repeating")
        end
    end
    
    def test_init_compactArray
        DTypeSchema.new do
            compactArray("test") do
                integer("repeating")
            end
        end

        DTypeSchema.compactArray("test") do
            integer("repeating")
        end
    end
    def test_init_compactArray_multiItem

        assert_raise DTypeSchemaError do
            DTypeSchema.new do
                compactArray("test") do
                    integer("repeating")
                    integer("invalid")
                end
            end
        end

        assert_raise DTypeSchemaError do
            DTypeSchema.compactArray("test") do
                integer("repeating")
                integer("invalid")
            end
        end
        
    end
    def test_init_compactArray_nestedCompact

        assert_raise DTypeSchemaError do
            DTypeSchema.new do
                compactArray("test") do
                    compactArray("invalid") do
                        integer("repeating")
                    end
                end
            end
        end

        assert_raise DTypeSchemaError do
            DTypeSchema.compactArray("test") do
                compactArray("invalid") do
                    integer("repeating")
                end
            end            
        end
        
    end
    def test_init_compactArray_size
        DTypeSchema.new do
            compactArray("test", size: 5) do
                integer("repeating")
            end
        end
    end
    def test_init_compactArray_sizeRange
        DTypeSchema.new do
            compactArray("test", size: 1..5) do
                integer("repeating")
            end
        end
    end

    def test_init_structure
        DTypeSchema.new do
            structure("test") do
                integer("one")
                long("two")
                doubleLong("three")
                octetString("four")
            end
        end
    end
    def test_init_structure_repeatFieldName
        
        assert_raise DTypeSchemaError do
            DTypeSchema.new do
                structure("test") do
                    integer("one")
                    long("one")                
                end
            end
        end

        assert_raise DTypeSchemaError do            
            DTypeSchema.structure("test") do
                integer("one")
                long("one")                
            end            
        end
        
    end

    def test_init_structure_anon
        assert_equal(true,
            DTypeSchema.structure do
                integer
                long
            end.anon
        )

        assert_equal(true,
            DTypeSchema.structure("test") do
                integer
                long
            end.anon
        )

        assert_equal(
            false,
            DTypeSchema.structure("test") do
                integer("one")
                long("two")
            end.anon
        )
        
    end

end
