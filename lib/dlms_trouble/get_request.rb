# Copyright (c) 2016 Cameron Harper
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module DLMSTrouble

    class GetRequest
        @tag = AXDR::Tag.new(192)
        def self.tag
            @tag
        end
        def self.decode(input)
            tag = AXDR::Tag.decode(input)
            case tag.value
            when GetRequestNormal.tag
                GetRequestNormal.decode(input)
            else
                raise
            end                
        end
        def encode
            self.class.tag.encode
        end
    end

    class GetRequestNormal < GetRequest
        attr_reader :invokeIDAndPriority, :attributeDescriptor, :accessSelection
        @tag = AXDR::Tag.new(1)
        def self.decode(input)
            invokeIDAndPriority = InvokeIDAndPriority.decode(input)
            attributeDescriptor = CosemAttributeDescriptor.decode(input)
            if AXDR::Boolean.decode(input).value                    
                accessSelection = SelectiveAccessDescriptor.decode(input)
            else
                accessSelection = nil
            end
            self.new(invokeIDAndPriority, attributeDescriptor, accessSelection)            
        end
        def initialize(invokeIDAndPriority, attributeDescriptor, accessSelection)
            @invokeIDAndPriority = invokeIDAndPriority
            @attributeDescriptor = attributeDescriptor
            @accessSelection = accessSelection
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
        end
    end

end
