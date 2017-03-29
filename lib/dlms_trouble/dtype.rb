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

    module DType

        class DTypeError < Exception
        end

        # factory method to produce data instances from input
        #
        # @param input [StringIO]
        # @raise [DTypeError]
        # @return [DType] subclass instances
        def self.from_axdr(input)
            
            if input.kind_of? String
                input = StringIO.new(input)
            end
            
            begin
                _tag = input.read(1).unpack("C").first                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end

            tagToType(_tag).from_axdr(input)
            
        end

        # @param symbol [Symbol] symbol from schema
        # @return equivalent DType subclass
        def self.symbolToType(symbol)

            s = symbol.to_s
            if symbol == :bcd
                s = "BCD"
            else
                s[0] = s[0].upcase
            end
            cls = const_get(s)
            if cls.nil?
                raise DTypeError.new "symbol '#{}' does not map to a DType type"
            end
            cls
            
        end

        # @param tag [Integer] xDLMS-APDU.DType tag
        # @return DType subclass
        def self.tagToType(tag)
            cls = DType.types.detect{|sub|sub.tag == tag}
            if cls.nil?
                raise DTypeError.new "#{tag} is not a recognised DType tag"
            end
            cls
        end

        # xDLMS-APDU.DType base type
        class DType

            @subs = []

            def self.types
                if self != DType
                    raise NoMethodError
                else
                    @subs
                end
            end

            def self.tagToType(tag)
                DLMSTrouble::DType.tagToType(tag)
            end
            
            # use inherited callback to build up a list of the subclasses
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
                else
                    @value = value
                end
            end

            # @return [Integer] xDLMS-APDU.DType tag of this class
            def self.tag
                if self == DType
                    raise NoMethodError
                else   
                    @tag
                end
            end

            # @return [Integer] xDLMS-APDU.DType tag of this instance
            def tag             
                self.class.tag
            end

            # @return [String] xDLMS-APDU.DType tag of this instance encoded in axdr
            def axdr_tag
                [tag].pack("C")
            end

            def ==(other)
                other.kind_of?(DType) and @value == other.value                
            end

            def self.===(other)
                self == other
            end
               
            def putTypeDescription
                axdr_tag
            end

        end

    end
        
end

require 'dlms_trouble/d_null_data'
require 'dlms_trouble/d_array'
require 'dlms_trouble/d_structure'
require 'dlms_trouble/d_bit_string'
require 'dlms_trouble/d_octet_string'
require 'dlms_trouble/d_visible_string'
require 'dlms_trouble/d_utf8_string'
require 'dlms_trouble/d_integer'
require 'dlms_trouble/d_double_long'
require 'dlms_trouble/d_double_long_unsigned'
require 'dlms_trouble/d_bcd'
require 'dlms_trouble/d_boolean'
require 'dlms_trouble/d_long'
require 'dlms_trouble/d_unsigned'
require 'dlms_trouble/d_long_unsigned'
require 'dlms_trouble/d_compact_array'
require 'dlms_trouble/d_long64'
require 'dlms_trouble/d_long64_unsigned'
require 'dlms_trouble/d_enum'
require 'dlms_trouble/d_float32'
require 'dlms_trouble/d_float64'
require 'dlms_trouble/d_floating_point'
require 'dlms_trouble/d_date_time'
require 'dlms_trouble/d_date'
require 'dlms_trouble/d_time'
require 'dlms_trouble/d_dont_care'
