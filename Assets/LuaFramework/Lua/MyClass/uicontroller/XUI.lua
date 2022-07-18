XUI = XUI or BaseClass()


--添加按钮事件绑定：
function XUI.AddClickEventListener(node, click_callback)
    node.button:AddClickListener(click_callback)
end
--移除按钮事件绑定：
function XUI.RemoveButtonClickEventListener(node, click_callback)
    node.button:RemoveListener(click_callback)
end
--移除按钮所有点击事件
function XUI.RemoveAllListener(node)
    node.button:RemoveAllListeners()
end
