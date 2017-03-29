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

module DLMSTrouble::DType

    class OctetString < DType

        @tag = 9

        def initialize(value)
            super(value.to_s)
        end

        def to_axdr(**opts)
            out = opts[:packed] ? "" : axdr_tag
            out << DLMSTrouble::AXDR::putSize(@value.size)
            out << @value
        end

        def self.from_axdr(input, typedef=nil)
            begin
                _size = DLMSTrouble::AXDR::getSize(input)
                val = input.read(_size)
                if val.size != _size
                    raise
                end                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end                        
            self.new(val)            
        end

        def size
            @value.size
        end

        def to_native
            @value.to_s
        end

    end

end
