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

    class GetResponse
        @tag = AXDR::Tag.new(196)
        def self.tag
            @tag
        end
        def self.decode(input)
            tag = AXDR::Tag.decode(input)
            case tag.value
            when GetResponseNormal.tag
                GetResponseNormal.decode(input)
            else
                raise
            end                
        end
        def encode
            self.class.tag.encode            
        end
    end

    class GetResponseNormal < GetResponse
        @tag = AXDR::Tag.new(1)
        def self.decode(input)
            invokeIDAndPriority = InvokeIDAndPriority.decode(input)            
            case AXDR::Tag.decode(input).value
            when 0
                result = DataAccessResult.new(:success)
                data = DType.decode(input)
            when 1
                result = DataAccessResult.decode(input)
                data = nil
            else
                raise
            end
            self.new(invokeIDAndPriority, result, data)            
        end
        def initialize(invokeIDAndPriority, dataAccessResult, data=nil)
            @invokeIDAndPriority = invokeIDAndPriority
            @dataAccessResult = dataAccessResult
            @data = data
        end
        def encode
            output = super.encode
            output << self.class.tag.encode
            output << @invokeIDAndPriority.encode
            if @dataAccessResult.value == :success
                output << AXDR::Tag.new(0).encode
                output << @data.encode
            else
                output << AXDR::Tag.new(1).encode            
                output << @dataAccessResult.encode
            end            
        end
    end

end
