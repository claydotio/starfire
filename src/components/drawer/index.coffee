z = require 'zorium'
Button = require 'zorium-paper/button'
_ = require 'lodash'

Icon = require '../icon'
Avatar = require '../avatar'
colors = require '../../colors'

if window?
  require './index.styl'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

module.exports = class Drawer
  constructor: ({@model, @router}) ->
    @$avatar = new Avatar()

    @state = z.state
      isOpen: @model.drawer.isOpen()
      me: @model.user.getMe()

      menuItems: [
        {
          path: '/profile'
          title: 'Profile'
          $icon: new Icon()
          iconName: 'profile'
        }
        {
          path: '/threads'
          title: 'Community'
          $icon: new Icon()
          iconName: 'chat'
        }
        {
          path: '/conversations'
          title: 'Private messages'
          $icon: new Icon()
          iconName: 'chat'
        }
        {
          path: '/members'
          title: 'Members'
          $icon: new Icon()
          iconName: 'friends'
        }
        {
          path: '/decks'
          title: 'Battle Decks'
          $icon: new Icon()
          iconName: 'decks'
        }
        {
          isDivider: true
        }
        {
          path: '/settings'
          title: 'Settings'
          $icon: new Icon()
          iconName: 'settings'
        }
      ]


  render: ({currentPath}) =>
    {isOpen, me, menuItems} = @state.getValue()

    setTimeout =>
      @state.set test: Math.random()
    , 3000

    drawerWidth = Math.min \
      window?.innerWidth - DRAWER_RIGHT_PADDING, DRAWER_MAX_WIDTH
    translateX = if isOpen then '0' else "-#{drawerWidth}px"

    z '.z-drawer', {
      className: z.classKebab {isOpen}
      style:
        display: if window? then 'block' else 'none'
    },
      z '.overlay', {
        onclick: (e) =>
          e?.preventDefault()
          @model.drawer.close()
      }

      z '.drawer', {
        style:
          width: "#{drawerWidth}px"
          transform: "translate(#{translateX}, 0)"
          webkitTransform: "translate(#{translateX}, 0)"
      },
        z '.header',
          z '.user-header',
            z '.avatar',
              z @$avatar, {size: '86px', user: me}
            z '.name', @model.user.getDisplayName(me)
            z '.join-date', 'Join date here' # FIXME FIXME
        z '.content',
          z 'ul.menu',
            _.map menuItems, ({path, title, $icon, iconName, isDivider}) =>
              if isDivider
                return z 'li.divider'
              isSelected = currentPath?.indexOf(path) is 0 or (
                path is '/games' and currentPath is '/'
              )
              z 'li.menu-item', {
                className: z.classKebab {isSelected}
              },
                z 'a.menu-item-link', {
                  href: path
                  onclick: (e) =>
                    e.preventDefault()
                    @model.drawer.close()
                    @router.go path
                },
                  z '.icon',
                    z $icon,
                      isTouchTarget: false
                      icon: iconName
                      color: colors.$primary500
                  title