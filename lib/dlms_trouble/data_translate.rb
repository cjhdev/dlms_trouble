require 'dlms_trouble/data'
require 'dlms_trouble/data_dsl'

module DLMSTrouble

    class DataTranslateError < Exception
    end

    class DataTranslate

        def self.to_data(input, dsl)
            _to_data(data, dsl.type)            
        end

        private_class_method

            def self._to_data(input, expected)

                out = nil

                # convert native to DType
                if !input.kind_of?(Data::DType)

                    case expected[:type]
                    when :array, :packedArray, :structure

                        out = mapType(expected[:type]).new
                        input.each do |v|
                            out.push native_to_dtype(v, expected)
                        end
                        
                    else
                        out = mapType(expected[:type]).new(input)
                    end

                # pass through DType
                else
                    out = input
                end

                out

            end

    end

end
