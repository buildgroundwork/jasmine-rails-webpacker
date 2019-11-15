# Jasmine for Rails with Webpacker

** Note: this gem is *only* for use with Rails+Webpacker (e.g. Rails 6), and thus has a hard dependency on Rails **

- I have tested this with Rails 6.  I have not testing with Rails 5 + Webpacker or similar.
- This should have no dependencies on the Rails Asset Pipeline, so should work fine in a pure Webpacker project.

** Note: The core jasmine project will not work with Webpack until resolution of [this pull request](https://github.com/jasmine/jasmine/pull/1766).  See installation notes below for a workaround.**

This library allows you to run a Rails project's Jasmine suite in a browser or on the command line.

## Getting started

Add the following to your `Gemfile`:
```ruby
group :development, :test do
  ...
  # Using the github link just until we get this published
  gem 'jasmine-rails-webpacker', github: 'buildgroundwork/jasmine-rails-webpacker'
end
```

Next, run the installation generator for your project:

```bash
% rails generate jasmine:install
```

If you would like some example specs to get you started you can run the examples generator:

```bash
% rails generate jasmine:examples
```

** Note: Workaround for Jasmine's incompatibility with Webpack (see note above):**

```bash
% yarn remove jasmine-core
% yarn add --dev https://github.com/buildgroundwork/jasmine.git
```

### Under the hood

The installation generator will create two new files in your packs directory, a new initializer, and a spec directory to mirror your production javascript directory:

```
<project root>
> app
  > javascript
    > packs
      > jasmine.js
      > specs.js
> config
  > initializers
    > jasmine.rb
> spec
  > javascript
    > helpers
      > .gitkeep 
```

The installation will also add a line to your Webpack environment configuration (`config/webpack/environment.js`) so that Webpacker can find your specs.  The file should look like this after a clean install:

```javascript
const { environment } = require('@rails/webpacker')

module.exports = environment;

environment.resolvedModules.append('project root', '.'); // <== added
```

## Usage

Start the Jasmine server:

```bash
% rake jasmine
```

Point your browser to `localhost:8888`. The suite will run every time this page is re-loaded.

To run from the command line:

```bash
% rake jasmine:ci
```

** Note: PhantomJS is no longer actively supported (see [here](https://github.com/ariya/phantomjs/issues/15344)).**

This uses Chrome Remote to load and run the Jasmine suite without a browser.

## Configuration

** Note: This project no longer uses the `jasmine.yml` file used by previous incarnations of Jasmine for configuration **

This project adds the `chrome_remote` as a dependency; no need to add that to your `Gemfile`.

### config/initializers/jasmine.rb

You can configure Jasmine's behavior using the `config` block in this initializer.  The default initializer created by the installation includes descriptions of each setting.

This file also includes a line that tells Webpacker to watch spec files for changes:

```ruby
  Webpacker::Compiler.watched_paths << 'spec/javascript/**/*.js'
```

You should not remove this file, unless you include that line elsewhere in your test environment.  You will need to update this line if you choose to keep your specs in a different directory.

You can customize which files your test process includes by adding them directly to the generated pack files. 

### packs/jasmine.js

This packages all of the Jasmine-specific JavaScript needed to run your tests.  You will likely not need to modify this file. 

** You should not include this file in any application layouts or views.  Jasmine will automatically include it in the test page when running the suite. **

### packs/spec.js

This packages all of your specs.  By default it will recursively include any spec files (ending in `_spec.js` or `Spec.js`) in the `specs/javascript` directory, as well as any `.js` files in the `spec/javascript/helpers` directory.

** You should not include this file in any application layouts or views.  Jasmine will automatically include it in the test page when running the suite. **

## Support

Documentation: [jasmine.github.io](https://jasmine.github.io)
Jasmine Mailing list: [jasmine-js@googlegroups.com](mailto:jasmine-js@googlegroups.com)
Twitter: [@jasminebdd](http://twitter.com/jasminebdd)

Please file issues here at Github.

## License
MIT License.

See `MIT.LICENSE` file in this repository.

