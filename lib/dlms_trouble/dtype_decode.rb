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

require 'dlms_trouble/axdr'
require 'dlms_trouble/dtype'

module DLMSTrouble

    class DTypeDecode

        # factory method to produce DType instances from input
        #
        # @param input [String] slices from this string
        # @raise [DTypeError]
        # @return DType subclass instances
        def self.from_axdr(input, **opts)
            s = input.to_s
            from_axdr!(s, **opts)            
        end

        ############################################################
        private_class_method

            def self.from_axdr!(input, **opts)

                out = nil
                klass = nil
                
                if !opts[:packed]
                    klass = DType.klassFromTag(input.slice!(0).unpack("C").first)
                else
                    klass = DType.klassFromTag(opts[:typedef].slice!(0).unpack("C").first)
                end

                case klass
                when DArray, DStructure

                    out = klass.new

                    if opts[:packed]
                        size = AXDR::getSize!(opts[:typedef])                        
                    else
                        size = AXDR::getSize!(input)
                    end
                    
                    index = 0
                    while index < size do
                        out << from_axdr!(input)
                        index += 1
                    end
                
                when DCompactArray

                    out = klass.new

                    if opts[:packed]
                        raise DTypeError.new "nested packed array not valid"
                    end

                    typedef = parseTypeDescription!(input)
                    opts[:packed] = true
                    size = AXDR::getSize!(input)

                    packedInput = input.slice!(0, size)

                    while packedInput.size != 0 do

                        opts[:typedef] = typedef.dup
                        out << from_axdr!(packedInput, opts)

                    end
                when DNullData, DDontCare
                    out = klass.new
                when DVisibleString, DOctetString, DUTF8String
                    out = klass.new(input.slice!(0, AXDR::getSize!(input)))
                when DBitString
                    raise "todo"                
                when DBoolean
                    case input.slice!(0).unpack("C").first
                    when nil
                        raise DTypeError
                    when 0
                        out = klass.new(false)
                    else
                        out = klass.new(true)
                    end                    
                when DInteger, DBCD
                    out = klass.new(input.slice!(0).unpack("c").first)
                when DLong
                    out = klass.new(input.slice!(0,2).unpack("s>").first)
                when DDoubleLong
                    out = klass.new(input.slice!(0,4).unpack("l>").first)
                when DLong64
                    out = klass.new(input.slice!(0,8).unpack("q>").first)
                when DEnum, DUnsigned
                    out = klass.new(input.slice!(0).unpack("C").first)
                when DLongUnsigned
                    out = klass.new(input.slice!(0,2).unpack("S>").first)
                when DDoubleLongUnsigned
                    out = klass.new(input.slice!(0,4).unpack("L>").first)
                when DLong64Unsigned
                    out = klass.new(input.slice!(0,8).unpack("Q>").first)
                when DFloat32, DFloatingPoint
                    out = klass.new(input.slice!(0,4).unpack("g").first)
                when DFloat64
                    out = klass.new(input.slice!(0,8).unpack("G").first)
                when DDateTime
                    raise "todo"
                when DDate
                    raise "todo"
                when DTime
                    raise "todo"
                else
                    raise "what is #{klass}"
                end

                out

            end

            # @return [String] parsed packed array typeDescription
            def self.parseTypeDescription!(typeDescription)

                out = typeDescription.slice(0)
                
                case DType.klassFromTag(typeDescription.slice!(0).unpack("C").first)
                when DArray
                    out << typeDescription.slice(0,2)
                    size = typeDescription.slice!(0,2).unpack("S>").first
                    index = 0
                    while index < size do
                        out << __method__(typeDescription)
                        index += 1
                    end                    
                when DStructure
                    size = AXDR::getSize!(typeDescription)
                    out << AXDR::putSize(size)
                    index = 0
                    while index < size do
                        out << __method__(typeDescription)
                        index += 1
                    end           
                when DCompactArray
                    raise DTypeError.new "nested packed array not allowed"
                end

                out
        
            end

    end

end
