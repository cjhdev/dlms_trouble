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

    class AccessRequest

        @tag = AXDR::Length.new(217)

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

        # @return [String] COSEMpdu.XDLMS-APDU.access-request
        def encode

            buffer = self.class.tag.encode
            buffer << @invokeID.encode
            buffer << AXDR::Length.new(@requests.size).encode
            @requests.each{|req| buffer << req.encode_spec}
            buffer << AXDR::Length.new(@requests.size).encode
            @requests.each{|req| buffer << req.encode_data}
            buffer
            
        end

        # @param classID [Integer]
        # @param instanceID [OBIS, String]
        # @param methodID [Integer]            
        def get(classID, instanceID, methodID)
            @requests << AccessRequestGet.new(classID, instanceID, methodID)
            self
        end

        def set(classID, instanceID, methodID, data)
            @requests << AccessRequestSet.new(classID, instanceID, methodID, data)
            self
        end

        # configure invokeID
        # @param id [integer, symbol]            
        def setInvokeID(id)

            if id == :generate
                @invokeID = 0
            else
                @invokeID = id.to_i & 0x7fffff
            end
            self
            
        end

        def invokeID
            @invokeID
        end

        # configure confirmed mode (default true)
        # @param mode [Boolean]
        def confirmed(mode)
            @confirmed = (mode ? true : false)
            self
        end

        def confirmed?
            @confirmed
        end

        # configure breakOnError mode (default false)
        # @param mode [Boolean]
        def breakOnError(mode)
            @breakOnError = (mode ? true : false)
            self
        end

        def breakOnError?
            @breakOnError
        end

        # configure selfDescribe mode (default false)
        # @param mode [Boolean]
        def selfDescribe(mode)
            @selfDescribe = (mode ? true : false)
            self
        end

        def selfDescribe?
            @selfDescribe
        end

        def highPriority(mode)
            @highPriority = (mode ? true : false)
            self
        end

        def highPriority?
            @highPriority
        end

        # configure dateTime field (default is empty)
        # @param time [DateTime, Symbol] :now or a DateTime
        def setDateTime(time)
            @dateTime = time
            if time
                begin
                    DType::DateTime.new(time)
                rescue ex
                    raise AccessError.new "dateTime failed for reason: #{ex}"
                end                
            end
            self               
        end

        def dateTime
            @dateTime
        end

        def self.tag
            @tag
        end

        def tag
            self.class.tag
        end

    end

end
