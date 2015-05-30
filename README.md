# mocha-ui package

A UI for running mocha inside of your project.

It is required to install the npm package `atom-ui-reporter` within your project:
```sh
npm install --save-dev atom-ui-reporter
```

Press `ctrl+shift+alt+m` to open the mocha-ui

![mocha-ui](https://cloud.githubusercontent.com/assets/1881921/7798031/b538ea94-02f4-11e5-8cb9-7d51c674f038.gif)

## Features
- environment variables
- watch over different project directories
- filter which tests should be run
- saves your settings (package 'Project Manager' required)
- notifications
- It is possible to define the ENV (useful for usage with debug npm package)

### Watch
You can specify a pattern watch files. On changes mocha will be run.
Syntax:
```
1/test/*.coffee
1/*.coffee
```
will watch all coffee-script files within your first project directory and its `test` subdirectory.

## Known issues

- small width is not supported (style gets ugly)
- modals (path change/pattern change) don't close on cancel (clicking somewhere/pressing ESC)
- a button to clear the filter field is missing
- tests should run on blur of filter field
- doesn't scroll down automatically
- action bar is ugly (could be replaced by defining actions with shortcuts)
- watch doesn't fire on newly created files. To watch these, unwatch+watch must be clicked [needs a new feature in atom](https://github.com/atom/atom/issues/6875). So no watch on freshly compiled files, watch the source instead.
- doesn't close on close of window (watcher is still active)
- doesn't work well, when opened in two atom instances simultaneous

## License
Copyright (c) 2015 Paul Pflugradt
Licensed under the MIT license.
