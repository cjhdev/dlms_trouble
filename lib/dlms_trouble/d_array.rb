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

    class DArray < DType

        @tag = 1

        def initialize(*value)

            @value = Array.new
            
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

        def to_axdr(**opts)
            out = ""
            if !opts[:packed]
                out << axdr_tag
                out << AXDR::putSize(@value.size)
            end
            @value.each do |sub|
                out << sub.to_axdr(opts)
            end
            out
        end

        def putTypeDescription
            out = axdr_tag
            if @value.size > 0xffff
                raise DTypeError.new "cannot express TypeDescription for an DArray larger than 0xffff elements"
            end
            out << [@value.size].pack("S>")                
            @value.each do |v|
                out << v.putTypeDescription
            end
            out
        end

        def size
            @value.size
        end

        def each
            @value.each
        end

        def each_with_index
            @value.each_with_index
        end

        def to_native
            @value.inject([]).each do |out, v|
                out << v.to_native
            end        
        end

        def self.from_axdr!(input, **opts)
            begin
                super
                out = self.new
                if opts[:packed]
                    size = AXDR::getSize!(opts[:typedef])                        
                else
                    size = AXDR::getSize!(input)
                end
                while out.size < size do

                    if !opts[:packed]
                        tag = input.slice(0).unpack("C").first                        
                    else
                        tag = opts[:typedef].slice!(0).unpack("C").first
                    end

                    out << tagToClass(tag).from_axdr!(input, opts)
                    
                end
                out
            rescue
                raise DTypeError
            end
        end

    end

end
