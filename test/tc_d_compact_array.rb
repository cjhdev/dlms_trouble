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

class TestDCompactArray < Test::Unit::TestCase

    include DLMSTrouble

    def test_to_axdr

        assert_equal("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a".force_encoding("ASCII-8BIT"), 
            DCompactArray.new(
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42)                
            ).to_axdr        
        )

    end

    def test_from_axdr!

        assert_equal(
            DCompactArray.new(
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42),
                DInteger.new(42)                
            ),
            DCompactArray.from_axdr!("\x13\x0F\x06\x2a\x2a\x2a\x2a\x2a\x2a".force_encoding("ASCII-8BIT"))
        )

        assert_equal(
            DCompactArray.new(
                DStructure.new(
                    DArray.new(
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42)
                    ),
                    DOctetString.new("hello world")
                ),
                DStructure.new(
                    DArray.new(
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42)
                    ),
                    DOctetString.new("hello world")
                ),
                DStructure.new(
                    DArray.new(
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42),
                        DInteger.new(42)
                    ),
                    DOctetString.new("")
                )
            ),
            DCompactArray.from_axdr!("\x13\x02\x02\x01\x00\x06\x0F\x09\x2B\x2a\x2a\x2a\x2a\x2a\x2a\x0bhello world\x2a\x2a\x2a\x2a\x2a\x2a\x0bhello world\x2a\x2a\x2a\x2a\x2a\x2a\x00".force_encoding("ASCII-8BIT"))
        )

    end

end