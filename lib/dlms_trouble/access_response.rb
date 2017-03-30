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

    class AccessResponse

        @tag = AXDR::Length.new(218)

        attr_reader :invokeID, :dateTime, :requests

        def self.tag
            @tag
        end

        def self.decode(input)
        
            invokeID = LongInvokeIDAndPriority.decode(input)
            dateTimeString = DType::OctetString.decode(input)

            if dateTimeString.size > 0
                dateTime = DType::DateTime.decode(StringIO.new(dateTimeString.encode))
            else
                dateTime = nil
            end

            spec = []
            
            while requestSpec.size < AXDR::Length.decode(input) do

                case AXDR::Tag.decode(input)
                when AccessRequestGet.tag
                    spec << {:type => AccessRequestGet, :spec => CosemAttributeDescriptor.decode(input)}
                else
                    raise
                end                
            end

            requests = []

            spec.each do |s|

                case s[:type]
                when AccessRequestGet
                    DType::NullData.decode(input)
                    requests << s[:type].new(s[:spec])
                when AccessRequestSet, AccessRequestAction
                    requests << s[:type].new(s[:spec], DType.decode(input))
                when AccessRequestGetWithSelection
                    DType::NullData.decode(input)
                    requests << s[:type].new(s[:spec], s[:selector])
                when AccessRequestSetWithSelection
                    requests << s[:type].new(s[:spec], s[:selector], DType.decode(input))
                    raise
                end

            end

            self.new(invokeID, dateTime, requests)
            
        end

        def initialize(invokeID, dateTime, requests)
        
            @invokeID = invokeID
            @dateTime = dateTime
            @requests = requests
            
        end

        


    end

end
