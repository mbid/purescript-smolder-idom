exports.createEvent = function (str) {
  return function (payload) {
    return new Event(str, payload);
  };
};
