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

    class ApplicationContextName

        SN_REFERENCING = "\x60\x85\x74\x05\x08\x01\x02".freeze
        LN_REFERENCING = "\x60\x85\x74\x05\x08\x01\x01".freeze

        attr_reader :referencing

        def self.decode(input)

            id = BER::Identifier.decode(input)

            if id.cls != :UNIVERSAL or !id.primitive? or id.tag !=
                raise
            end

            length = BER::Length.decode(input)
    
            result = input.read(length.value)

            if result.size != length.value
                raise
            end

            case result
            when SN_REFERENCING
                ShortNames.new            
            when LN_REFERENCING
                LongNames.new
            else
                raise
            end

        end        
    end

    class LongNames < ApplicationContextName
        def encode
            LN_REFERENCING
        end
    end

    class ShortNames < ApplicationContextName
        def encode
            SN_REFERENCING
        end
    end
    

end
