define ()->
  Menu = (options)->
    self = this
    $target = $(options.target);
    itemClass = ".category-menu__item"
    $item = $target.find(itemClass);
    activeClass = "category-menu__item--active"

    mouseenterFn = ()->
      $pop_item = $(this).find ".category-menu__pop-item"
      $(this).addClass activeClass
             .siblings itemClass
             .removeClass activeClass
      return false

    mouseleaveFn = ()->
      $(this).removeClass activeClass
      return false

    $item.on "mouseenter",mouseenterFn
    $item.on "mouseleave",mouseleaveFn
    self
  Menu
