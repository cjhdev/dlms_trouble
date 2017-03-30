module DLMSTrouble

    class ActionRequest

        @tag = AXDR::Tag.new(195)

        def self.tag
            @tag
        end
        
        def self.decode(input)
            tag = AXDR::Tag.decode(input)
            case tag
            when ActionRequestNormal.tag
                ActionRequestNormal.decode(input)
            else
                raise
            end                
        end
        
        def encode
            self.class.tag.encode
        end
    end

    class ActionRequestNormal < ActionRequest

        attr_reader :invokeIDAndPriority, :methodDescriptor, :parameter
        @tag = AXDR::Tag.new(1)
        def self.decode(input)
            invokeIDAndPriority = InvokeIDAndPriority.decode(input)
            methodDescriptor = CosemMethodDescriptor.decode(input)
            parameter = DType.decode(input)
            self.new(invokeIDAndPriority, methodDescriptor, parameter)            
        end
        def initialize(invokeIDAndPriority, methodDescriptor, parameter)
            @invokeIDAndPriority = invokeIDAndPriority
            @methodDescriptor = methodDescriptor
            @parameter = parameter
        end
        def encode
            output = super.encode
            output << self.class.tag.encode
            output << @invokeIDAndPriority.encode
            output << @methodDescriptor.encode
            output << @parameter
        end
    end

end

