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

    class Ciphered

        attr_reader :header, :ic, :payload

        def self.decode(input)

            length = AXDR::Length.decode(input)
            buffer = input.read(length.value)

            stream = StreamIO.new(buffer)

            header = SecurityHeader.decode(stream)
            ic = stream.read(4)
            if ic.size != 4
                raise
            end

            payload = stream.read(stream.size - stream.pos)            

            self.new(sc, ic, payload)
        
        end

        def initialize(header, ic, payload)
            @header = header
            @ic = ic
            @payload = payload
        end

        def encode
            buffer = @header.encode
            buffer << [@ic].pack(">L")
            buffer << payload
        end

    end

end


