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
require 'dlms_trouble/dtype'
require 'dlms_trouble/access_error'

module DLMSTrouble

    class AccessRequestSet

        TAG = 2

        def initialize(classID, instanceID, methodID, data)
            @classID = classID.to_i
            @instanceID = OBIS.new(instanceID.to_s)
            @methodID = methodID
            @data = data
        end

        def self.tag
            TAG
        end

        def tag
            TAG
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

end

