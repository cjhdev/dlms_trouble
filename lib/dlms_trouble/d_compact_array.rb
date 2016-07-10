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

module DLMSTrouble

    class DCompactArray < DArray

        @tag = 19

        def push(value)
            if value.kind_of? self.class
                raise DTypeError.new "cannot nest compact array"
            end
            super(value)                
        end

        alias << push

        def to_axdr(**opts)

            out = opts[:packed] ? ( raise ) : axdr_tag

            out << @value.first.putTypeDescription

            data = ""

            @value.each do |v|
                data << v.to_axdr(packed: true)
            end

            out << AXDR::putSize(data.size)
            out << data
            
        end

        def self.from_axdr!(input)
            begin
                _tag = input.slice!(0).unpack("C").first                                    
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end                        
            if _tag != @tag
                raise DTypeError.new "decode #{self}: expecting tag #{@tag} but got #{_tag}"
            end

            out = self.new

            typedef = parseTypeDescription!(input)

            _size = AXDR::getSize!(input)

            packedInput = input.slice!(0, _size)
            if packedInput.size != _size
                raise DTypeError.new "input too short"
            end

            while packedInput.size != 0 do

                _tag = typedef.slice(0).unpack("C").first                
                out << DType::tagToClass(_tag).from_axdr!(packedInput, typedef.dup)
                
            end
            out
        end

        def put_typeDescription
            raise DTypeError.new "cannot nest compact array"
        end

        private_class_method

            # @param input [String] 
            # @return [String] parsed packed array typeDescription
            def self.parseTypeDescription!(input)

                begin

                    out = input.slice(0)

                    case DType::tagToClass(input.slice!(0).unpack("C").first)
                    when DArray
                        _size = input.slice!(0,2).unpack("S>").first
                        out << AXDR::putSize(_size)
                        out << parseTypeDescription!(input)                            
                    when DStructure
                        _size = AXDR::getSize!(input)
                        out << AXDR::putSize(_size)
                        while _size > 0 do
                            out << parseTypeDescription!(input)
                            _size -= 1
                        end           
                    when DCompactArray
                        raise DTypeError.new "nested compactArray not allowed"
                    end

                rescue
                    raise DTypeError.new "cannot parse compactArray typeDescription"
                end

                out

            end

        
    end

end
