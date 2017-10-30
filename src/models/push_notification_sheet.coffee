RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

module.exports = class PushNotificationSheet
  constructor: ->
    @_isOpen = new RxBehaviorSubject false
    @onActionFn = null

  isOpen: =>
    @_isOpen

  onAction: (@onActionFn) => null

  open: =>
    @_isOpen.next true
    # prevent body scrolling while viewing menu
    document.body.style.overflow = 'hidden'

  close: =>
    @_isOpen.next false
    @onAction null
    document.body.style.overflow = 'auto'
