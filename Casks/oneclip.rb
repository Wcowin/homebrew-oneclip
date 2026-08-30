cask "oneclip" do
  version "2.0.8"
  sha256 "23701caa0457bb82a9160a3650258a1f1386630bf02d824ef8679120cf4015c3"

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
