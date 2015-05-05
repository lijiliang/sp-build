checkStrong = (value)->
    modes = 1
    return 0 if value.length<1
    return 1 if value.length <= 5
    modes++ if /\d/.test(value) #数字
    modes++ if /[a-z]/.test(value) #小写
    modes++ if /[A-Z]/.test(value) #大写
    modes++ if /\W/.test(value) #特殊字符

    switch modes
        when 1
            return 1
        when 2
            return 2
        when 3
            return 3
        when 4
            return 4
        when 5
            return if value.length <12 then 4 else 5

module.exports = checkStrong;
