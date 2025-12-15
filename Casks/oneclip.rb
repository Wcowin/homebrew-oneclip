cask "oneclip" do
  version "1.4.1"
  sha256 "c780ac4d302940c16ede715616c269fe6031ea2295317e1517b743332d828138"

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
