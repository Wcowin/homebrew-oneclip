cask "oneclip" do
  version "1.4.0"
  sha256 "57b0fa677f21ccf11f6beba2837d9c860b7361584a442b4b9ee4d70ff9c9cc9c"

  # 使用 Gitee 国内源，确保国内用户下载稳定
  url "https://gitee.com/Wcowin/OneClip/releases/download/#{version}/OneClip-#{version}.dmg"
  name "OneClip"
  desc "Professional clipboard manager for macOS"
  homepage "https://oneclip.cloud/"

  livecheck do
    url "https://gitee.com/Wcowin/OneClip/releases"
    regex(/OneClip[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end

  depends_on macos: ">= :monterey"


  app "OneClip.app"

  zap trash: [
    "~/Library/Application Support/OneClip",
    "~/Library/Caches/com.wcowin.OneClip",
    "~/Library/HTTPStorages/com.wcowin.OneClip",
    "~/Library/Preferences/com.wcowin.OneClip.plist",
    "~/Library/Saved Application State/com.wcowin.OneClip.savedState",
    "~/Library/WebKit/com.wcowin.OneClip",
  ]
end
