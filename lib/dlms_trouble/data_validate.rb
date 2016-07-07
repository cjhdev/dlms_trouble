require 'dlms_trouble/data'
require 'dlms_trouble/data_dsl'

module DLMSTrouble

    class DataValidateError < Exception
    end

    class DataValidate

        def self.validate(data, dsl)
            _validate(data, dsl.type)            
        end

        private_class_method

            def self.mapType(symbol)
                s = symbol.to_s
                s[0] = s[0].upcase
                Data::const_get("D" + s)
            end

            def self._validate(data, expected)

                if !data.kind_of?(Data::DType)
                    raise DataValidateError
                end

                if data.class != mapType(expected[:type])
                    raise DataValidateError.new "expecting instance of #{mapType(expected[:type])} but got #{data.class}"
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

    end

end
