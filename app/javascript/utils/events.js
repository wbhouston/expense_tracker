window.Utils ||= {}

windown.Utils.Events = {
  delegate({
    callback,
    delegatedTo = document,
    eventTarget,
    eventType,
  }) {
    delegatedTo.addEventListener(eventType, (event) => {
      if (event.target.closest(eventTarget)) {
        callback(event)
      }
    })
  },
}