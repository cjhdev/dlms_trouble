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

    class DBitString < DType

        @tag = 4

        def initialize(value)
            super(value.to_a)
        end

        def to_axdr(**opts)
            out = opts[:packed] ? "" : axdr_tag
            out << AXDR::putSize(@value.size)

            buf = 0
            @value.each_with_index do |v,i|
                if i % 8
                    buf = 0
                end
                if v
                    buf |= 1 << (i % 8)
                end
                if (i % 8) == 7
                    out << buf
                end                
            end

            if @value.size % 8
                out << buf
            end
               
            out << @value
        end

        def size
            @value.size
        end

        def to_native
            @value.to_a
        end

    end

end
