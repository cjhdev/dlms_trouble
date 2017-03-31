module DLMSTrouble

    class ActionResponse

        @tag = AXDR::Tag.new(199)

        def self.tag
            @tag
        end
        
        def self.decode(input)
            tag = AXDR::Tag.decode(input)
            case tag
            when ActionResponseNormal.tag
                ActionResponseNormal.decode(input)
            else
                raise
            end                
        end
        
        def encode
            self.class.tag.encode
        end
    end

    class ActionResponseNormal < ActionResponse

        attr_reader :invokeIDAndPriority, :methodDescriptor, :parameter
        @tag = AXDR::Tag.new(1)
        def self.decode(input)
            invokeIDAndPriority = InvokeIDAndPriority.decode(input)
            result = ActionResult.decode(input)
            if AXDR::Boolean.decode(input).value
                data = DType.decode(input)
            else
                data = nil
            end
            self.new(invokeIDAndPriority, result, data)            
        end
        def initialize(invokeIDAndPriority, result, data=nil)
            @invokeIDAndPriority = invokeIDAndPriority
            @result = result
            @data = nil
        end
        def encode
            output = super.encode
            output << self.class.tag.encode
            output << @invokeIDAndPriority.encode
            output << @result.encode
            if @data
                output << AXDR::Boolean.new(true).encode
                output << @data.encode
            else
                output << AXDR::Boolean.new(false).encode
            end                            
        end
    end

end


