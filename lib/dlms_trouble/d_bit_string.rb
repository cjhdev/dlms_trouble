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

    class DBitString < DType

        @tag = 4

        def initialize(*value)

            @value = []

            if value.size == 1

                case value.first.class.name
                when "Array"
                    value.first.each do |v|
                        @value << ( v ? true : false )
                    end                
                else
                    @value << ( value ? true : false)
                end

            else

                value.each do |v|
                    @value << ( v ? true : false )                    
                end
                
            end

        end

        def to_axdr(**opts)
            out = opts[:packed] ? "" : axdr_tag
            out << AXDR::putSize(@value.size)

            buf = 0
            
            @value.each_with_index do |v,i|

                case i % 8
                when 0
                    buf = 0
                    buf += ( (v == true) ? 0x80 : 0x00)                    
                when 1
                    buf += ( (v == true) ? 0x40 : 0x00)
                when 2
                    buf += ( (v == true) ? 0x20 : 0x00)
                when 3
                    buf += ( (v == true) ? 0x10 : 0x00)
                when 4
                    buf += ( (v == true) ? 0x08 : 0x00)
                when 5
                    buf += ( (v == true) ? 0x04 : 0x00)
                when 6
                    buf += ( (v == true) ? 0x02 : 0x00)                    
                when 7
                    buf += ( (v == true) ? 0x01 : 0x00)
                    out << [buf].pack("C")                
                end
                    
            end

            if (@value.size % 8) != 0
                out << [buf].pack("C")
            end

            out
            
        end

        def size
            @value.size
        end

        def to_native
            @value.to_a
        end

        def self.from_axdr!(input, typedef=nil)
            begin
                if typedef
                    _tag = typedef.slice!(0).unpack("C").first
                else
                    _tag = input.slice!(0).unpack("C").first
                end
                bitSize = AXDR::getSize!(input)
                byteSize = ( (bitSize / 8 ) + (((bitSize % 8) == 0) ? 0 : 1) )
                val = input.slice!(0,byteSize).unpack("C#{byteSize}")                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end                        
            if _tag != @tag
                raise DTypeError.new "decode #{self}: expecting tag #{@tag} but got #{_tag}"
            end

            buf = []

            val.each do |v|

                buf << ((v & 0x80) == 0x80) ? true : false
                buf << ((v & 0x40) == 0x40) ? true : false
                buf << ((v & 0x20) == 0x20) ? true : false
                buf << ((v & 0x10) == 0x10) ? true : false
                buf << ((v & 0x08) == 0x08) ? true : false
                buf << ((v & 0x04) == 0x04) ? true : false
                buf << ((v & 0x02) == 0x02) ? true : false
                buf << ((v & 0x01) == 0x01) ? true : false

            end

            if (bitSize % 8) != 0

                tail = 8 - (bitSize % 8)

                buf.reverse_each do |v|

                    if tail == 0
                        break
                    end

                    if v == true
                        
                        raise DTypeError.new "padding bits in bit-string must be zero"
                    end

                    buf.delete_at(buf.size-1)
                    tail -= 1
                    
                end

            end

            self.new(buf)
            
        end

    end

end
