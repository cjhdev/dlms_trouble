module DLMSTrouble::HDLC

    module Checksum

        # @param block [String]
        # @param fcs [Integer]
        # @return [Integer]
        def checksum_block(fcs, block)
            
            block.bytes.each do |b|
                fcs = ((fcs >> 8) ^ checksum( (fcs ^ b ) & 0xff )) & 0xffff
            end
            
            fcs
            
        end
        
        # @param v [Integer]
        # @return [Integer]
        def checksum(v)
        
            vv = v
        
            8.times do
                if (vv & 1) == 1
                    vv = (vv >> 1) ^ 0x8408
                else
                    vv = vv >> 1
                end
            end
            
            vv & 0xffff
               
        end
    
    end


end
