require "test/unit"
require "dlms_trouble/axdr"

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

    def test_getSize!

        assert_equal(0, AXDR::getSize!("\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x7f, AXDR::getSize!("\x7f".force_encoding("ASCII-8BIT")))
        assert_equal(0x80, AXDR::getSize!("\x81\x80".force_encoding("ASCII-8BIT")))
        assert_equal(0xff, AXDR::getSize!("\x81\xff".force_encoding("ASCII-8BIT")))
        assert_equal(0x100, AXDR::getSize!("\x82\x01\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x10000, AXDR::getSize!("\x83\x01\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x1000000, AXDR::getSize!("\x84\x01\x00\x00\x00".force_encoding("ASCII-8BIT")))
        assert_equal(0x100000000, AXDR::getSize!("\x85\x01\x00\x00\x00\x00".force_encoding("ASCII-8BIT")))

        assert_raise(AXDR::AXDRError) do
            AXDR::getSize!("\x80".force_encoding("ASCII-8BIT"))
        end
    end

end
