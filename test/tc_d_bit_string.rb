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

class TestDBitString < Test::Unit::TestCase

    include DLMSTrouble

    def test_to_axdr

        assert_equal("\x04\x08\x55".force_encoding("ASCII-8BIT"), DBitString.new(false,true,false,true,false,true,false,true).to_axdr)
        assert_equal("\x04\x07\x54".force_encoding("ASCII-8BIT"), DBitString.new(false,true,false,true,false,true,false).to_axdr)
        assert_equal("\x04\x08\x00".force_encoding("ASCII-8BIT"), DBitString.new(false,false,false,false,false,false,false,false).to_axdr)
        assert_equal("\x04\x09\xff\x00".force_encoding("ASCII-8BIT"), DBitString.new(true,true,true,true,true,true,true,true,false).to_axdr)

    end

    def test_from_axdr!

        assert_equal(DBitString.new(false,true,false,true,false,true,false,true), DBitString.from_axdr!("\x04\x08\x55".force_encoding("ASCII-8BIT")))
        assert_equal(DBitString.new(false,true,false,true,false,true,false), DBitString.from_axdr!("\x04\x07\x54".force_encoding("ASCII-8BIT")))
        assert_equal(DBitString.new(false,false,false,false,false,false,false,false), DBitString.from_axdr!("\x04\x08\x00".force_encoding("ASCII-8BIT")))
        assert_equal(DBitString.new(true,true,true,true,true,true,true,true,false), DBitString.from_axdr!("\x04\x09\xff\x00".force_encoding("ASCII-8BIT")))

        assert_raise DTypeError do

            assert_equal(DBitString.new(false,true,false,true,false,true,false), DBitString.from_axdr!("\x04\x07\x55".force_encoding("ASCII-8BIT")))

        end

    end

end
