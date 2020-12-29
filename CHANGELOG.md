# Change Log

## 0.1.0

- Serialize JSON basic data types
- Serialize Ruby basic data types
- Serialize instance variables as JSON
- Serialize class variables as JSON
- Serialize struct member values as JSON
- Serialize top-level class/module as JSON
- Serialize cycles by using object ID references
- Support `include_classes` option on dump
- Deserialize instance variables from JSON
- Deserialize Class occurence in variables from JSON
- Deserialize Module occurence in variables from JSON
- Deserialize class variables from JSON
- Deserialize Struct members from JSON
- Deserialize cycles with object ID references
- Deserialize top-level class/module from JSON
- Support `include_classes` option on load
- Raise error for deserialization not finding a class mentioned in the data
