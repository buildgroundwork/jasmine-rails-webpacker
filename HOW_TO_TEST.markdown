To test changes to the jasmine-gem:

* You need to have the [jasmine project](https://github.com/jasmine/jasmine) checked out in `../jasmine`
* Delete `Gemfile.lock`
* Clear out your current gemset
* exec a `bundle install`
* `rake` until specs are green
* Repeat
* Check in
