module DLMSTrouble

    class CosemAttributeDescriptor
        attr_reader :classID, :instanceID, :attributeID
        def self.decode(input)
            classID = input.read(2).unpack("S>")
            instanceID = OBIS.decode(input)
            attributeID = input.read(1).unpack("c")
            self.new(classID, instanceID, attributeID)
        end
        def initialize(classID, instanceID, attributeID)
            @classID = classID
            @instanceID = instanceID
            @attributeID = attributeID
        end
        def encode
            buffer = [@classID].pack("S>")
            buffer << @instanceID.encode
            buffer << [@attributeID].pack("c")
        end
    end

end
