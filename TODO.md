# TODO

## Next

- Avoid loading 'date', 'set', 'continuation', & 'socket' to conserve memory by testing for related classes conditionally

## Future

- Serialize whether a class reference is a class or module
- Serialize whether a class reference is a struct or not
- Materialize a class matching a non-existing class

## Far Off
    
- Handle exception in instance variable matching class name (e.g. an attribute begins with '_data')

## Just Ideas

- Designate if a class is serializable or should be ignored (serializing as nil)
- Filter by attributes on dump
- Filter by classes on dump
