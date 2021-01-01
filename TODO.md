# TODO

## Next


## Soon


## Future

- Improve support for `whitelist_classes` on load to also filter basic types if any of them are mentioned
- Support `whitelist_classes` on dump, ignoring other classes silently without complaining
- Support `blacklist_classes` on dump, ignoring classes silently without complaining

## Far Off
    
- Support materializing a class matching a non-existing class during deserialization by ensuring serialization includes whether a class reference is a class, module, or struct along with all ancestors
- Handle exception in instance variable matching class name (e.g. an attribute begins with '_data')

## Just Ideas

- Filter by attributes (whitelist or blacklist) on dump
- Filter by attributes globally
- Limit number of lifetime deserialized symbols to prevent symbol DOS attacks in a programmer friendly way without requiring them to know all symbols in advance, which can be very impractical
