if (process.env.RAILS_ENV === 'test' || process.env.RAILS_ENV === 'development') {
  require('jasmine-core/lib/jasmine-core/jasmine.css');
  require('jasmine-core/lib/jasmine-core/jasmine.js');
  require('jasmine-core/lib/jasmine-core/jasmine-html.js');
  require('jasmine-core/lib/jasmine-core/boot.js');

  require('jasmine-core/images/jasmine_favicon.png');
}

