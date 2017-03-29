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
require "dlms_trouble"

class TestAXDR < Test::Unit::TestCase

    include DLMSTrouble

    def test_sizeSize

        assert_equal(1, AXDR::sizeSize(0))
        assert_equal(1, AXDR::sizeSize(0x7f))
        assert_equal(2, AXDR::sizeSize(0x80))
        assert_equal(2, AXDR::sizeSize(0xff))
        assert_equal(3, AXDR::sizeSize(0x100))
        assert_equal(4, AXDR::sizeSize(0x10000))
        assert_equal(5, AXDR::sizeSize(0x1000000))
        assert_equal(6, AXDR::sizeSize(0x100000000))
        
    end

    def test_putSize

        assert_equal("\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0))
        assert_equal("\x7F".force_encoding("ASCII-8BIT"), AXDR::putSize(0x7f))
        assert_equal("\x81\x80".force_encoding("ASCII-8BIT"),AXDR::putSize(0x80))
        assert_equal("\x81\xff".force_encoding("ASCII-8BIT"), AXDR::putSize(0xff))
        assert_equal("\x82\x01\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x100))
        assert_equal("\x83\x01\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x10000))
        assert_equal("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x1000000))
        assert_equal("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x100000000))
        assert_equal("\x86\x01\x00\x00\x00\x00\x00".force_encoding("ASCII-8BIT"), AXDR::putSize(0x10000000000))

    end

    def test_getSize

        assert_equal(0, AXDR::getSize(StringIO.new("\x00")))
        assert_equal(0x7f, AXDR::getSize(StringIO.new("\x7f")))
        assert_equal(0x80, AXDR::getSize(StringIO.new("\x81\x80")))
        assert_equal(0xff, AXDR::getSize(StringIO.new("\x81\xff")))
        assert_equal(0x100, AXDR::getSize(StringIO.new("\x82\x01\x00")))
        assert_equal(0x10000, AXDR::getSize(StringIO.new("\x83\x01\x00\x00")))
        assert_equal(0x1000000, AXDR::getSize(StringIO.new("\x84\x01\x00\x00\x00")))
        assert_equal(0x100000000, AXDR::getSize(StringIO.new("\x85\x01\x00\x00\x00\x00")))

        assert_raise(AXDR::AXDRError) do
            AXDR::getSize(StringIO.new("\x80"))
        end
    end

end
