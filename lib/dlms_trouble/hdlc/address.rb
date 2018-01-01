module DLMSTrouble::HDLC

    class Address
        attr_reader :logical, :physical
        def initialize(logical, physical=nil)
            raise "abstract class" unless self.class != Address
            @logical = logical
            @physical = physical
        end
    end        
    
    class OneByte < Address
        def size
            1
        end
        def to_s
            [(logical << 1) | 0x1].pack("C")
        end
    end
    
    class TwoByte < Address 
        def size
            2
        end
        def to_s
            [
                (logical << 1) & 0xfe, 
                (physical << 1) | 0x1
            ].pack("C2")
        end
    end
    
    class FourByte < Address          
        def size
            4
        end
        def to_s
            [
                (logical >> 7) & 0xfe,
                (logical << 1) & 0xfe,
                (physical >> 7) & 0xfe,
                (physical << 1) | 0x1
            ].pack("C4")
        end
    end

end
