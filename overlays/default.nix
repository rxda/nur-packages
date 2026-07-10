{
  default = final: prev: {
    bilibili-video-downloader = final.callPackage ../pkgs/bilibili-video-downloader { };
    hello-nur = final.callPackage ../pkgs/hello-nur { };
    sing-box-beta = final.callPackage ../pkgs/sing-box-beta { };
    tongdaxin = final.callPackage ../pkgs/tongdaxin { };
    tonghuashun = final.callPackage ../pkgs/tonghuashun { };
  };
}
