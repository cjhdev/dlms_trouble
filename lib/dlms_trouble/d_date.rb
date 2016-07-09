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

    class DDate < DType

        @tag = 26

        attr_reader :year, :month, :dom, :dow

        def initialize(value=nil, **arg)

            default = {
                :year => :undefined,
                :month => :undefined,
                :dom => :undefined,
                :dow => :undefined
            }
        
            if value.kind_of? Time

                default.merge!({
                    :year => value.year,
                    :month => value.month,
                    :dom => value.day,
                    :dow => value.wday
                })

            elsif value.kind_of? Hash

                default.merge!(value)
            
            elsif !value.nil?

                raise DTypeError.new "cannot handle this value"
                
            end

            default.merge!(arg)

            @year = default[:year]
            @month = default[:month]
            @dom = default[:dom]
            @dow = default[:dow]
            
        end

        def to_axdr(**opts)
        
            out = opts[:packed] ? "" : axdr_tag

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

        def to_native
            self
        end

    end

end
