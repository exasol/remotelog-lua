# remotelog-lua 1.1.0, released 2021-11-23

## Summary

Version 1.1.0 of `remotelog-lua` lets you pick between three different fallback strategies in case the remote logging connection can't be established:

* Console logging (default)
* Silently discarding messages
* Throwing an error

Check the [user guide](doc/user_guide/user_guide.md) for more details.

We also added a developer guide that helps you setting up and building the project and migrated the CI build from Travis CI to GitHub Actions.

### Documentation

* #4: Added developer guide.