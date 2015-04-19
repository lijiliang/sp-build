# cart
define ['Swipe', 'FavoriteList'], (Swipe, FavoriteList)->

    page = ->

    page.init =->

        # 收藏夹列表
        favoriteList = new FavoriteList()
        favoriteList.init()

        initSwipe = ($el)->
            $swipe = $el.find '.swipe'
            $item = $swipe.find '.swipe-item'


            $prev = $el.find '.swipe-actions__prev'
            $next = $el.find '.swipe-actions__next'


            if $item.length > 1
                swipe = new Swipe $swipe[0],
                    startSlide: 0
                    speed: 400
                    auto: 0
                    continuous: true
                    disableScroll: false
                    stopPropagation: false
                    callback: (index, elem)->

                $prev.on 'click', ->
                    swipe.prev()
                    return false

                $next.on 'click', ->
                    swipe.next()
                    return false
            else
                $swipe.css 'visibility','visible'
                $prev.remove()
                $next.remove()


        initSwipe $ '#j-swipe'

    return page
