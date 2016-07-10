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

require 'dlms_trouble/d_integer'

module DLMSTrouble

    class DLong64Unsigned < DInteger

        @tag = 21
        @minValue = 0
        @maxValue = 18446744073709551615

        def to_axdr(**opts)
            out = opts[:packed] ? "" : axdr_tag
            out << [@value].pack("Q>")
        end

        def self.from_axdr!(input, typedef=nil)
            begin
                if typedef
                    _tag = typedef.slice!(0).unpack("C").first
                else
                    _tag = input.slice!(0).unpack("C").first
                end
                val = input.slice!(0,8).unpack("Q>").first
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end                        
            if _tag != @tag
                raise DTypeError.new "decode #{self}: expecting tag #{@tag} but got #{_tag}"
            end
            self.new(val)            
        end

    end

end
