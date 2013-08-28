helpers = require 'habitrpg-shared/script/helpers'
algos = require 'habitrpg-shared/script/algos'
browser = require './browser'
items = require './items'
misc = require './misc'
_ = require 'lodash'

module.exports.app = (appExports, model) ->
  user = model.at('_user')

  appExports.revive = ->
    [uObj, paths] = [user.get(), {}]
    algos.revive(uObj, {paths})
    _.each paths, ((v,k) -> user.set k, helpers.dotGet(k, uObj))

  appExports.reset = (e, el) ->
    misc.batchTxn model, (uObj, paths, batch) ->
      batch.set 'tasks', {}
      ['habit', 'daily', 'todo', 'reward'].forEach (type) -> batch.set("#{type}Ids", [])
      _.each {hp:50, lvl:1, gp:0, exp:0}, (v,k) -> batch.set("stats.#{k}",v)
      _.each {armor:0, weapon:0, head:0, shield:0}, (v,k) -> batch.set("items.#{k}",v)
    browser.resetDom(model)

  appExports.closeNewStuff = (e, el) ->
    user.set('flags.newStuff', 'hide')

  appExports.customizeGender = (e, el) ->
    user.set 'preferences.gender', $(el).attr('data-value')

  appExports.customizeHair = (e, el) ->
    user.set 'preferences.hair', $(el).attr('data-value')

  appExports.customizeSkin = (e, el) ->
    user.set 'preferences.skin', $(el).attr('data-value')

  appExports.customizeArmorSet = (e, el) ->
    user.set 'preferences.armorSet', $(el).attr('data-value')

  appExports.restoreSave = ->
    misc.batchTxn model, (uObj, paths, batch) ->
      $('#restore-form input').each ->
        [path, val] = [$(this).attr('data-for'), parseInt($(this).val() || 1)]
        batch.set(path,val)

  appExports.toggleHeader = (e, el) ->
    user.set 'preferences.hideHeader', !user.get('preferences.hideHeader')

  appExports.deleteAccount = (e, el) ->
    model.del "users.#{user.get('id')}", ->
      location.href = "/logout"

  appExports.profileAddWebsite = (e, el) ->
    newWebsite = model.get('_newProfileWebsite')
    return if /^(\s)*$/.test(newWebsite)
    user.unshift 'profile.websites', newWebsite
    model.set '_newProfileWebsite', ''

  appExports.profileEdit = (e, el) -> model.set '_profileEditing', true
  appExports.profileSave = (e, el) -> model.set '_profileEditing', false
  appExports.profileRemoveWebsite = (e, el) ->
    sites = user.get 'profile.websites'
    i = sites.indexOf $(el).attr('data-website')
    sites.splice(i,1)
    user.set 'profile.websites', sites

  appExports.toggleResting = ->
    model.set '_user.flags.rest', !model.get('_user.flags.rest')
