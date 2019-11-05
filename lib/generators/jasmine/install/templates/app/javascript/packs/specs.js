function requireAll(context) {
  context.keys().forEach(context);
}

requireAll(require.context('javascripts/helpers/', true, /\.js/));
requireAll(require.context('javascripts/', true, /[sS]pec\.js/));

