({
  /**
   * Removes session storage items based on provided patterns.
   *
   * @param {Array<string>} startsWithPatterns - An array of patterns to match session storage keys that start with any of these patterns.
   * @param {Array<string>} exactMatchPatterns - An array of exact session storage keys to be removed.
   */
  removeSessionStorageItems: function (startsWithPatterns, exactMatchPatterns) {
    var sessionKeysToRemove = [];

    // Find custom keys in the session storage for cleanup
    for (var i = 0; i < sessionStorage.length; i++) {
      var key = sessionStorage.key(i);

      // Check for keys that start with any of the provided patterns
      // or exactly match any of the provided patterns
      if (
        startsWithPatterns.some(function (pattern) {
          return key.startsWith(pattern);
        }) ||
        exactMatchPatterns.includes(key)
      ) {
        sessionKeysToRemove.push(key);
      }
    }

    // Remove the selected keys from the session storage
    sessionKeysToRemove.forEach(function (key) {
      sessionStorage.removeItem(key);
    });
  }
});
