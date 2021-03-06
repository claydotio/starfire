z = require 'zorium'
_find = require 'lodash/find'

AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ProfileChest = require '../../components/clash_royale_profile_chests'
Spinner = require '../../components/spinner'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileChestsPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    playerId = requests.map ({route}) ->
      if route.params.playerId then route.params.playerId else false

    @player = playerId.switchMap (playerId) =>
      @model.player.getByPlayerIdAndGameKey playerId, 'clash-royale'
      .map (player) ->
        return player or {}

    @$spinner = new Spinner()

    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profileChest = new ProfileChest {@model, @router, @player}

    @state = z.state
      windowSize: @model.window.getSize()
      player: @player

  getMeta: =>
    @player.map (player) =>
      playerName = player?.data?.name
      smcCount = _find(player?.data?.upcomingChests?.items, {
        name: 'Super Magical Chest'
      })?.index
      {
        title: "#{playerName}'s #{@model.l.get 'profileChestsPage.title'}"
        description:
          if smcCount?
            "+#{smcCount} until " +
            'Super Magical Chest'
          else
            'Track my chest cycle'
        twitter:
          image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{player?.id}.png"
        openGraph:
          image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{player?.id}.png"
      }

  render: =>
    {windowSize, player} = @state.getValue()

    z '.p-profile-chests', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'profileChestsPage.title'
        style: 'primary'
        $topLeftButton: z @$buttonBack, {
          color: colors.$header500Icon
          fallbackPath: @router.get 'clashRoyalePlayer', {playerId: player?.id}
        }
      }
      if player
        @$profileChest
      else
        @$spinner
