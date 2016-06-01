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
require "dlms_trouble/obis"

class TestOBIS < Test::Unit::TestCase

    include DLMSTrouble

    def setup
        @obis = OBIS.new("1.2.3.4.5.6")
    end
    
    def test_parts

        assert_equal(1, @obis.a)
        assert_equal(2, @obis.b)
        assert_equal(3, @obis.c)
        assert_equal(4, @obis.d)
        assert_equal(5, @obis.e)
        assert_equal(6, @obis.f)

    end

    def test_to_s
        assert_equal("1.2.3.4.5.6", @obis.to_s)        
    end

    def test_to_axdr    
        assert_equal("\x01\x02\x03\x04\x05\x06".force_encoding("ASCII-8BIT"), @obis.to_axdr)
    end

    def test_init_from_axdr
        assert_true(OBIS.new("\x01\x02\x03\x04\x05\x06".force_encoding("ASCII-8BIT")).to_s == "1.2.3.4.5.6")
    end
    

end
