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

module DLMSTrouble::DType

    class CompactArray < Array

        @tag = 19

        def push(value)
            if value.kind_of? self.class
                raise DTypeError.new "cannot nest compact array"
            end
            super(value)                
        end

        alias << push

        def encode(**opts)

            out = opts[:packed] ? ( raise ) : axdr_tag

            out << @value.first.putTypeDescription

            data = ""

            @value.each do |v|
                data << v.encode(packed: true)
            end

            out << DLMSTrouble::AXDR::Length.new(data.size).encode
            out << data
            
        end

        def self.decode(input)

            out = self.new

            typedef = StringIO.new(parseTypeDescription(input))

            _size = DLMSTrouble::AXDR::Length.decode(input).value

            packedInput = StringIO.new(input.read(_size))
            
            if packedInput.size != _size
                raise DTypeError.new "input too short"
            end

            while packedInput.pos < packedInput.size do

                typedef.rewind

                _tag = typedef.read(1).unpack("C").first

                out << tagToType(_tag).decode(packedInput, typedef)
                
            end
            out
        end

        def put_typeDescription
            raise DTypeError.new "cannot nest compact array"
        end

        

            # @param input [String] 
            # @return [String] parsed packed array typeDescription
            def self.parseTypeDescription(input)

                begin

                    out = input.read(1)

                    case tagToType(out.unpack("C").first)
                    when Array
                        _size = input.read(2).unpack("S>").first
                        out << DLMSTrouble::AXDR::Length.new(_size).encode
                        out << parseTypeDescription(input)                            
                    when Structure
                        _size = DLMSTrouble::AXDR::Length.decode(input).value
                        out << DLMSTrouble::AXDR::Length.new(_size).encode
                        while _size > 0 do
                            out << parseTypeDescription(input)
                            _size = _size - 1
                        end           
                    when CompactArray
                        raise DTypeError.new "nested compactArray not allowed"
                    end

                rescue
                    raise DTypeError.new "cannot parse compactArray typeDescription"
                end

                out

            end

        
    end

end
