require 'dlms_trouble'
require 'pp'
include DLMSTrouble

schema = DTypeSchema.compactArray "buffer" do
    structure "entry" do
        dateTime "timestamp"
        doubleLongUnsigned "recordNumber"
        doubleLongUnsigned "activeImportWh"
    end
end

# a native structure we want to encode as AXDR according to schema
native = [
    [Time.new(2016,7,10,8,0) , 0, 810], # 8:00
    [Time.new(2016,7,10,8,30), 1, 820], # 8:30
    [Time.new(2016,7,10,9,0) , 2, 824], # 9:00 (new)
]

puts "Native:"
pp native

# convert native to axdr according to schema and format for display on terminal
puts "\nAXDR:"
puts DTypeValidate.new(schema).to_data(native).to_axdr.bytes.map{ |c| sprintf("\\x%02X",c) }.join



