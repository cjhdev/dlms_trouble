module DLMSTrouble

    class LongInvokeIDAndPriority < InvokeIDAndPriority

        def selfDescribe?
            @selfDescribe
        end

        def breakOnError?
            @breakOnError
        end
        
        def self.decode(input)

            raw = input.read(1).unpack("L>")

            invokeID = raw & 0x7fffff

            if (raw & (0x1 << 28)) == (0x1 << 28)
                selfDescribe = true
            else
                selfDescribe = false
            end

            if (raw & (0x1 << 28)) == (0x1 << 28)
                breakOnError = true
            else
                breakOnError = false
            end

            if (raw & (0x1 << 28)) == (0x1 << 28)
                confirmed = true
            else
                confirmed = false
            end

            if (raw & (0x1 << 28)) == (0x1 << 28)
                highPriority = true
            else
                highPriority = false
            end

            self.new(invokeID, selfDescribe: selfDescribe, breakOnError: breakOnError, confirmed: confirmed, highPriority: highPriority)
        end
        def initialize(invokeID, **opts)
            @invokeID = invokeID
            @highPriority = opts[:highPriority]||false
            @selfDescribe = opts[:selfDescribe]||false
            @breakOnError = opts[:breakOnError]||false
            @confirmed = opts[:confirmed]||true
        end
        def encode

            raw = (@invokeID & 0x7fffff) |
                ( @selfDescribe ? (0x1 << 28) : 0x0 ) |
                ( @breakOnError ? (0x1 << 29) : 0x0 ) |
                ( @confirmed ? (0x1 << 30) : 0x0 ) |
                ( @highPriority ? (0x1 << 31) : 0x0 )

            [raw].pack("L>")
        end
    end

end

