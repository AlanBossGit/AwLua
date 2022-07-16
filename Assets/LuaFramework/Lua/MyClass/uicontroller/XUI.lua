XUI = XUI or BaseClass()


--添加按钮事件绑定：
function XUI.AddButtonClickEventListener(node, click_callback)
    print_error("===",node.button.onClick)
    node.button.onClick:AddListener(function()
        print_error("11111")
    end)
end
--移除按钮事件绑定：
function XUI.RemoveButtonClickEventListener(node, click_callback)
    node.button.onClick:RemoveListener(click_callback)
end
--移除按钮所有点击事件
function XUI.RemoveAllListener(node)
    node.button.onClick:RemoveAllListeners()
end
