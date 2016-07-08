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
require 'dlms_trouble/data'

module DLMSTrouble

    class AccessRequestGet

        TAG = 1

        def initialize(classID, instanceID, methodID)
            @classID = classID
            @instanceID = OBIS.new(instanceID.to_s)
            @methodID = methodID    
        end

        # @return [String]
        def to_request_spec
            [TAG, @classID, @instanceID.to_axdr, @methodID].pack("CS>A#{@instanceID.to_axdr.size}c")
        end

        # @return [String]
        def to_request_data
            [0].pack("C")
        end

    end

    class AccessRequestSet

        TAG = 2

        def initialize(classID, instanceID, methodID, data)
            @classID = classID
            @instanceID = OBIS.new(instanceID.to_s)
            @methodID = methodID
            @data = data
        end

        # @return [String]
        def  to_request_spec
            [TAG, @classID, @instanceID.to_axdr, @methodID].pack("CS>A#{@instanceID.to_axdr.size}c")
        end

        # @return [String]
        def to_request_data
            @data.to_axdr
        end

    end

    class Access

        TAG_ACCESS_REQUEST = 217
        TAG_ACCESS_RESPONSE = 218

        def initialize(**args, &body)

            @confirmed = true
            @breakOnError = false
            @selfDescribe = false
            @timeStamp = ""

            self.instance_exec(&body)            
            @status = :new
    
        end

        # @return [Symbol] :new, :sent, :complete
        attr_reader :status

        # @return [Integer] 
        attr_reader :invokeID

        # @return [String] COSEMpdu.XDLMS-APDU.access-request
        def request

            out = ""

            invokeIDAndPriority = (@invokeID & 0x7fffff) |
                ( @selfDescribe ? (0x1 << 28) : 0x0 ) |
                ( @breakOnError ? (0x1 << 29) : 0x0 ) |
                ( @confirmed ? (0x1 << 30) : 0x0 ) |
                ( @priority ? (0x1 << 31) : 0x0 )
                
            out << [TAG_ACCESS_REQUEST, invokeIDAndPriority].pack("CL>")

            if @dateTime
                out << AXDR::putSize(@dateTime.size)
                out << @dateTime
            end

            out << AXDR::putSize(@requests.size)
            out << @requests.each { |request| out << request.to_request_spec }

            out << AXDR::putSize(@requests.size)
            out << @requests.each { |request| out << request.to_request_data }

            @status = :sent
            out
            
        end

        # @param input [String] COSEMpdu.XDLMS-APDU.access-response
        def response(input)

            tag, invokeIDAndPriority = input.slice!(0).unpack("CL>")
            @status = :complete

        end

        # @return [Enumerator] 
        def each
            if status == :complete
                @requests.each
            else
                raise "access request is incomplete"
            end
        end
        

        private

            # @param classID [Integer]
            # @param instanceID [OBIS, String]
            # @param methodID [Integer]            
            def get(classID, instanceID, methodID)
                @requests << AccessRequestGet.new(classID, instanceID, methodID)
            end

            def set(classID, instanceID, methodID, data)
                @requests << AccessRequestSet.new(classID, instanceID, methodID)
            end

            # configure invokeID
            # @param id [integer, symbol]            
            def invokeID(id)

                if id == :generate
                    @invokeID = 0
                else
                    @invokeID = id.to_i & 0x7fffff
                end

            end

            # configure confirmed mode (default true)
            # @param mode [Boolean]
            def confirmed(mode)
                @confirmed = (mode ? true : false)
            end

            # configure breakOnError mode (default false)
            # @param mode [Boolean]
            def breakOnError(mode)
                @breakOnError = (mode ? true : false)
            end

            # configure selfDescribe mode (default false)
            # @param mode [Boolean]
            def selfDescribe(mode)
                @selfDescribe = (mode ? true : false)
            end

            # configure timestamp field (default is empty)
            # @param time [DateTime, Symbol] :now or a DateTime
            def timeStamp(time)
                if time == :now
                    @timeStamp = DDateTime.new(DateTime.now)
                else
                    @timeStamp = DDateTime.new(time)
                end
            end

    end

end
