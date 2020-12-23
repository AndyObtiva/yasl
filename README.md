# YASL - Yet Another Serialization Library

A Ruby serialization library that serializes/deserializes objects through their instance variables and Struct members by default without complaining about unserializable objects.

## Background

There are many Ruby serialization libraries out there, but none simply serialize objects perfectly as they are and deserialize them on the other side regardless of what is stored in them. Even `Marshal` is error-prone and complains when certain conditions are not met. YASL aims to provide serialization similar to Marshal's, albeit simpler and without complaining about unserializable objects. After all, 90% of the time, I don't care if a proc, binding, or singleton method got serialized or not. I just want the object containing them to get serialized successfully, and that is all I need.

## Assumptions

- Both the server and client contain the same Ruby classes
- JSON is good enough. No need for premature optimization.

## Contributing

-   Check out the latest master to make sure the feature hasn't been
    implemented or the bug hasn't been fixed yet.
-   Check out the issue tracker to make sure someone already hasn't
    requested it and/or contributed it.
-   Fork the project.
-   Start a feature/bugfix branch.
-   Commit and push until you are happy with your contribution.
-   Make sure to add tests for it. This is important so I don't break it
    in a future version unintentionally.
-   Please try not to mess with the Rakefile, version, or history. If
    you want to have your own version, or is otherwise necessary, that
    is fine, but please isolate to its own commit so I can cherry-pick
    around it.

## TODO

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Copyright

[MIT](LICENSE.txt)

Copyright (c) 2020 Andy Maleh.
