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

    # Everything to handle moving between native types and AXDR.
    #
    #
    module AXDR

        TAGS = {
            0 => :DNullData,
            1 => :DArray,
            2 => :DStructure,
            3 => :DBoolean,
            4 => :DBitString,
            5 => :DDoubleLong,
            6 => :DDoubleLongUnsigned,
            7 => :DFloatingPoint,
            9 => :DOctetString,
            10 => :DVisibleString,
            13 => :DBCD,
            15 => :DInteger,
            16 => :DLong,
            17 => :DUnsigned,
            18 => :DLongUnsigned,
            19 => :DCompactArray,
            20 => :DLong64,
            21 => :DLong64Unsigned,
            22 => :DEnum,
            23 => :DFloat32,
            24 => :DFloat64,
            25 => :DDateTime,
            26 => :DDate,
            27 => :DTime
        }

        class EncodingError < Exception
        end

        # These types exist so we can keep axdr meta data around
        class DType

            attr_reader :value

            # @param value native type/value to wrap
            def initialize(value)
                @value = value
            end

            # @return [Integer]
            def self.tag
                TAGS.key(self.name.split('::').last.to_sym)
            end

            # @return [Integer]
            def tag
                self.class.tag
            end

            def ===(other)
                @value === (other.respond_to?("is_a_dtype?".to_sym, true) ? other.value : other)
            end

            def <=>(other)
                
                @value <=> (other.respond_to?("is_a_dtype?".to_sym, true) ? other.value : other)
            end

            def ==(other)
                @value == (other.respond_to?("is_a_dtype?".to_sym, true) ? other.value : other)
            end
=begin
            def kind_of?(klass)
                @value.kind_of?(klass)
            end
=end            

            def to_s
                @value.to_s
            end

            # bypass to wrapped value methods
            def method_missing(name, *args, &blk)
                @value.send(name, *args, &blk)                
            end

            # factory method to produce DType instances from input
            #
            # @param input [String] slices from this string
            # @raise [EncodingError]
            def self.from_axdr!(input)

                out = []
                stack = []

                begin

                    if stack.size > 0
                        out = stack.last[:type]
                    end

                    type = DLMSTrouble::AXDR.const_get(TAGS[input.slice!(0).unpack("C").first])
                    
                    case TAGS[type.tag]
                    when :DArray, :DStructure
                        stack.push({:type => type.new([]), :size => AXDR::getSize!(input)})                        
                    when :DNullData
                        out << type.new
                    when :DVisibleString, :DOctetString
                        type.new(input.slice!(0, AXDR::getSize!(input)))
                    when :DBoolean
                        case input.slice!(0).unpack("C").first
                        when nil
                            raise EncodingError
                        when 0
                            out << type.new(false)
                        else
                            out << type.new(true)
                        end                
                    when :DInteger
                        out << type.new(input.slice!(0).unpack("c").first)
                    when :DLong
                        out << type.new(input.slice!(0,2).unpack("s>").first)
                    when :DDoubleLong
                        out << type.new(input.slice!(0,4).unpack("l>").first)
                    when :DLong64
                        out << type.new(input.slice!(0,8).unpack("q>").first)
                    when :DEnum, :DUnsigned
                        out << type.new(input.slice!(0).unpack("C").first)
                    when :DLongUnsigned
                        out << type.new(input.slice!(0,2).unpack("S>").first)
                    when :DDoubleLongUnsigned
                        out << type.new(input.slice!(0,4).unpack("L>").first)
                    when :DLong64Unsigned
                        out << type.new(input.slice!(0,8).unpack("Q>").first)
                    when :DFloat32, :DFloatingPoint
                        out << type.new(input.slice!(0,4).unpack("g").first)
                    when :DFloat64
                        out << type.new(input.slice!(0,8).unpack("G").first)
                    else
                        raise EncodingError
                    end

                    if stack.size > 0 and out.size == stack.last[:size]
                        stack.pop
                    end

                end while stack.size > 0
            
                out.pop

            end

            # convert DType subtype instance to axdr stream
            def self.to_axdr(data)

                out = ""
                stack = []
                value = data

                begin

                    loop do

                        if stack.size > 0

                            begin
                                value = stack.last.next
                            rescue StopIteration, UndefinedMethod
                                break
                            end
                        end

                        out << [value.tag].pack("C")

                        case TAGS[value.tag]
                        when :DArray, :DStructure
                            out << AXDR::putSize(value.size)
                            stack.push(value.each)
                        when :DNullData
                            out << ""
                        when :DBoolean
                            if value.value
                                out << [1].pack("C")
                            else
                                out << [0].pack("C")
                            end
                        when :DVisibleString, :DOctetString
                            out << AXDR::putSize(value.size)
                            out << value
                        when :DInteger
                            out << [value].pack("c")
                        when :DLong
                            out << [value].pack("s>")
                        when :DDoubleLong
                            out << [value].pack("l>")
                        when :DLong64
                            out << [value].pack("q>")
                        when :DEnum, :DUnsigned
                            out << [value].pack("C")
                        when :DLongUnsigned
                            out << [value].pack("S>")
                        when :DDoubleLongUnsigned
                            out << [value].pack("L>")
                        when :DLong64Unsigned
                            out << [value].pack("Q>")
                        when :DFloat32, :DFloatingPoint
                            out << [value.value].pack("g")
                        when :DFloat64
                            out << [value.value].pack("G")
                        else
                            raise "incomplete feature #{value.class}"
                        end

                        if stack.size == 0; break end

                    end

                    stack.pop

                end while stack.size > 0

                out

            end

            protected

                def is_a_dtype?
                    true
                end
            
        end

        class DVisibleString < DType
        end

        class DOctetString < DType
        end

        class DEnum < DType
        end

        class DFloat32 < DType
            def initialize(value)
                super([value].pack("g").unpack("g").first)
            end
        end
        class DFloat64 < DType
        end
        class DFloatingPoint < DType
            def initialize(value)
                super([value].pack("g").unpack("g").first)
            end
        end

        class DNullData < DType
            def initialize
                super(nil)
            end
        end

        class DBoolean < DType        
        end

        class DInteger < DType
            def initialize(value)
                raise EncodingError if !value.kind_of? Integer
                super(value)
            end            
        end

        class DLong < DInteger
        end

        class DDoubleLong < DInteger
        end

        class DLong64 < DInteger
        end

        class DUnsigned < DInteger
        end
        
        class DLongUnsigned < DInteger
        end

        class DDoubleLongUnsigned < DInteger            
        end

        class DLong64Unsigned < DInteger
        end

        class DArray < DType            
        end
        
        class DCompactArray < DType           
        end

        class DStructure < DType
        end

        class DDateTime < DType
        end

        class DTime < DType
        end

        class DDate < DType
        end

        
        # @param size [Integer]
        # @return [Integer] byte length to encode size
        def self.sizeSize(size)

            if size < 0x80
                return 1
            else
                max = 0x100
                bytes = 2

                loop do

                    if size < max
                        return bytes
                    end

                    bytes += 1
                    max = max << 8

                end
            end
        end

        # @param size [Integer]
        # @return [String] encoded size
        def self.putSize(size)

            bytes = sizeSize(size.to_i)
            out = Array.new(bytes)

            if bytes == 1
                out[0] = size
            else
                out.each_with_index do |v,i|
                    if i == 0
                        out[i] = 0x80 + bytes - 1
                    else
                        out[i] = size >> ((bytes - i - 1)*8)
                    end
                end
            end

            out.pack("C#{bytes}")
        end       

        # @param input [String]
        # @return [Integer] decoded size
        # @raise [EncodingError]
        def self.getSize!(input)

            size = 0
            lead = input.slice!(0).unpack("C").first

            if lead.nil? or lead == 0x80
                raise EncodingError
            elsif lead < 0x80
                size = lead
            else
                input.slice!(0, lead & 0x7f).unpack("C#{lead & 0x7f}").each do |v|
                    if v.nil?; raise EncodingError end
                    size = (size << 8) | v            
                end
            end

            size
                            
        end
        
    end
end
