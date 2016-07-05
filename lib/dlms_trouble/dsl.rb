require 'ostruct'
require 'dlms_trouble/axdr'

module DLMSTrouble

    class DSLError < Exception
    end

    class DSL

        TAGS = {
            0 => :nullData,
            1 => :array,
            2 => :structure,
            3 => :boolean,
            4 => :bitString,
            5 => :doubleLong,
            6 => :doubleLongUnsigned,
            7 => :floatingPoint,
            9 => :octetString,
            10 => :visibleString,
            13 => :bcd,
            15 => :integer,
            16 => :long,
            17 => :unsigned,
            18 => :longUnsigned,
            19 => :compactArray,
            20 => :long64,
            21 => :long64Unsigned,
            22 => :enum,
            23 => :float32,
            24 => :float64,
            25 => :dateTime,
            26 => :date,
            27 => :time
        }

        def initialize(&dsl)
            @tree = {:value => []}
            @stack = [@tree]
            instance_eval(&dsl)

            if @tree[:value].size == 0
                raise "need to make a definition"
            end
        end


        def evaluate(data, expected=nil)

            if expected.nil?
                expected = @tree[:value].first
            end

            case expected[:type]
            when :nullData
                if data.kind_of? AXDR::DNullData or data.nil?
                else
                    raise DSLError
                end
            when :boolean
                if data
                    out << [1].pack("C")
                else
                    out << [0].pack("C")
                end
            when :integer
                if data.kind_of? Integer
                    if data >= -128 and data <= 127
                    
                    else
                        raise DSLError.new "integer is out of range"
                    end
                else
                    raise DSLError.new "expecting kind_of Integer but got #{data.class}"
                end
            when :long
                if data.kind_of? Integer
                    if data >= -32768 and data <= 32767
                    
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :doubleLong
                if data.kind_of? Integer
                    if data >= -2147483648 and data <= 214783647
                    
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :long64
                if data.kind_of? Integer
                    if data >= -9223372036854775808 and data <= 9223372036854775807
                    
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :unsigned, :enum
                if data.kind_of? Integer
                    if data >= 0 and data <= 255
                    
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :longUnsigned
                if data.kind_of? Integer
                    if data >= 0 and data <= 65535
                    
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :doubleLongUnsigned
                if data.kind_of? Integer
                    if data >= 0 and data <= 4294967295

                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :long64Unsigned
                if data.kind_of? Integer
                    if data >= 0 and data <=  18446744073709551615
                        
                    else
                        raise DSLError
                    end
                else
                    raise DSLError.new "expecting kind_of #{Integer.class} but got #{data.class}"
                end
            when :floatingPoint, :float32
                if data.kind_of? Numeric
                
                else
                    raise DSLError.new "expecting kind_of #{Numeric.class} but got #{data.class}"
                end
            when :float64
                if data.kind_of? Numeric
                
                else
                    raise DSLError.new "expecting kind_of #{Numeric.class} but got #{data.class}"
                end
            when :octetString, :visibleString
                if data.kind_of? String
                    if expected[:size].nil? or (expected[:size] and expected[:size].include? data.size)
                                         
                    else
                        raise DSLError.new "input is out of the acceptable size range"
                    end
                else
                    raise DSLError.new "expecting kind_of #{String} but got #{data.class}"
                end
            when :array
                if data.kind_of? Array
                    if expected[:size].nil? or (expected[:size] and expected[:size].include? data.size)
                        data.each do |value|
                            evaluate(value, expected[:value].first)
                        end
                    else
                        raise DSLError
                    end                                
                else
                    raise DSLError.new "expecting kind_of Array but got #{data.class}"
                end                    
            when :structure
                if data.kind_of? Array
                    if expected[:value].size == data.size
                        data.each_with_index do |value, index|
                            evaluate(value, expected[:value][index])
                        end
                    else
                        raise DSLError
                    end
                else
                    raise DSLError
                end                                
            else
                raise DSLError
            end
        end
        
        private

            ADD_SIMPLE = lambda do |stack, id, method|
                if stack.size == 1 and stack.last[:value].size > 0
                    raise "already defined top level"
                elsif stack.last[:type] == :array or stack.last[:type] == :packedArray and stack.last[:value].size > 0
                    raise "array type already defined"
                end
                stack.last[:value] << {:type => method, :id => id}
            end

            ADD_STRING = lambda do |stack, id, method, size|
                ADD_SIMPLE.call(stack, id, method)
                if size
                    if size.kind_of? Integer
                        stack.last[:value].last[:size] = Range.new(size, size)
                    elsif size.kind_of? Range
                        stack.last[:value].last[:size] = size
                    else
                        raise DSLError.new "can't accept #{size} as size attribute"
                    end
                end                                                
            end

            ADD_ARRAY = lambda do |stack, id, method, size|
                ADD_SIMPLE.call(stack, id, method)
                if size
                    if size.kind_of? Integer
                        stack.last[:value].last[:size] = Range.new(size, size)
                    elsif size.kind_of? Range
                        stack.last[:value].last[:size] = size
                    else
                        raise DSLError.new "can't accept #{size} as size attribute"
                    end
                end                                                
            end
            
            def nullData(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__) 
            end
            def boolean(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)            
            end
            def enum(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                            
            end
            def unsigned(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                            
            end
            def longUnsigned(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def doubleLongUnsigned(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def long64Unsigned(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def integer(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def long(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def doubleLong(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def doubleLongUnsigned(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def float32(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def floatingPoint(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def float64(id, **args)
                ADD_SIMPLE.call(@stack, id, __method__)                          
            end
            def octetString(id, **args)
                ADD_STRING.call(@stack, id, __method__, args[:size])
            end
            def visibleString(id, **args)
                ADD_STRING.call(@stack, id, __method__, args[:size])                
            end
            def structure(id, **args, &sub)
                ADD_SIMPLE.call(@stack, id, __method__)
                instance_eval(&sub)                
            end
            def array(id, **args, &sub)
                ADD_ARRAY.call(@stack, id, __method__, args[:size])
                @stack << @stack.last[:value].last
                @stack.last[:value] = []
                instance_eval(&sub)
                @stack.pop                
            end            
            def compactArray(id, **args, &sub)
                ADD_ARRAY.call(@stack, id, __method__, args[:size])
                @stack.last[:size] = args[:size]                        
                instance_eval(&sub)    
            end            
    end

end
