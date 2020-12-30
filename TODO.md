# TODO

## Next



## Future

- Support `whitelist_classes` on load to also include basic types (people could use YASL constants to avoid typing all by hand), documenting default as YASL::RUBY_BASIC_DATA_TYPES
- Support `whitelist_classes` on dump, ignoring other classes silently without complaining
- Support `blacklist_classes` on dump, ignoring classes silently without complaining

## Far Off
    
- Serialize whether a class reference is a class or module
- Serialize whether a class reference is a struct or not
- Materialize a class matching a non-existing class
- Handle exception in instance variable matching class name (e.g. an attribute begins with '_data')

## Just Ideas

- Filter by attributes (whitelist or blacklist) on dump
