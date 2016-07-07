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

    module Data

        class EncodingError < Exception
        end

        class DType

            # encoding tags mapped to DType subclasses
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

            attr_reader :value

            # @param value native type/value to wrap
            def initialize(value)
                @value = value
            end

            # @return [Integer]
            def self.tag
                out = TAGS.key(self.name.split('::').last.to_sym)
                if out.nil?; raise end
                out
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

            def putTypeDescription
                axdr_tag
            end

            # factory method to produce DType instances from input
            #
            # @param input [String] slices from this string
            # @raise [EncodingError]
            # @return DType subclass instances
            def self.from_axdr!(input, **opts)

                out = nil
                tag = nil

                if !opts[:packed]
                    tag = TAGS[input.slice!(0).unpack("C").first]
                else
                    tag = opts[:typedef].slice!(0).unpack("C").first
                end

                type = Data.const_get(TAGS[tag])

                case TAGS[type.tag]
                when :DArray, :DStructure
                    out = type.new

                    if opts[:packed]
                        size = Data::getSize!(opts[:typedef])                        
                    else
                        size = DatagetSize!(input)
                    end
                    
                    index = 0
                    while index < size do
                        out << from_axdr!(input)
                        index += 1
                    end
                
                when :DCompactArray

                    out = type.new

                    if opts[:packed]
                        raise "nested packed array not valid"
                    end

                    typedef = parseTypeDescription!(input)
                    opts[:packed] = true
                    size = DatagetSize!(input)

                    packedInput = input.slice!(0, size)

                    while packedInput.size != 0 do

                        opts[:typedef] = typedef.dup
                        out << from_axdr!(input, opts)

                    end
                when :DNullData
                    out = type.new
                when :DVisibleString, :DOctetString
                    type.new(input.slice!(0, DatagetSize!(input)))
                when :DBoolean
                    case input.slice!(0).unpack("C").first
                    when nil
                        raise EncodingError
                    when 0
                        out = type.new(false)
                    else
                        out = type.new(true)
                    end                    
                when :DInteger
                    out = type.new(input.slice!(0).unpack("c").first)
                when :DLong
                    out = type.new(input.slice!(0,2).unpack("s>").first)
                when :DDoubleLong
                    out = type.new(input.slice!(0,4).unpack("l>").first)
                when :DLong64
                    out = type.new(input.slice!(0,8).unpack("q>").first)
                when :DEnum, :DUnsigned
                    out = type.new(input.slice!(0).unpack("C").first)
                when :DLongUnsigned
                    out = type.new(input.slice!(0,2).unpack("S>").first)
                when :DDoubleLongUnsigned
                    out = type.new(input.slice!(0,4).unpack("L>").first)
                when :DLong64Unsigned
                    out = type.new(input.slice!(0,8).unpack("Q>").first)
                when :DFloat32, :DFloatingPoint
                    out = type.new(input.slice!(0,4).unpack("g").first)
                when :DFloat64
                    out = type.new(input.slice!(0,8).unpack("G").first)
                else
                    raise "unexpected exception"
                end

                out

            end

            ############################################################
            private_class_method

                # @return [String] parsed packed array typeDescription
                def self.parseTypeDescription!(typeDescription)

                    out = typeDescription.slice(0)
                    
                    case TAGS[typeDescription.slice!(0).unpack("C").first]
                    when nil
                        raise "invalid input"
                    when :DArray
                        out << typeDescription.slice(0,2)
                        size = typeDescription.slice!(0,2).unpack("S>").first
                        index = 0
                        while index < size do
                            out << __method__(typeDescription)
                            index += 1
                        end                    
                    when :DStructure
                        size = DatagetSize!(typeDescription)
                        out << DataputSize(size)
                        index = 0
                        while index < size do
                            out << __method__(typeDescription)
                            index += 1
                        end           
                    when :DPackedArray
                        raise "nested packed array not allowed"
                    end

                    out
            
                end

        end

        class DOctetString < DType

            def initialize(value)
                super(value.to_s)
            end

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << Data::putSize(@value.size)
                out << @value
            end

            def size
                @value.size
            end

        end

        class DVisibleString < DOctetString
        end

        class DFloat32 < DType

            def initialize(value)
                super([value.to_f].pack("g").unpack("g").first)
            end

            def to_f
                @value.dup
            end

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("g")
            end
            
        end

        class DFloat64 < DType

            def initialize(value)
                super(value.to_f)
            end

            def to_f
                @value.dup
            end
            
            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("G")
            end
            
        end

        class DFloatingPoint < DFloat32
        end

        class DNullData < DType

            def initialize(value=nil)
                super(nil)
            end

            def to_axdr(**opts)
                opts[:packed] ? "" : axdr_tag
            end

        end

        class DBoolean < DType

            def initialize(value)
                @value = (value) ? true : false
            end
            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [(@value) ? 1 : 0].pack("C")
            end
            
        end

        class DInteger < DType

            @minValue = -128
            @maxValue = 127

            def initialize(value)
                super(value.to_i)
                if @value < self.class.minValue and @value > self.class.minValue
                    raise
                end            
            end

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("c")
            end

            def to_i
                @value.dup
            end

            private_class_method

                def self.minValue
                    @minValue
                end
                def self.maxValue
                    @maxValue
                end
            
        end

        class DEnum < DInteger

            @minValue = 0
            @maxValue = 255

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("C")
            end

        end

        class DLong < DInteger

            @minValue = -32768
            @maxValue = 32767

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("s>")
            end

        end

        class DDoubleLong < DInteger

            @minValue = -2147483648
            @maxValue = 214783647

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("l>")
            end
            
        end

        class DLong64 < DInteger

            @minValue = -9223372036854775808
            @maxValue = 9223372036854775807

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("q>")
            end

        end

        class DUnsigned < DInteger

            @minValue = 0
            @maxValue = 255

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("C")
            end
                
        end

        class DLongUnsigned < DInteger

            @minValue = 0
            @maxValue = 65535

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("S>")
            end

        end

        class DDoubleLongUnsigned < DInteger

            @minValue = 0
            @maxValue = 4294967295

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("L>")
            end

        end

        class DLong64Unsigned < DInteger

            @minValue = 0
            @maxValue = 18446744073709551615

            def to_axdr(**opts)
                out = opts[:packed] ? "" : axdr_tag
                out << [@value].pack("Q>")
            end

        end

        class DArray < DType

            def initialize(*value)

                @value = Array.new
                
                value.each do |v|
                    self.push(v)
                end
                
            end

            def push(value)

                if value.kind_of?(Data::DType)
                    if @value.size == 0 or value.class == @value.last.class
                        @value.push(value)                    
                    else
                        raise "element must be same as all other elements"
                    end
                else
                    "element must be DType"
                end
                                   
            end

            alias << push

            def to_axdr(**opts)
                out = ""
                if !opts[:packed]
                    out << axdr_tag
                    out << Data::putSize(@value.size)
                end
                @value.each do |sub|
                    out << sub.to_axdr(opts)
                end
                out
            end

            def putTypeDescription
                out = axdr_tag
                if @value.size > 0xffff; raise "cannot express TypeDescription for an array larger than 0xffff elements" end
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

        end

        class DCompactArray < DArray

            def push(value)
                if value.kind_of? self.class
                    raise "cannot nest compact array"
                end
                super(value)                
            end

            def to_axdr(**opts)

                out = opts[:packed] ? ( raise "whoops" ) : axdr_tag

                out << @value.first.putTypeDescription

                data = ""

                @value.each do |v|
                    data << v.to_axdr(packed: true)
                end

                out << Data::putSize(data.size)
                out << data
                
            end

            def put_typeDescription
                raise "cannot nest compact array"
            end

        end

        class DStructure < DArray

            def push(value)
                @value.push(value)
            end

            def putTypeDescription
                out = axdr_tag
                out << Data::putSize(@value.size)
                @value.each do |v|
                    out << v.putTypeDescription
                end
                out
            end

        end

        class DDateTime < DType

            attr_reader :year, :month, :dom, :dow, :hour, :min, :sec, :hun, :gmt_offset, :status

            def initialize(value=nil, **arg)

                default = {
                    :year => :undefined,
                    :month => :undefined,
                    :dom => :undefined,
                    :dow => :undefined,
                    :hour => :undefined,
                    :min => :undefined,
                    :sec => :undefined,
                    :hun => :undefined,
                    :gmt_offset => :undefined,
                    :status => :undefined
                }
            
                if value.kind_of? Time

                    default.merge!({
                        :year => value.year,
                        :month => value.month,
                        :dom => value.day,
                        :dow => value.wday,
                        :hour => value.hour,
                        :min => value.min,
                        :sec => value.sec,
                        :hun => value.usec / 1000,
                        :gmt_offset => value.gmt_offset                        
                    })

                elsif value.kind_of? Hash

                    default.merge!(value)

                else

                    raise "cannot handle this input"
                    
                end

                default.merge!(arg)

                @year = default[:year]
                @month = default[:month]
                @dom = default[:dom]
                @dow = default[:dow]
                @hour = default[:hour]
                @min = default[:min]
                @sec = default[:sec]
                @hun = default[:hun]
                @gmt_offset = default[:gmt_offset]
                
            end

            def to_axdr(**opts)
            
                out = super(opts)

                if year == :undefined
                    out << [0xffff].pack("S>")
                else
                    out << [year].pack("S>")
                end
                
                case month
                when :dls_end
                    out << [0xfd].pack("C")
                when :dls_begin
                    out << [0xfe].pack("C")
                when :undefined
                    out << [0xff].pack("C")
                else
                    out << [month].pack("C")
                end
                
                case dom
                when :last_dom
                    out << [0xfe].pack("C")
                when :second_last_dom
                    out << [0xfd].pack("C")
                when :undefined
                    out << [0xff].pack("C")
                else
                    out << [dom].pack("C")
                end
                
                if dow == :undefined
                    out << [0xff].pack("C")
                else
                    out << [dow].pack("C")
                end
                
                if hour == :undefined
                    out << [0xff].pack("C")
                else
                    out << [hour].pack("C")
                end
                
                if min == :undefined
                    out << [0xff].pack("C")
                else
                    out << [min].pack("C")
                end
                
                if sec == :undefined
                    out << [0xff].pack("C")
                else
                    out << [sec].pack("C")
                end
                
                if hun == :undefined
                    out << [0xff].pack("C")
                else
                    out << [hun].pack("C")
                end
                
                if gmt_offset == :undefined
                    out << [0x8000].pack("S>")
                else
                    out << [gmt_offset].pack("S>")
                end
                
                clockStatus
                status.each do |s|
                    case s
                    when :invalidValue
                        clockStatus |=  0x1
                    when :doubtfulValue
                        clockStatus |=  0x2
                    when :differentClockBase
                        clockStatus |=  0x4
                    when :invalidClockStatus
                        clockStatus |= 0x8                            
                    when :dlsActive
                        clockStatus |= 0x80                                    
                    end
                end
                out << [clockStatus].pack("C")
            end
                
        end

        class DTime < DType

            attr_reader :hour, :min, :sec, :hun

            def initialize(value=nil, **arg)

                default = {
                    :hour => :undefined,
                    :min => :undefined,
                    :sec => :undefined,
                    :hun => :undefined
                }
            
                if value.kind_of? Time

                    default.merge!({
                        :hour => value.hour,
                        :min => value.min,
                        :sec => value.sec,
                        :hun => value.usec / 1000
                    })

                elsif value.kind_of? Hash

                    default.merge!(value)
                
                else

                    raise "incomplete feature"
                    
                end

                default.merge!(arg)

                @hour = default[:hour]
                @min = default[:min]
                @sec = default[:sec]
                @hun = default[:hun]
                
            end

            def to_axdr(**opts)
                out = super(opts)

                if data.hour == :undefined
                    out << [0xff].pack("C")
                else
                    out << [data.hour].pack("C")
                end
                if data.min == :undefined
                    out << [0xff].pack("C")
                else
                    out << [data.min].pack("C")
                end
                if data.sec == :undefined
                    out << [0xff].pack("C")
                else
                    out << [data.sec].pack("C")
                end
                if data.hun == :undefined
                    out << [0xff].pack("C")
                else
                    out << [data.hun].pack("C")
                end
            end

        end

        class DDate < DType

            attr_reader :year, :month, :dom, :dow

            def initialize(value=nil, **arg)

                default = {
                    :year => value.year,
                    :month => value.month,
                    :dom => value.day,
                    :dow => value.wday
                }
            
                if value.kind_of? Time

                    default.merge!({
                        :year => value.year,
                        :month => value.month,
                        :dom => value.day,
                        :dow => value.wday
                    })

                elsif default.kind_of? Hash

                    default.merge!(value)
                
                else

                    raise "incomplete feature"
                    
                end

                default.merge!(arg)

                @year = default[:year]
                @month = default[:month]
                @dom = default[:dom]
                @dow = default[:dow]
                
            end

            def to_axdr(**opts)

                out = super(opts)

                if year == :undefined
                    out << [0xffff].pack("S>")
                else
                    out << [year].pack("S>")
                end
                
                case month
                when :dls_end
                    out << [0xfd].pack("C")
                when :dls_begin
                    out << [0xfe].pack("C")
                when :undefined
                    out << [0xff].pack("C")
                else
                    out << [month].pack("C")
                end
                
                case dom
                when :last_dom
                    out << [0xfe].pack("C")
                when :second_last_dom
                    out << [0xfd].pack("C")
                when :undefined
                    out << [0xff].pack("C")
                else
                    out << [dom].pack("C")
                end
                
                if dow == :undefined
                    out << [0xff].pack("C")
                else
                    out << [dow].pack("C")
                end

                out
            end

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

            begin

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

            rescue
                raise EncodingError
            end

            size
                            
        end

    end
        
end