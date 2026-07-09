{
  default = final: prev: {
    bilibili-video-downloader = final.callPackage ../pkgs/bilibili-video-downloader { };
    hello-nur = final.callPackage ../pkgs/hello-nur { };
    sing-box-beta = final.callPackage ../pkgs/sing-box-beta { };
    tonghuashun = final.callPackage ../pkgs/tonghuashun { };
  };
}
