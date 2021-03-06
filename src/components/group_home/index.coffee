z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
Environment = require '../../services/environment'
require 'rxjs/add/observable/combineLatest'

GroupHomeVideos = require '../group_home_videos'
GroupHomeThreads = require '../group_home_threads'
GroupHomeAddons = require '../group_home_addons'
GroupHomeAdminStats = require '../group_home_admin_stats'
GroupHomeChat = require '../group_home_chat'
GroupHomeOffers = require '../group_home_offers'
GroupHomeCollecting = require '../group_home_collecting'
GroupHomeStats = require '../group_home_stats'
GroupHomeClashRoyaleDecks = require '../group_home_clash_royale_decks'
GroupHomeTranslate = require '../group_home_translate'
MasonryGrid = require '../masonry_grid'
UiCard = require '../ui_card'
AerservAd = require '../aerserv_ad'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHome
  constructor: ({@model, @router, group, @overlay$, @serverData}) ->
    me = @model.user.getMe()
    meAndGroup = RxObservable.combineLatest me, group, (vals...) -> vals

    player = meAndGroup.switchMap ([{id}, group]) =>
      gameKey = group?.gameKeys?[0] or 'clash-royale'
      @model.player.getByUserIdAndGameKey id, gameKey
      .map (player) ->
        return player or {}

    @isTranslateCardVisibleStreams = new RxReplaySubject 1
    @isTranslateCardVisibleStreams.next @model.l.getLanguage().map (lang) ->
      needTranslations = ['es', 'it', 'fr', 'ja', 'ko', 'zh',
                          'pt', 'de', 'pl', 'tr', 'ru', 'id', 'tl']
      isNeededLanguage = lang in needTranslations
      localStorage? and isNeededLanguage and
                              not localStorage['hideTranslateCard']


    @$aerservAd = new AerservAd {@model, group}
    @$groupHomeThreads = new GroupHomeThreads {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeAddons = new GroupHomeAddons {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeAdminStats = new GroupHomeAdminStats {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeStats = new GroupHomeStats {
      @model, @router, group, @overlay$, isMe: true
    }
    @$groupHomeClashRoyaleDecks = new GroupHomeClashRoyaleDecks {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeOffers = new GroupHomeOffers {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeCollecting = new GroupHomeCollecting {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeChat = new GroupHomeChat {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeVideos = new GroupHomeVideos {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeTranslate = new GroupHomeTranslate {
      @model, @router, group, @isTranslateCardVisibleStreams
    }
    @$masonryGrid = new MasonryGrid {@model}

    @state = z.state {
      group
      player
      language: @model.l.getLanguage()
      isTranslateCardVisible: @isTranslateCardVisibleStreams.switch()
      me: me
    }

  render: =>
    {me, group, player, deck, language,
      isTranslateCardVisible} = @state.getValue()

    userAgent = @serverData?.req?.headers?['user-agent'] or
                  navigator?.userAgent or ''
    isFortnite = group?.key and group?.key.indexOf('fortnite') isnt -1
    isNative = Environment.isNativeApp(config.GAME_KEY, {userAgent})

    z '.z-group-home',
      z '.g-grid',
        # if isFortnite and player?.id
        #   z '.weekly-raffle', {
        #     onclick: =>
        #       @model.group?.goPath group, 'groupWeeklyRaffle', {
        #         @router
        #       }
        #   },
        #     z '.title', @model.l.get 'groupHome.raffle'
        #     z '.learn-more',
        #       @model.l.get 'groupHome.raffleLearnMore'

        if group?.id
          z @$masonryGrid,
            columnCounts:
              mobile: 1
              desktop: 2
            $elements: _filter [
              z @$groupHomeStats

              if window? and not isNative
                @$aerservAd

              if group?.key in [
                'playhard', 'eclihpse', 'nickatnyte', 'ferg',
                'teamqueso', 'ninja', 'theviewage'
              ]
                z @$groupHomeVideos

              if group?.key in [
                'clashroyalees', 'clashroyalept', 'clashroyalepl', 'fortnitees'
                'fortnite', 'fortnitejp', 'brawlstarses'
              ]
                z @$groupHomeThreads

              z @$groupHomeChat


              if group?.key in ['nickatnyte', 'theviewage']
                z @$groupHomeCollecting

              # if me?.username is 'austin' or ( # FIXME
              #   me?.username is 'brunoph' and group?.key is 'playhard'
              # )
              #   z @$groupHomeAdminStats

              if not Environment.isiOS({userAgent}) and group?.key in [
                'playhard', 'eclihpse', 'nickatnyte', 'ferg', 'teamqueso'
              ]
                z @$groupHomeOffers


              if player?.id and not isFortnite and
                  not (group?.key in ['brawlstarses', 'ninja', 'theviewage'])
                z @$groupHomeClashRoyaleDecks

              z @$groupHomeAddons

              if isTranslateCardVisible
                z @$groupHomeTranslate
            ]
