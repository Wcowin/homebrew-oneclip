cask "oneclip" do
  version "1.6.0"
  sha256 "0c85830b552855abbbdc199b2946eaa6e6cc36cea2e0146673b99d85ba368d6a"

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
