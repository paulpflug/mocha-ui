# mocha-ui package

A UI for running mocha inside of your project.

It is required to install the npm package `atom-ui-reporter` within your project:
```sh
npm install --save-dev atom-ui-reporter
```

## Features
- environment variables
- watch over different project directories
- filter which tests should be run
- saves your settings (package 'Project Manager' required)
- notifications
It is possible to define the ENV (useful for usage with debug npm package)

### Watch
You can specify a pattern watch files. On changes mocha will be run.
Syntax:
```
1/test/*.coffee
1/*.coffee
```
will watch all coffee-script files within your first project directory and its `test` subdirectory.


## License
Copyright (c) 2015 Paul Pflugradt
Licensed under the MIT license.
