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

    class DInteger < DType
        
        @tag = 15
        @minValue = -128
        @maxValue = 127

        def initialize(value)
            super(value.to_i)                
            if value.to_i < self.class.minValue or value.to_i > self.class.maxValue
                raise DTypeError.new "valid initialisation value for #{self.class} container must be within range #{self.class.minValue}..#{self.class.maxValue}"
            end            
        end

        def to_axdr(**opts)
            out = opts[:packed] ? "" : axdr_tag
            out << [@value].pack("c")
        end

        def self.from_axdr!(input, **opts)
            super
            begin
                self.new(input.slice!(0).unpack("c").first)
            rescue
                raise DTypeError
            end            
        end

        def to_native
            @value.to_i
        end

        private_class_method

            def self.minValue
                @minValue
            end
            def self.maxValue
                @maxValue
            end
        
    end

end
