cask "oneclip" do
  version "2.1.0"
  sha256 "2f754c9c62e8a203ad9d52e44a5abd3a443fbd78d61066dd916b62c15ad7b821"

  url "https://gitee.com/oneclip/OneClip/releases/download/#{version}/OneClip-#{version}.dmg"
  name "OneClip"
  desc "Professional clipboard manager"
  homepage "https://oneclip.cloud/"

  livecheck do
    url "https://gitee.com/oneclip/OneClip/releases"
    regex(/OneClip[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end

  depends_on macos: :monterey

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
