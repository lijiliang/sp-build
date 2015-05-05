# 规格属性选择
define ()->
    GoodTypeSelect = (options)->
        #属性集
        keys = []
        skuGroup = $(".sku-group");
        skuGroup.each ()->
            key = []
            $(this).find(".sku-attr").each ()->
                key.push $(this).data("sid")
            keys.push(key)
        #后台读取结果集

        # 处理后台数据
        toData = ()->
            result = {}
            skuObj = window.skuObj
            #console.log skuObj
            return false if !skuObj
            for sku in skuObj
                attr_item = []
                attributeKeyGroup = sku["attribute_key"].split(",")
                for attributeKeyGroup_item in attributeKeyGroup
                    _attr_item = attributeKeyGroup_item.split("-")
                    attr_item.push _attr_item[1]
                getKey = ()->
                    # console.log(attr_item)
                    # attr_item.join(";")
                    attr_item.sort (a,b)->
                        return parseInt(a)-parseInt(b)
                    return attr_item.join(";")
                result[getKey()] =
                    price:sku.price
                    skuSn:sku["sku_sn"]
                    goods:sku["goods_id"]
                    url: sku['url']
            result
        data = toData()
        ###data =
            "10;20;30;":
                price: 5
                count: 3
            "10;20;31;":
                price: 50
                count: 2
            "11;20;32;":
                price: 80
                count: 2###
        #保存最后的组合结果信息
        SKUResult = {}
        #初始化用户选择事件
        #获得对象的key
        getObjKeys = (obj) ->
            if (obj != Object(obj))
                throw new TypeError('Invalid object')
            keys = []
            for key of obj
                if Object::hasOwnProperty.call(obj, key)
                    keys[keys.length] = key
            keys

        #把组合的key放入结果集SKUResult
        add2SKUResult = (combArrItem, sku) ->
            key = combArrItem.join(';')
            if SKUResult[key]
                #SKU信息key属性·
                SKUResult[key].skuSn = sku['skuSn']
                #SKUResult[key].count += sku.count
                SKUResult[key].prices.push sku.price
            else
                SKUResult[key] =
                    skuSn: sku['skuSn']
                    #count: sku.count
                    prices: [sku.price]
                    url: sku['url']
            return

        #初始化得到结果集
        initSKU = ->
            skuKeys = getObjKeys(data)
            i = 0
            while i < skuKeys.length
                skuKey = skuKeys[i]
                #一条SKU信息key
                sku = data[skuKey]
                #一条SKU信息value
                skuKeyAttrs = skuKey.split(';')
                #SKU信息key属性值数组
                len = skuKeyAttrs.length
                #对每个SKU信息key属性值进行拆分组合
                combArr = arrayCombine(skuKeyAttrs)
                j = 0
                while j < combArr.length
                    add2SKUResult combArr[j], sku
                    j++
                #结果集接放入SKUResult
                SKUResult[skuKey] =
                    #count: sku.count
                    skuSn: sku['skuSn']
                    prices: [sku.price]
                    url: sku['url']
                i++
            return

        ###
        # 从数组中生成指定长度的组合
        ###

        arrayCombine = (targetArr) ->
            if !targetArr or !targetArr.length
                return []
            len = targetArr.length
            resultArrs = []
            # 所有组合
            n = 1
            while n < len
                flagArrs = getFlagArrs(len, n)
                while flagArrs.length
                    flagArr = flagArrs.shift()
                    combArr = []
                    i = 0
                    while i < len
                        flagArr[i] and combArr.push(targetArr[i])
                        i++
                    resultArrs.push combArr
                n++
            resultArrs

        ###
        # 获得从m中取n的所有组合
        ###
        getFlagArrs = (m, n) ->
            if !n or n < 1
                return []
            resultArrs = []
            flagArr = []
            isEnd = false
            i = 0
            while i < m
                flagArr[i] = if i < n then 1 else 0
                i++
            resultArrs.push flagArr.concat()
            while !isEnd
                leftCnt = 0
                k = 0
                while k < m - 1
                    if (flagArr[k] == 1) and (flagArr[k + 1] == 0)
                        j = 0
                        while j < k
                            flagArr[j] = if j < leftCnt then 1 else 0
                            j++
                        flagArr[k] = 0
                        flagArr[k + 1] = 1
                        aTmp = flagArr.concat()
                        resultArrs.push aTmp
                        if (aTmp.slice(-n).join('').indexOf('0') == -1)
                            isEnd = true
                        break
                    (flagArr[k] == 1) and leftCnt++
                    k++
            resultArrs

        setPrice = (key,jump)->
            # 价格
            prices = SKUResult[key].prices
            # 库存
            count = SKUResult[key].count
            maxPrice = Math.max.apply(Math, prices)
            minPrice = Math.min.apply(Math, prices)
            if maxPrice > minPrice
                #$('#price').text '¥ '+minPrice + '-' + '¥ '+maxPrice
                $("#j-add-to-cart").addClass '_disable'
            else
                # 如果不等于当前SKU
                if jump
                    window.location.href = SKUResult[key]["url"]
                #window.location.href = '/goods?sid='+SKUResult[key]["skuSn"]
                #$('#price').text '¥ '+maxPrice
                $("#j-add-to-cart").removeClass '_disable'

        getSelectedIds= ()->
            selectedObjs = $('.sku-attr._active')
            selectedIds = []
            selectedObjs.each ->
                selectedIds.push $(this).data('sid')
                return
            selectedIds.sort (value1, value2) ->
                parseInt(value1) - parseInt(value2)
            selectedIds

        setState = (jump)->
            #已经选择的节点
            selectedObjs = $('.sku-attr._active')
            if selectedObjs.length
                #获得组合key价格
                selectedIds = getSelectedIds()
                len = selectedIds.length
                setPrice(selectedIds.join(';'),jump)
                #用已选中的节点验证待测试节点 underTestObjs
                $('.sku-attr').not(selectedObjs).not(self).each ->
                    siblingsSelectedObj = $(this).siblings('.sku-attr._active')
                    testAttrIds = []
                    #从选中节点中去掉选中的兄弟节点
                    if siblingsSelectedObj.length
                        siblingsSelectedObjId = siblingsSelectedObj.data('sid')
                        i = 0
                        while i < len
                            (selectedIds[i] != siblingsSelectedObjId) and testAttrIds.push(selectedIds[i])
                            i++
                    else
                        testAttrIds = selectedIds.concat()
                    testAttrIds = testAttrIds.concat($(this).data('sid'))
                    testAttrIds.sort (value1, value2) ->
                        parseInt(value1) - parseInt(value2)
                    if !SKUResult[testAttrIds.join(';')]
                        $(this).addClass("_disable").removeClass '_active'
                    else
                        $(this).removeClass '_disable'
                    return
            else
                #设置默认价格
                #selectedIds = getSelectedIds()
                #setPrice(selectedIds.join(';'),true)
                #设置属性状态
                $('.sku-attr').each ->
                    if SKUResult[$(this).attr('attr_id')] then $(this).removeClass '_disable' else $(this).addClass('_disable').removeClass("_active")
                    return

        init = ()->
            initSKU()
            $('.sku-attr').each(->
                setState();
                #selectedIds = getSelectedIds()
                #setPrice(selectedIds.join(';'))
                return
            ).click ->
                if($(this).hasClass("_disable"))
                    return;
                $(this).addClass("_active").siblings().removeClass("_active")
                setState(true);
                return
            return

        init();


    return  GoodTypeSelect
