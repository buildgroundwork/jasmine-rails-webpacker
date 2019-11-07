module.exports = (function() {
  'use strict';

  function Song() {
  }

  Song.prototype.persistFavoriteStatus = function(value) {
    // something complicated
    throw new Error("not yet implemented");
  };

  return Song;
})();

