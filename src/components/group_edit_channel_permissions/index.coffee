z = require 'zorium'

GroupRolePermissions = require '../group_role_permissions'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannelPermissions
  constructor: ({@model, @router, group, conversation, gameKey}) ->
    me = @model.user.getMe()

    permissionTypes = [
      'readMessages'
    ]

    @$groupRolePermissions = new GroupRolePermissions {
      @model, @router, group, gameKey, permissionTypes
      conversation, onSave: @save
    }

    @state = z.state
      me: me
      group: group
      conversation: conversation

  save: (roleId, permissions) =>
    {group, conversation} = @state.getValue()

    @model.groupRole.updatePermissions(
      {roleId, channelId: conversation.id, groupId: group.id, permissions}
    )

  render: =>
    {me} = @state.getValue()

    z '.z-group-edit-channel-permissions',
      @$groupRolePermissions
