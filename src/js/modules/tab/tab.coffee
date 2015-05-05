define () ->
  Tab = (options) ->
    self = this
    $target = $(options.target)
    $uiTab = $target.find(".ui-tab")
    $uiTabContainer = $target.find(".ui-tab-container")
    headItemClass = ".ui-tab__item"
    $headItem = $uiTab.find(headItemClass) ;
    containerItemClass = ".ui-tab-container__item"
    $containerItem = $uiTabContainer.find(containerItemClass)
    activeClass = "_active"

    fn = () ->
      index = $(this).index()
      $(this).find(".index-tab__text").addClass activeClass
      .closest headItemClass
      .siblings headItemClass
      .find ".index-tab__text"
      .removeClass activeClass

      $containerItem.eq(index)
      .show()
      .siblings containerItemClass
      .hide()

      if(options.callback)
        options.callback(index)

      return false

    $headItem.on "click", fn
    self
  return Tab
