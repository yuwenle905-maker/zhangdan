# 本地账单 - 固定支出提醒看板

## 项目说明

SwiftUI + SwiftData 开发的本地财务提醒 App，无网络请求，通过 TrollStore 签名安装。

## 功能特性

- 5 个分类：信用卡、花呗、抚养费、房租（红色/待还款）、投资（绿色）
- 看板：本月待付总额 + 总投资额，深色 `.ultraThinMaterial` 圆角卡片
- 垂直时间轴：按到期日排序，一眼看清全部待办
- 点击卡片查看详情，"标记为已完成" 自动将到期日滚动到下个周期（月/周）
- 本地推送：提前 3 天 + 到期当日各一条提醒
- FaceID / Touch ID / 锁屏密码强制验证，前台恢复时重新锁定
- SwiftData 使用 App Group 容器存储，为后续 Widget 预留数据接口

## 编译方法

### 环境要求

- macOS 13+
- Xcode 15+
- XcodeGen（用于生成 .xcodeproj）

### 步骤

```bash
# 1. 安装 XcodeGen
brew install xcodegen

# 2. 克隆项目
git clone https://github.com/yuwenle905-maker/zhangdan.git
cd zhangdan

# 3. 生成 Xcode 项目
xcodegen generate --spec project.yml

# 4. 本地构建（TrollStore 免签）
xcodebuild \
  -project 本地账单.xcodeproj \
  -scheme 本地账单 \
  -configuration Release \
  -sdk iphoneos \
  ARCHS=arm64 CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  build
```

打包为 IPA 后用 TrollStore 直接安装。

## App Group

如需实现桌面 Widget，请复用 `group.com.yourname.zhangdan` App Group，
通过 `ModelContainerFactory.make()` 读取同一份 SwiftData 数据。
