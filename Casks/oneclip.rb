cask "oneclip" do
  version "2.0.5"
  sha256 "fa935fb2e9c0c082a95dd90a6feaee334d4b8a3c5212e1a109a0946f31a4ddb9"

  url "https://gitee.com/oneclip/OneClip/releases/download/#{version}/OneClip-#{version}.dmg",
      verified: "gitee.com/oneclip/OneClip/"
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
