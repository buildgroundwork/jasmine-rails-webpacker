(function() {
  'use strict';

  function requireAll(context) {
    context.keys().forEach(context);
  }

  requireAll(require.context('spec/javascript/helpers/', true, /\.js/));
  requireAll(require.context('spec/javascript/', true, /[sS]pec\.js/));
})();

