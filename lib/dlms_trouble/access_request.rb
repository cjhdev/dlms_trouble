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

require 'dlms_trouble/obis'
require 'dlms_trouble/axdr'
require 'dlms_trouble/access_error'
require 'dlms_trouble/access_request_set'
require 'dlms_trouble/access_request_get'

module DLMSTrouble

    class AccessRequest

        @tag = 217
        
        def initialize(**args, &body)

            @confirmed = true
            @breakOnError = false
            @selfDescribe = false
            @dateTime = nil
            @invokeID = 0
            @highPriority = false
            @requests = []

            if body
                self.instance_exec(&body)
            end
    
        end

        # @return [String] COSEMpdu.XDLMS-APDU.access-request
        def to_axdr

            out = ""

            invokeIDAndPriority = (@invokeID & 0x7fffff) |
                ( @selfDescribe ? (0x1 << 28) : 0x0 ) |
                ( @breakOnError ? (0x1 << 29) : 0x0 ) |
                ( @confirmed ? (0x1 << 30) : 0x0 ) |
                ( @highPriority ? (0x1 << 31) : 0x0 )
                
            out << [tag, invokeIDAndPriority].pack("CL>")

            if @dateTime
                out << AXDR::putSize(@dateTime.to_axdr.size)
                out << @dateTime.to_axdr
            else
                out << AXDR::putSize(0)
            end

            out << AXDR::putSize(@requests.size)
            @requests.inject(out) { |acc, r| acc << r.to_request_spec }

            out << AXDR::putSize(@requests.size)
            @requests.inject(out) { |acc, r| acc << r.to_request_data }

            out
            
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
