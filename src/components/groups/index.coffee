z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

GroupList = require '../group_list'
UiCard = require '../ui_card'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Groups
  constructor: ({@model, @router}) ->
    myGroups = @model.group.getAll({filter: 'mine'})
    publicGroup = @model.group.getById config.MAIN_GROUP_ID
    myGroupsAndPublicGroup = Rx.Observable.combineLatest(
      myGroups
      publicGroup
      (myGroups, publicGroup) ->
        (myGroups or []).concat [publicGroup]
    )
    @$myGroupList = new GroupList {
      @model
      @router
      groups: myGroupsAndPublicGroup
    }
    @$suggestedGroupsList = new GroupList {
      @model
      @router
      groups: @model.group.getAll({filter: 'suggested'})
    }

    @$unreadInvitesIcon = new Icon()
    @$unreadInvitesChevronIcon = new Icon()

    @$translateCard = new UiCard()

    language = @model.l.getLanguage()

    @state = z.state
      me: @model.user.getMe()
      language: language
      isTranslateCardVisible: language.map (lang) ->
        needTranslations = ['ko', 'de', 'zh', 'ja']
        isNeededLanguage = lang in needTranslations
        console.log language, lang
        localStorage? and isNeededLanguage and
                                not localStorage['hideTranslateCard']

  render: =>
    {me, isTranslateCardVisible, language} = @state.getValue()

    groupTypes = [
      {
        title: @model.l.get 'groups.myGroupList'
        $groupList: @$myGroupList
      }
      # {
      #   title: @model.l.get 'groups.suggestedGroupList'
      #   $groupList: @$suggestedGroupsList
      # }
    ]

    unreadGroupInvites = me?.data.unreadGroupInvites
    inviteStr = if unreadGroupInvites is 1 then 'invite' else 'invites'

    translation =
      ko: '한국어'
      ja: '日本語'
      zh: '中文'
      de: 'deutsche'

    z '.z-groups',
      if unreadGroupInvites
        @router.link z 'a.unread-invites', {
          href: '/groupInvites'
        },
          z '.icon',
            z @$unreadInvitesIcon,
              icon: 'notifications'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.text', "You have #{unreadGroupInvites} new group #{inviteStr}"
          z '.chevron',
            z @$unreadInvitesChevronIcon,
              icon: 'chevron-right'
              isTouchTarget: false
              color: colors.$primary500
      _map groupTypes, ({title, $groupList}) ->
        z '.group-list',
          z '.g-grid',
            z 'h2.title', title
          $groupList
      z '.g-grid',
        z '.g-cols',
          z '.g-col.g-xs-12.g-md-6',
            if isTranslateCardVisible
              z @$translateCard,
                isHighlighted: true
                text:
                  z 'div',
                    z 'p', @model.l.get 'translateCard.request1'
                    z 'p', @model.l.get 'translateCard.request2', {
                      language: translation[language]
                    }
                cancel:
                  text: @model.l.get 'translateCard.cancelText'
                  onclick: =>
                    localStorage['hideTranslateCard'] = '1'
                    @state.set isTranslateCardVisible: false
                submit:
                  text: @model.l.get 'translateCard.submit'
                  onclick: =>
                    ga? 'send', 'event', 'translate', 'click', language
                    @model.portal.call 'browser.openWindow',
                      url: 'https://crowdin.com/project/starfire'
                      target: '_SYSTEM'
