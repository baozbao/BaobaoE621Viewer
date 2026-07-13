/// 全 App 文案集中管理（D2:统一为中文，消除中英混排）。
/// 需要做多语言时，把这里替换为 flutter_localizations + arb 即可。
class Strings {
  // 通用
  static const appName = 'E621 浏览器';
  static const retry = '重试';
  static const cancel = '取消';
  static const confirm = '确定';
  static const add = '添加';
  static const done = '完成';
  static const manage = '管理';
  static const copy = '复制';
  static const copied = '已复制';

  // 首页
  static const browse = '浏览';
  static const popular = '热门';
  static const favorites = '收藏';
  static const settings = '设置';
  static const sortLabel = '排序:';
  static const ratingLabel = '评级:';
  static const sortScore = '高分';
  static const sortFav = '收藏';
  static const sortNewest = '最新';
  static const sortRandom = '随机';
  static const sortRank = '热度';
  static const ratingAll = '全部';
  static const ratingSafe = 'S';
  static const ratingQuestionable = 'Q';
  static const ratingExplicit = 'E';
  static const jumpPageTitle = '跳转页码';
  static const jumpPageHint = '输入页码';
  static const jumpPageInvalid = '请输入有效的正整数';
  static const jump = '跳转';
  static const backToTop = '返回顶部';

  // 空/错误状态
  static const errorNetwork = '网络连接失败，请检查网络后重试';
  static const errorTimeout = '请求超时，服务器响应过慢';
  static const errorServer = '服务器出错了，请稍后再试';
  static const errorUnknown = '加载失败';
  static const emptyResultTitle = '没有找到相关作品';
  static const emptyResultHint = '换个标签试试，或检查黑名单是否过滤了全部结果';
  static const clearSearch = '清除搜索';
  static const noSearchHistory = '暂无搜索历史';

  // 详情页
  static const detailTitle = '详情';
  static const download = '下载';
  static const share = '分享';
  static const openInBrowser = '在浏览器打开';
  static const copyLink = '复制链接';
  static const tags = '标签';
  static const imageInfo = '图片信息';
  static const description = '简介';
  static const source = '来源';
  static const tagArtist = '画师';
  static const tagCopyright = '版权';
  static const tagCharacter = '角色';
  static const tagSpecies = '种族';
  static const tagGeneral = '通用';
  static const tagMeta = '元信息';
  static const searchThisTag = '以此搜索';
  static const appendToSearch = '追加到当前搜索';
  static const addToBlacklist = '加入黑名单';

  // 下载
  static const downloadChooseQuality = '选择下载画质';
  static const downloadOriginal = '原图';
  static const downloadSample = '采样图';
  static const downloading = '正在下载…';
  static const downloadSaved = '已保存到相册';
  static const downloadFailed = '下载失败';
  static const downloadWebDisabled = 'Web 模式不支持下载（需 Android/iOS）';
  static const permissionDenied = '存储权限被拒绝';

  // 设置
  static const settingsTitle = '应用设置';
  static const sectionGeneral = '通用设置';
  static const sectionDisplay = '显示设置';
  static const sectionDev = '开发者选项';
  static const appearance = '外观';
  static const appearanceSystem = '跟随系统';
  static const appearanceLight = '浅色';
  static const appearanceDark = '深色';
  static const contentSource = '内容源';
  static const contentSourceFull = 'e621.net（完整内容）';
  static const contentSourceSafe = 'e926.net（仅 Safe 内容）';
  static const contentSourceSwitched = '内容源已切换';
  static const enableBlacklist = '启用黑名单';
  static const enableBlacklistSub = '过滤包含黑名单标签的作品';
  static const editBlacklist = '编辑黑名单';
  static const editBlacklistSub = '添加或删除黑名单标签';
  static const previewGrid = '预览与网格设置';
  static const previewGridSub = '调整缩略图高度、列数与加载数量';
  static const layoutMode = '布局模式';
  static const layoutMasonry = '瀑布流';
  static const layoutGrid = '等高网格';
  static const browseMode = '浏览模式';
  static const browseModeInfinite = '无限滚动';
  static const browseModePaged = '分页';
  static const historyTitle = '浏览历史';
  static const historySub = '查看最近打开过的作品';
  static const historyEmpty = '暂无浏览历史';
  static const historyEmptyHint = '你查看过的帖子会显示在这里';
  static const clearHistory = '清空历史';
  static const clearHistoryConfirm = '确定要清空全部浏览历史吗？';
  static const systemLogs = '系统日志';
  static const systemLogsSub = '查看网络请求与图片加载的报错日志';

  // 黑名单
  static const blacklistTitle = '编辑黑名单';
  static const blacklistEmpty = '暂无黑名单标签';
  static const blacklistAddTitle = '添加黑名单标签';
  static const blacklistAddHint = '输入标签，可用空格/逗号分隔批量添加';
  static const blacklistImportPreset = '导入 e621 默认预设';
  static const blacklistPresetImported = '已导入默认黑名单预设';

  // 收藏
  static const favoritesTitle = '我的收藏';
  static const favoritesEmpty = '还没有收藏任何作品';
  static const favoritesEmptyHint = '在详情页点 ♡ 即可收藏';
  static const added2Favorites = '已加入收藏';
  static const removedFromFavorites = '已取消收藏';

  // 热门
  static const popularTitle = '热门';
  static const popularDay = '日榜';
  static const popularWeek = '周榜';
  static const popularMonth = '月榜';
}
