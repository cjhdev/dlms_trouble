DLMS Trouble
============

An ongoing project to produce a Ruby toolkit for working with DLMS.

[![Build Status](https://travis-ci.org/cjhdev/dlms_trouble.svg?branch=master)](https://travis-ci.org/cjhdev/dlms_trouble)

## Features

### Attribute/Method Data Handling

XDLMS-APDU.Data types map to the following classes:

| XDLMS-APDU.Data           | Equivalent Class            |
| --------------------------|-----------------------------|
| `null-data`               | DType::NullData             |
| `boolean`                 | DType::Boolean              |
| `enum`                    | DType::Enum                 |
| `bcd`                     | DType::BCD                  |
| `unsigned`                | DType::Unsigned             |
| `long-unsigned`           | DType::LongUnsigned         |
| `double-long-unsigned`    | DType::DoubleLongUnsigned   |
| `long64-unsigned`         | DType::Long64Unsigned       |
| `integer`                 | DType::Integer              |
| `long`                    | DType::Long                 |
| `double-long`             | DType::DoubleLong           |
| `long64`                  | DType::Long64               |
| `floating-point`          | DType::FloatingPoint        |
| `float32`                 | DType::Float32              |
| `float64`                 | DType::Float64              |
| `bit-string`              | DType::BitString            |
| `octet-string`            | DType::OctetString          |
| `visible-string`          | DType::VisibleString        |
| `utf8-string`             | DType::UTF8String           |
| `structure`               | DType::Structure            |
| `array`                   | DType::Array                |
| `compact-array`           | DType::CompactArray         |
| `dont-care`               | DType::DontCare             |
| `date-time`               | DType::DateTime             |
| `date`                    | DType::Date                 |
| `time`                    | DType::Time                 |

## Examples

- [encoding data](/examples/working_with_data/encode.rb)
- [decoding data](/examples/working_with_data/decode.rb)

## License

DLMS Trouble has an MIT license

