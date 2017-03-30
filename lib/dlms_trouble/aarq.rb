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

    class AARQ

        @tag = BER::Identifier.new(0, cls: :APPLICATION)

        def self.tag
            @tag
        end

        def self.decode(input)

            length = BER::Length.decode(input)

            case length
            when :indefinite
                raise
            else
                input = StringIO.new(input.read(length))
                if input.size != length
                    raise "EOF"
                end                
            end

            # protocol version
            id = Identifier.decode(input)

            if id.tag == 0

            else

                protocolVersion = 0
                id = Identifier.decode(input)

            end

            # application-context-name
            if id.tag == 1

                length = BER::Length.decode(input)
                applicationContextName = ApplicationContextName.decode(StringIO.new(input.read(length)))

                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            
            else
                raise
            end

            if id.tag == 2
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 3
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 4
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 5
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 6
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 7
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 8
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 9
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 10
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 11
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 12
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 29
                length = BER::Length.decode(input)
                input.read(input)
                if input.pos < input.size
                    id = Identifier.decode(input)
                end
            end
            if id.tag == 30
                length = BER::Length.decode(input)
                input.read(input)                
            end

            if input.pos < input.size
                raise "input too short"
            end

            self.new()

        end

        def initialize
            @protocolVersion = 0
        end

        def encode
    
            buffer = ""

            buffer << @tag.BER::Identifier.new(1, cls: :CONTEXT).encode
            buffer << BER::Length.new(@applicationContextName.size).encode
            buffer << @applicationContextName

            buffer.prepend(BER::Length.new(buffer.size).encode)
            buffer.prepend(self.class.tag.encode)
            
        end
    
    end

end
