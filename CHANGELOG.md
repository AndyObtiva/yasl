# Change Log

## 0.2.1

- Make `YASL::UNSERIALIZABLE_DATA_TYPES` work with regular classes too
- Make load `whitelist_classes` work with string class names
- Make load `whitelist_classes` work with a single class or class name string
- Support deserialization fallback of instance variables for Struct member values
- Added missing hash method to optional pure Ruby Struct implementation
- Fixed issue with requiring one arg minimum, using `select`, and using undefined `upcase?` in implementation of optional pure Ruby Struct

## 0.2.0

- Support Boolean serialization in Opal (instead of TrueClass and FalseClass)
- Support BigDecimal serialization
- Include optional pure Ruby reimplementaiton of Struct to avoid JS issues in Opal Struct when needed
- Fix issue with dumping not working when some ruby basic data type libraries (e.g. 'date') are not loaded by comparing to class name string instead of actual class object

## 0.1.0

- Serialize JSON basic data types
- Serialize Ruby basic data types
- Serialize instance variables as JSON
- Serialize class variables as JSON
- Serialize struct member values as JSON
- Serialize top-level class/module as JSON
- Serialize cycles by using object ID references
- Support `include_classes` option on dump
- Silently ignore non-serializable objects like `Proc`, `Binding`, and `IO`.
- Deserialize instance variables from JSON
- Deserialize Class occurence in variables from JSON
- Deserialize Module occurence in variables from JSON
- Deserialize class variables from JSON
- Deserialize Struct members from JSON
- Deserialize cycles with object ID references
- Deserialize top-level class/module from JSON
- Support `include_classes` option on load
- Raise error for deserialization not finding a class mentioned in the data
- Require passing `whitelist_classes` to `YASL#load` or else raise error for illegal classes
