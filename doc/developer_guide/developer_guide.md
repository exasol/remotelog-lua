# Developer Guide

This document contains developer information on how to build, run, modify and publish this Lua project.

## Prerequisites

This project needs a Lua interpreter &ge; Lua 5.1.

### Lua Rocks 3

To install the Lua dependencies you also need the [LuaRocks](https://luarocks.org/) package manager. While LuaRocks version 3 is already available for quite a while, it has not yet reached all package repositories. Check the `.rockspec` file for a list of all Lua dependencies.

You can install the dependencies with:

```bash
luarocks install --deps-only *.rockspec
```

### Installing on Ubuntu 21.10

```bash
wget http://http.us.debian.org/debian/pool/main/l/luarocks/luarocks_3.8.0+dfsg1-1_all.deb
sudo dpkg -i luarocks_3.8.0+dfsg1-1_all.deb
```

## Sources and tests

You find the implementation under `src` and the tests under `test`.

## Versioning

We use semantic versioning, meaning that the major version indicates backward compatibility, the minor version behavior changes and the fix version everything else.

The version is defined in the LuaRock specification file in the root directory.

```
<module-name>-<version>-<package-revision>.rockspec
```

Example:

```
mymodule-15.8.0-1.rockspec
```

As you can see, the version is part of the filename already. Unfortunately you also have to change it _inside_ the file.

```
-- ...
version = "15.8.0-1"

source = {
    url = -- project URL on GitHub
    tag = "15.8.0"
}
```

Additionally, you need to change the version number in the module itself under `src/<module-path>`:

```lua
-- ...

local M = {
    VERSION = "15.8.0",
    -- ...
}
```

Finally, each new version needs an entry in the changelog under `doc/changes/changes_<version>.md` and a link to that file from `doc/changes/changelog.md`.

## Running the tests

To run all the tests in the project use:

```bash
tools/runtests.sh
```

This script also runs the static code analysis. Note that this is the same script used in the [continuous integration](#continuous-integration) builds.

The unit tests are written using [LuaLUnit](https://github.com/bluebird75/luaunit). The are therefore directly executable with Lua:

```bash
lua tests/<test-name>.lua
```

## Building the Package

Refer to the [LuaRocks documentation](https://github.com/luarocks/luarocks/wiki/Documentation) for detailed information about package management in Lua.

To build and install the package locally use the command below. "Locally" in this context means as a regular user for yourself as opposed to globally as administrator.

```bash
luarocks make --local
```

If you have administrator privileges on your machine and prefer a global installation, simply omit the `--local` switch in all commands.

**Warning:** Be careful, when you have packages installed that you also work on, you have to make sure that the work-in-progress code is in the front of the package path. Otherwise you end up debugging an installed package instead of your code!

To uninstall the package use:

```bash
luarocks remove <package-name> --local
```

## Continuous Integration

In the directory `.github/workflows` you find the GitHub actions that make up the continuous integration and test for this project.

The build runs with each change on a pull request. As mentioned before, the test suite and static code analysis are part of the CI build. So the build only succeeds if the whole test suite and static checks are green.

## Publishing the LuaRock Package

Unlike the other parts of the build, this step can only be executed by project members with access to the package repository for this module.

Before changes can be published as a new LuaRock package, we first always need a release on GitHub. The reason for this is that the `.rockspec` uses a GitHub tag as source.

So the publication process consists of two steps:

1. Create a release on GitHub
1. Upload the new `.rockspec` to LuaRocks

The simple way is to upload the spec via the LuaRocks web UI. 

But that gets very repetitive soon, so as an alternative, you can upload from the command line.

1. Get an account on https://luarocks.org if you do not have one yet
1. In the "settings" section of your account, create an API key
1. Upload the Lua rock using the following command:

    ```bash
    read -s API_KEY && luarocks upload --api-key="$API_KEY" <rock-spec>
    ```

This will prompt for the API key on the console.