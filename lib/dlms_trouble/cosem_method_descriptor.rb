module DLMSTrouble

    class CosemMethodDescriptor
        attr_reader :classID, :instanceID, :methodID
        def self.decode(input)
            classID = input.read(2).unpack("S>")
            instanceID = OBIS.decode(input)
            methodID = input.read(1).unpack("c")
            self.new(classID, instanceID, methodID)
        end
        def initialize(classID, instanceID, methodID)
            @classID = classID
            @instanceID = instanceID
            @methodID = methodID
        end
        def encode
            buffer = [@classID].pack("S>")
            buffer << @instanceID.encode
            buffer << [@methodID].pack("c")
        end
    end

end
