# 下拉菜单
define ()->
    goodListHover = ->

    goodListHover.init = ->
        #$goodListBox 商品列表 hover 效果
        $goodListBox = $('#j-good-list-box')
        if($goodListBox.length)
            $item = $goodListBox.find('.good-list-item');
            spans = if $item.eq(0).hasClass('_item_span6') then 2 else (if $item.eq(0).hasClass('_item_span3') then 4 else 0)
            $listBox = $goodListBox.find('.new-goods-list-box')
            $box = $('<div class="new-goods-list-box new-goods-list-box__clone"></div>')
            $listBox.before($box)
            # $item.hover ->
            $item.on 'mouseenter', ()->
                $this = $(this)
                $clone = $this.clone()
                offset = $this.offset()
                listBoxOffset = $listBox.offset()
                $clone
                .addClass('good-list-item__clone')
                .css
                    left: (100 / spans) * ($this.index() % spans) + '%',
                    top: offset.top - listBoxOffset.top
                $box.html($clone)

            $goodListBox.on 'mouseleave', '.good-list-item__clone', ->
                $(this).remove()

    return  goodListHover
