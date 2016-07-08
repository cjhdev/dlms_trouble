require 'dlms_trouble/data'
require 'dlms_trouble/data_dsl'

module DLMSTrouble

    class DataValidateError < Exception
    end
    
    class DataValidate

        # Take Data input and validate according to dsl
        def self.validate(data, dsl)
            _validate(data, dsl.type)            
        end

        # Take mixed native and Data input and convert to valid Data output according to dsl
        # @raise [DataValidateError] input is invalid according to dsl
        def self.to_data(input, dsl, **opts)
            _to_data(input, dsl.type)
        end

        private_class_method

            def self._validate(data, expected)

                if !data.kind_of?(Data)
                    raise DataValidateError
                end

                if data.class != Data.mapSymbolToType(expected[:type])
                    raise DataValidateError.new "expecting instance of #{Data.mapSymbolToType(expected[:type])} but got #{data.class}"
                end

                case expected[:type]
                when :array, :packedArray
                    if expected[:size].nil? or expected[:size].include?(data.size)
                        data.each do |v|
                            _validate(v, expected[:value].first)
                        end
                    else
                        raise DataValidateError
                    end
                when :visibleString, :octetString

                    if expected[:size].nil? or expected[:size].include?(data.size)
                    
                    else
                        raise DataValidateError
                    end
                when :structure
                    if expected[:size].nil? or expected[:size].include?(data.size)
                        data.each_with_index do |v,i|
                            _validate(v, expected[:value][i])
                        end
                    else
                        raise DataValidateError
                    end
                end

                true
                
            end

            def self._to_data(input, expected, **opts)

                out = nil

                # convert native to Data
                if !input.kind_of?(Data)

                    case expected[:type]
                    when :array, :packedArray, :structure

                        out = Data.mapSymbolToType(expected[:type]).new
                        
                        if !input.respond_to? :each
                            raise DataValidateError
                        end

                        input.each_with_index do |v, i|
                            if i > expected[:value].size
                                raise DataTranslateError
                            end
                            out.push(_to_data(v, expected[:value][i]))
                        end
                        
                    else

                        begin
                            out = Data.mapSymbolToType(expected[:type]).new(input)
                        rescue DataError
                            raise DataValidateError
                        end
                        
                    end

                # pass through Data
                else
                    out = input
                end

                _validate(out, expected)

                out

            end

    end

end
