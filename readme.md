DLMS Trouble
============

An ongoing project to produce a Ruby toolkit for working with DLMS.

[![Build Status](https://travis-ci.org/cjhdev/dlms_trouble.svg?branch=master)](https://travis-ci.org/cjhdev/dlms_trouble)

## Features

### Attribute/Method Data Handling

- Classes to represent XDLMS-APDU.Data types
    - Initialisation from AXDR or compatible Ruby types
    - Serialisation of instances to AXDR
- Schema class for defining attribute/method structure (DTypeSchema)
- Attribute/method structure validation (DTypeValidate)

XDLMS-APDU.Data types map to the following classes:

| XDLMS-APDU.Data           | Equivalent Class      |
| --------------------------|-----------------------|
| `null-data`               | DNullData             |
| `boolean`                 | DBoolean              |
| `enum`                    | DEnum                 |
| `bcd`                     | DBCD                  |
| `unsigned`                | DUnsigned             |
| `long-unsigned`           | DLongUnsigned         |
| `double-long-unsigned`    | DDoubleLongUnsigned   |
| `long64-unsigned`         | DLong64Unsigned       |
| `integer`                 | DInteger              |
| `long`                    | DLong                 |
| `double-long`             | DDoubleLong           |
| `long64`                  | DLong64               |
| `floating-point`          | DFloatingPoint        |
| `float32`                 | DFloat32              |
| `float64`                 | DFloat64              |
| `bit-string`              | DBitString            |
| `octet-string`            | DOctetString          |
| `visible-string`          | DVisibleString        |
| `utf8-string`             | DUTF8String           |
| `structure`               | DStructure            |
| `array`                   | DArray                |
| `compact-array`           | DCompactArray         |
| `dont-care`               | DDontCare             |
| `date-time`               | DDateTime             |
| `date`                    | DDate                 |
| `time`                    | DTime                 |



## Examples

- [Working with Attribute and Method Data](https://github.com/cjhdev/dlms_trouble/wiki/Working-With-Attribute-and-Method-Data)

## License

MIT

Cameron Harper (C) 2016

cam@stackmechanic.com

