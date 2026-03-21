name: 🐛 Bug Report
description: 报告一个 Bug
title: '[Bug] '
labels: ['bug']
body:
  - type: markdown
    attributes:
      value: |
        ## Bug 描述
        请简洁明了地描述这个问题。

  - type: textarea
    id: steps
    attributes:
      label: 复现步骤
      placeholder: |
        1. 进入 '...'
        2. 点击 '....'
        3. 滚动到 '....'
        4. 看到错误
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: 期望行为
      placeholder: 描述你期望发生的事情

  - type: textarea
    id: screenshots
    attributes:
      label: 截图/录屏
      placeholder: 如果有截图或录屏，请在这里粘贴

  - type: dropdown
    id: platform
    attributes:
      label: 平台
      options:
        - iOS
        - Android
        - Web
        - macOS
        - Linux
        - Windows
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: Flutter 版本
      placeholder: 例如：3.24.0

  - type: input
    id: device
    attributes:
      label: 设备信息
      placeholder: 例如：iPhone 14, Android 13
