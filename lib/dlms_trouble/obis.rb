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

    class OBIS

        DOT_MATCH = /^(?<a>[0-9]+)\.(?<b>[0-9]+)\.(?<c>[0-9]+)\.(?<d>[0-9]+)\.(?<e>[0-9]+)\.(?<f>[0-9]+)$/
        
        def initialize(obis)

            obis = obis.to_s

            match = DOT_MATCH.match(obis)
            if match
                @a = match[:a].to_i
                @b = match[:b].to_i
                @c = match[:c].to_i
                @d = match[:d].to_i
                @e = match[:e].to_i
                @f = match[:f].to_i
                if a <= 0xff and b <= 0xff and c <= 0xff and d <= 0xff and e <= 0xff and f <= 0xff
                    @bytes = [a, b, c, d, e, f].pack("C6")
                else
                    raise ArgumentError
                end                
            elsif obis.size == 6
                @bytes = obis.dup

                @a = @bytes.bytes[0].to_i
                @b = @bytes.bytes[1].to_i
                @c = @bytes.bytes[2].to_i
                @d = @bytes.bytes[3].to_i
                @e = @bytes.bytes[4].to_i
                @f = @bytes.bytes[5].to_i
            else
                raise ArgumentError
            end
            
        end

        attr_reader :a,:b,:c,:d,:e,:f

        def to_axdr
            @bytes
        end

        def to_s
            "#{a}.#{b}.#{c}.#{d}.#{e}.#{f}"
        end

        def self.size
            6
        end
        
    end

end
