# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('input#new-activity-btn').click (event) ->
    $('.progress-bar').animate { width: '100%' }, 4000
    return
  return