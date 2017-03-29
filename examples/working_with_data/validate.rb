require 'dlms_trouble'
require 'pp'
include DLMSTrouble
axdr = "\x13\x02\x03\x19\x06\x06\x28\x07\xe0\x07\x0a\x07\x08\x00\x00\x00\x00\x3c\x08\x00\x00\x00\x00\x00\x00\x03\x2a\x07\xe0\x07\x0a\x07\x08\x1e\x00\x00\x00\x3c\x08\x00\x00\x00\x01\x00\x00\x03\x34"
dtype = DType.from_axdr(axdr)

# the expected structure
schema = DTypeSchema.compactArray "buffer" do
    structure "entry" do
        dateTime "timestamp"
        doubleLongUnsigned "recordNumber"
        doubleLongUnsigned "activeImportWh"
    end
end

# validate dtype against schema
valid = DTypeValidate.new(schema).validate(dtype)

# print validation result to terminal (true is valid, false is invalid)
puts "is valid? #{valid}"

