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

    class Array < DType

        @tag = 1

        def initialize(*value)
            @value = []
            value.each do |v|
                self.push(v)
            end            
        end

        def push(value)

            if value.kind_of?(DType)
                if @value.size == 0 or value.class == @value.last.class
                    @value.push(value)                    
                else
                    raise DTypeError.new "element in array must be same as all other elements in array"
                end
            else
                raise DTypeError.new "element must be a DType subclass"
            end
                               
        end

        alias << push

        def encode(**opts)
            out = ""
            if !opts[:packed]
                out << axdr_tag
                out << DLMSTrouble::AXDR::Length.new(@value.size).encode
            end
            @value.inject(out) do |acc,v|
                acc << v.encode(opts)
            end
        end

        def putTypeDescription
            out = axdr_tag
            if @value.size > 0xffff
                raise DTypeError.new "cannot express TypeDescription for an DType::Array larger than 0xffff elements"
            end
            out << [@value.size].pack("S>")
            @value.first.putTypeDescription            
        end

        def size
            @value.size
        end

        def to_native
            @value.inject([]) do |out, v|
                out << v.to_native
            end        
        end

        def self.decode(input, typedef=nil)
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

            if typedef

                _tag = typedef.read(1).unpack("C").first

            end

            
            while out.size < _size do
                if typedef                
                    if out.size == (_size - 1)
                        out << tagToType(_tag).decode(input, typedef)
                    else
                        out << tagToType(_tag).decode(input, typedef.dup)
                    end                    
                else
                    _tag = input.read(1).unpack("C").first
                    out << tagToType(_tag).decode(input)                
                end
            end

            out

        end

    end

end
