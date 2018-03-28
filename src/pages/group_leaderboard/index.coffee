z = require 'zorium'
isUuid = require 'isuuid'

AppBar = require '../../components/app_bar'
Tabs = require '../../components/tabs'
GroupLeaderboard = require '../../components/group_leaderboard'
GroupEarnXp = require '../../components/group_earn_xp'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupLeaderboardPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$tabs = new Tabs {@model}
    @$groupLeaderboard = new GroupLeaderboard {
      @model, @router, serverData, group
    }
    @$earnXp = new GroupEarnXp {
      @model, @router, serverData, group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'leaderboardPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-leaderboard', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupLeaderboardPage.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
      }
      z @$tabs,
        isBarFixed: false
        hasAppBar: true
        tabs: [
          {
            $menuText: @model.l.get 'groupLeaderboardPage.earnXp'
            $el: z @$earnXp
          }
          {
            $menuText: @model.l.get 'groupLeaderboardPage.topAllTime'
            $el: z @$groupLeaderboard
          }
        ]
