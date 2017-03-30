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

    class WPDU

        attr_reader :src, :dst, :payload

        def self.decode(input)

            buffer = input.read(8).unpack("S>S>S>S>").each

            if buffer.next != 1
                raise "expecting version 1"
            end

            src = buffer.next
            dst = buffer.next
            size = buffer.next

            payload = input.read(size)

            if payload.size != size
                raise "EOF"
            end

            self.new(src, dst, payload)

        end

        def initialize(src, dst, payload)
            @src = src
            @dst = dst
            @payload = payload.freeze
            @version = 1            
        end

        def encode
            [@version, @src, @dst, @payload.size].pack("S>S>S>S>") << @payload            
        end
    
    end

end
