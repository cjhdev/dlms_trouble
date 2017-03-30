module DLMSTrouble

    class SetRequest
        @tag = AXDR::Tag.new(193)
        def self.tag
            @tag
        end
        def self.decode(input)
            tag = AXDR::Tag.decode(input)
            case tag.value
            when SetRequestNormal.tag
                SetRequestNormal.decode(input)
            else
                raise
            end                
        end
        def encode
            self.class.tag.encode
        end
    end

    class SetRequestNormal < SetRequest
        attr_reader :invokeIDAndPriority, :attributeDescriptor, :accessSelection, :data
        @tag = AXDR::Tag.new(1)
        def self.decode(input)
            invokeIDAndPriority = InvokeIDAndPriority.decode(input)
            attributeDescriptor = CosemAttributeDescriptor.decode(input)
            if AXDR::Boolean.decode(input).value                    
                accessSelection = SelectiveAccessDescriptor.decode(input)
            else
                accessSelection = nil
            end
            data = DType.decode(input)
            self.new(invokeIDAndPriority, attributeDescriptor, accessSelection, data)            
        end
        def initialize(invokeIDAndPriority, attributeDescriptor, accessSelection, data)
            @invokeIDAndPriority = invokeIDAndPriority
            @attributeDescriptor = attributeDescriptor
            @accessSelection = accessSelection
            @data = data
        end
        def encode
            output = super.encode
            output << self.class.tag.encode
            output << @invokeIDAndPriority.encode
            output << @attributeDescriptor.encode
            if @accessSelection
                output << AXDR::Boolean.new(true).encode
                output << @accessSelection.encode
            else
                output << AXDR::Boolean.new(false).encode
            end
            output << @data
        end
    end

end
