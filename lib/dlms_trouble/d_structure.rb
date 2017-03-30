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

    class Structure < Array

        @tag = 2

        def push(value)
            @value.push(value)
        end

        alias << push

        def putTypeDescription
            out = axdr_tag
            out << AXDR::Length.new(@value.size).encode
            @value.inject(out) do |acc, v|
                acc << v.putTypeDescription
            end            
        end

        def self.from_axdr(input, typedef=nil)

            begin
                if typedef
                    _size = DLMSTrouble::AXDR::Length.decode(typedef).value
                else
                    _size = DLMSTrouble::AXDR::Length.decode(input).value
                end                                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end
            
            out = self.new
            
            while out.size < _size do
                out << tagToType(((typedef ? typedef : input).read(1).unpack("C").first)).from_axdr(input, typedef)                
            end

            out

        end

    end

end
