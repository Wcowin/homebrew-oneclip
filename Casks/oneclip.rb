cask "oneclip" do
  version "1.2.7"
  sha256 "7689c0596f0b44530a59d384cdeb133e38f6fc7767fdda416310325a12a4530c"

  url "https://gitee.com/Wcowin/OneClip/releases/download/#{version}/OneClip-#{version}-apple-silicon.dmg"
  name "OneClip"
  desc "Professional clipboard manager"
  homepage "https://oneclip.cloud/"

  livecheck do
    url "https://gitee.com/Wcowin/OneClip/releases"
    regex(/OneClip[._-]v?(\d+(?:\.\d+)+)[._-]apple[._-]silicon\.dmg/i)
  end

  depends_on macos: ">= :monterey"
  depends_on arch: :arm64

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
