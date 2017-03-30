module DLMSTrouble

    class InvokeIDAndPriority
        attr_reader :invokeID

        def confirmed?
            @confirmed
        end

        def highPriority?
            @highPriority
        end

        def self.decode(input)
            raw = input.read(1).unpack("C")
            if (raw & 0x80) == 0x80
                highPriority = true
            else
                highPriority = false
            end
            if (raw & 0x40) == 0x40
                confirmed = true
            else
                confirmed = false
            end
            invokeID = raw & 0x3f
            self.new(invokeID, confirmed: confirmed, highPriority: highPriority)
        end

        def initialize(invokeID, **opts)
            @invokeID = invokeID
            @highPriority = opts[:highPriority]||false
            @confirmed = opts[:confirmed]||true      
        end
        
        def encode
            raw = (@priority ? 0x80 : 0x00)
            raw |= (@highPriority ? 0x40 : 0x00)
            raw |= (@invokeID & 0x3f)
            [raw].pack("C")
        end
    end

end
