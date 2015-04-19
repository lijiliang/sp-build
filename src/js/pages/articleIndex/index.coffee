# cart
define ['Sp','liteModalBox'], (Sp, LiteModalBox)->

    page = ->

    page.init = ->
        `
        var tabsClass = {
            'container': '.tabs',
            'title': '.tabs_title',
            'content': '.tabs_content',
            'active': 'this--active'
        };
        $('body').on('click', tabsClass.title, function() {
            var $this = $(this);

            if ($this.hasClass(tabsClass.active)) return;

            var $container = $this.closest(tabsClass.container)
            ,   $titles = $container.find(tabsClass.title)
            ,   $contents = $container.find(tabsClass.content)
            ,   index = $titles.index($this);

            $titles.removeClass(tabsClass.active);
            $this.addClass(tabsClass.active);
            $contents.hide().eq(index).show();
        });
        `
        emailBox = null
        $("#j-email-modal-show").on "click",->
            if(!emailBox)
                emailBox = new LiteModalBox
                    top: 250
                    mask: true
                    title: '邮箱服务'
                    contents: '“请您将邮件发送至service@sipin.com，我们会在第一时间给您回复。”'
                    closeBtn: true
            emailBox.show()
            return false

    return  page
