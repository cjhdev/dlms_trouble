module DLMSTrouble::HDLC

    class Frame
    
        FRAME_CHAR = 0x7e
    
        include Checksum
        include DLMSTrouble::LoggerMethods
    
        attr_reader :pf
        attr_reader :dest
        attr_reader :src
        attr_reader :info
        attr_reader :segment
        
        @subs = []
        
        def self.===(other)
            self == other
        end
        
        def self.inherited(subclass)
            if self == Frame
                @subs << subclass            
            else                
                superclass.inherited(subclass)
            end
        end
        
        def self.from_decoder(decoder)
        
            if (decoder.control & 1) == 0
            
                IFrame.from_decoder(decoder)
                    
            elsif (decoder.control & 3) == 3
                
                UFrame.from_decoder(decoder)
            
            else
            
                SFrame.from_decoder(decoder)
            
            end
                
        end
        
        def initialize(**attr)
        
            raise "abstract class" unless self.class != Frame
        
            if attr.has_key? :dest
                @dest = attr[:dest]
                raise TypeError unless dest.kind_of? Address
            else
                @dest = OneByte.new(0)
            end
                
            if attr.has_key? :src
                @src = attr[:src]
                raise TypeError unless src.kind_of? Address
            else
                @src = OneByte.new(0)
            end
            
            if attr.has_key? :pf
                @pf = ( attr[:pf] ? true : false )
            else
                @pf = true
            end
            
            if attr.has_key? :segment
                @segment = ( attr[:segment] ? true : false )
            else
                @segment = false
            end
            
        end
        
        # @return [String]
        def encode
            
            size = 2 + dest.encode.size + src.encode.size + 1 + ( (info.size > 0) ? ( 2 + info.size) : 0 )
            
            hdr = [
                ( segment ? 0xa8 : 0xa0 ) | ( (size > 0xff) ? ((size >> 8) & 0x7) : 0 ),
                size,
                dest.encode,
                src.encode,
                control
            ].pack("C2A*A*C")
            
            if  info.size > 0
            
                [
                    FRAME_CHAR,
                    hdr,
                    checksum_block(0xffff, hdr) ^ 0xffff,
                    info,
                    checksum_block(0xf0b8, info) ^ 0xffff,
                    FRAME_CHAR,
                    
                ].pack("CA*S<A*S<C")
                    
            else
            
                [
                    FRAME_CHAR,
                    hdr,
                    checksum_block(0xffff, hdr) ^ 0xffff,
                    FRAME_CHAR,
                    
                ].pack("CA*S<C")
                    
            end    
            
        end
        
    end
    
    class UFrame < Frame
    
        @subs = []
        
        def self.inherited(subclass)
            if self == UFrame
                @subs << subclass            
            end
            superclass.inherited(subclass)            
        end
    
        def self.type
            @type
        end
        
        def control(type)
            (((type & 0x1c) << 3) | ((pf ? 0x1 : 0x0) << 4) | ((type & 0x3) << 2)|0x3)
        end
    
        def self.from_decoder(decoder)
        
            type = ((decoder.control & 0xe0) >> 3) | ((decoder.control & 0x3) >> 2)
            pf = ( ((decoder.control & 0x10) == 0x10) ? true : false )
        
            klass = @subs.detect { |k| k.type == type }
            
            raise RangeError.new "unknown command" unless klass
            
            klass.new(
                src: decoder.src,
                dest: decoder.dest,
                segment: decoder.segment,
                pf: pf,                
                info: decoder.info
            )
        end
        
        def initialize(**attr)
            
            raise "abstract class" unless self.class != UFrame
            
            super
            
            if attr.has_key? :info
                @info = attr[:info].to_s
                raise TypeError unless @info.size <= 0x7ff                
            else            
                @info = ""
            end
            
        end
        
    end
    
    
    class FRMRFrame < UFrame        
        @type = 17    
        def control
            super(type)
        end
    end
    
    class SNRMFrame < UFrame    
        @type = 16    
        
        def control
            super(type)
        end        
        def initialize(**attr)  
            super(**attr)
            @info = attr[:info].dup            
        end                
    end
    
    class UIFrame < UFrame
        @type = 0
        attr_reader :info
        def control
            super(type)
        end
        def initialize(**attr)
            super(**attr)
            @info = attr[:info]
        end
    end
    
    class UAFrame < UFrame
        @type = 12
        def control
            super(type)
        end
    end
    class DiscFrame < UFrame
        @type = 8
        attr_reader :info
        def control
            super(type)
        end
        def initialize(**attr)
            super(**attr)
            @info = attr[:info]
        end
    end
    
    class DMFrame < UFrame
        @type = 3
        def control
            super(type)
        end
    end
    
    class SFrame < Frame    
        
        @subs = []
        
        def self.inherited(subclass)
            if self == UFrame
                @subs << subclass            
            end
            superclass.inherited(subclass)            
        end
        
        def self.from_decoder(decoder)
        
            type = (decoder.control >> 1) & 0x7
            pf = ( ((decoder.control & 0x10) == 0x10) ? true : false )
        
            klass = @subs.detect { |k| k.type == type }
            
            raise RangeError.new "unknown command" unless klass
            
            klass.new(
                src: decoder.src,
                dest: decoder.dest,
                segment: decoder.segment,
                pf: pf,
                rrr: (decoder.control >> 5)
            )
        end
        
        attr_reader :rrr        
        def self.type
            @type
        end
        def control(type)
            (((rrr & 0x7) << 5) | ((pf ? 0x1 : 0x0) << 4) | ((type & 0x3) << 2)|0x1)
        end        
        def initialize(**attr)  
            
            raise "abstract class" unless self.class != SFrame 
            
            super
            
            if attr.has_key? :rrr
                @rrr = attr[:rrr].to_i
                raise TypeError unless @rrr >= 0            
            else
                @rrr = 0
            end
            
        end    
    end
    
    class RRFrame < SFrame    
        @type = 0        
        def control
            super(type)
        end     
    end
    
    class RNRFrame < SFrame    
        @type = 2        
        def control
            super(type)
        end    
    end
    
    class IFrame < Frame
         
        def self.from_decoder(decoder)
        
            sss = (decoder.control >> 1) & 0x7
            rrr = (decoder.control >> 5) & 0x7
            pf = ( ((decoder.control & 0x10) == 0x10) ? true : false )
        
            self.new(
                src: decoder.src,
                dest: decoder.dest,
                segment: decoder.segment,
                pf: pf,
                info: decoder.info.dup,
                sss: sss,
                rrr: rrr
            )
        end
        
        attr_reader :rrr
        attr_reader :sss
        def control
            ((rrr & 0x7) << 5) | ((pf ? 1 : 0) << 4) | ((sss & 0x7) << 1)
        end
        def initialize(**attr)
            
            super
            
            if attr.has_key? :rrr
                @rrr = attr[:rrr].to_i
                raise TypeError unless @rrr >= 0            
            else
                @rrr = 0
            end
            
            if attr.has_key? :sss
                @sss = attr[:sss].to_i
                raise TypeError unless @sss >= 0            
            else
                @sss = 0
            end
            
            if attr.has_key? :info
                @info = attr[:info].to_s
                raise TypeError unless @info.size <= 0x7ff                
            else            
                @info = ""
            end
            
        end
    end


end
