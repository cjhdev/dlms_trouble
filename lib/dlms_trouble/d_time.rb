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

    class DTime < DType

        @tag = 27

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
            
            elsif !value.nil?

                raise DTypeError.new "cannot handle this value"
                
            end

            default.merge!(arg)

            @hour = default[:hour]
            @min = default[:min]
            @sec = default[:sec]
            @hun = default[:hun]
            
        end

        def to_axdr(**opts)
            
            out = opts[:packed] ? "" : axdr_tag

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
        end

        def to_native
            self
        end

    end

end
