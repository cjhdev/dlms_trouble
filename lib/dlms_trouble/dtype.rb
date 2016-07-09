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

    class DTypeError < Exception
    end

    class DType

        @subs = []

        def self.tagToClass(tag)
            @subs.select do |sub|
                sub.tag == tag
            end.first
        end
        
        def self.inherited(subclass)
            if self == DType
                @subs << subclass            
            else                
                superclass.inherited(subclass)
            end
        end

        attr_reader :value

        # @param value native type/value to wrap
        def initialize(value)
            if self.class == DType
                raise NoMethodError
            end
            @value = value            
        end

        # @return [Integer]
        def self.tag
            if self == DType
                raise NoMethodError
            elsif @tag.nil?
                raise "where is the tag?"
            end            
            @tag
        end

        # @param symbol [Symbol]
        # @return equivalent DType subclass
        def self.mapSymbolToType(symbol)
            s = symbol.to_s
            if symbol == :bcd
                s = "BCD"
            else
                s[0] = s[0].upcase
            end
            DLMSTrouble::const_get("D" + s)
        end

        def self.from_axdr!(input, **opts)
            if opts[:packed]
                begin
                    tag = input.slice!(0).unpack("C").first
                rescue
                    raise DTypeError
                end

                if tag != @tag
                    raise DTypeError
                end
            end               
        end

        # @return [Integer]
        def tag            
            self.class.tag
        end

        # @return [String] serialised AXDR tag for this type
        def axdr_tag
            [tag].pack("C")
        end

        def ==(other)
            if other.kind_of?(DType) and @value == other.value
                true
            else
                false
            end
        end

        def self.===(other)
            self == other
        end
           
        def putTypeDescription
            axdr_tag
        end

    end
        
end

require 'dlms_trouble/d_null_data'
require 'dlms_trouble/d_array'
require 'dlms_trouble/d_structure'
require 'dlms_trouble/d_boolean'
require 'dlms_trouble/d_bit_string'
require 'dlms_trouble/d_double_long'
require 'dlms_trouble/d_double_long_unsigned'
require 'dlms_trouble/d_floating_point'
require 'dlms_trouble/d_octet_string'
require 'dlms_trouble/d_visible_string'
require 'dlms_trouble/d_utf8_string'
require 'dlms_trouble/d_bcd'
require 'dlms_trouble/d_integer'
require 'dlms_trouble/d_long'
require 'dlms_trouble/d_unsigned'
require 'dlms_trouble/d_long_unsigned'
require 'dlms_trouble/d_compact_array'
require 'dlms_trouble/d_long64'
require 'dlms_trouble/d_long64_unsigned'
require 'dlms_trouble/d_enum'
require 'dlms_trouble/d_float32'
require 'dlms_trouble/d_float64'
require 'dlms_trouble/d_date_time'
require 'dlms_trouble/d_date'
require 'dlms_trouble/d_time'
require 'dlms_trouble/d_dont_care'
