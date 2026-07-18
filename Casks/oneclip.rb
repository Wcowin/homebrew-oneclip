cask "oneclip" do
  version "2.0.1"
  sha256 "66173b22cf536179b7aaf23de3cedf19418855c77dfdd5ce7daaff13fd6356ab"

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
