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

require 'dlms_trouble/dtype'
require 'dlms_trouble/dtype_schema'

module DLMSTrouble

    class DTypeValidateError < Exception
    end
    
    class DTypeValidate

        def initialize(schema)
            @schema = schema
        end

        # Take DType input and validate according to schema
        #
        # @param data [DType] input objects to validate
        #
        # @return [true] data is valid against schema
        # @return [false] data is not valid against schema
        def validate(data)
            _validate(data, @schema.type)            
        end

        # Take mixed native and DType input and convert to valid DType output according to schema
        #
        # @param input mixed DType and native
        #
        # @raise [DTypeValidateError] input is invalid according to schema
        #
        # @return [DType] input converted to DType object
        def to_data(input, **opts)
            out = _to_data(input, @schema.type)
            if _validate(out, @schema.type) == false
                raise DTypeValidateError
            end
            out            
        end

        private

            def _validate(data, expected)

                result = false

                if data.kind_of?(DType)
                
                    if data.class == DType.mapSymbolToType(expected[:type])

                        case expected[:type]
                        when :array, :compactArray
                            if expected[:size].nil? or expected[:size].include?(data.size)
                                ok = 0
                                data.each do |v|
                                    puts "hey"
                                    if _validate(v, expected[:value].first) == true
                                        ok += 1                                    
                                    end
                                end
                                if data.size == ok
                                    result = true
                                end
                            end
                        when :visibleString, :octetString
                            if expected[:size].nil? or expected[:size].include?(data.size)
                                result = true                            
                            end
                        when :structure
                            if expected[:value].size == data.size
                                ok = 0
                                exp = expected[:value].each
                                data.each do |v|
                                    if _validate(v, exp.next) == true
                                        ok += 1
                                    end
                                end
                                if expected[:value].size == ok
                                    result = true
                                end
                            end
                        else
                            result = true
                        end

                    end

                end

                result
                
            end

            def _to_data(input, expected, **opts)

                out = nil

                # convert native to DType
                if !input.kind_of?(DType)

                    case expected[:type]
                    when :array, :compactArray

                        out = DType.mapSymbolToType(expected[:type]).new

                        if !input.respond_to? :each
                            raise DTypeValidateError
                        end

                        input.each do |v|
                            out.push(_to_data(v, expected[:value].first))
                        end

                    when :structure

                        out = DType.mapSymbolToType(expected[:type]).new

                        if !input.respond_to? :each_with_index or !input.respond_to? :size
                            raise DTypeValidateError
                        end

                        if input.size != expected[:value].size
                            raise DTypeValidateError
                        end

                        input.each_with_index do |v, i|
                            out.push(_to_data(v, expected[:value][i]))
                        end
                    
                    else

                        begin
                            out = DType.mapSymbolToType(expected[:type]).new(input)                            
                        rescue DTypeError
                            raise DTypeValidateError
                        end
                        
                    end

                # pass through DType
                else
                    out = input
                end

                out

            end

    end

end
