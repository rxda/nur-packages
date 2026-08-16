{
  default = final: prev: {
    bilibili-video-downloader = final.callPackage ../pkgs/bilibili-video-downloader { };
    deepseek-harness = final.callPackage ../pkgs/deepseek-harness { };
    hello-nur = final.callPackage ../pkgs/hello-nur { };
    sing-box-beta = final.callPackage ../pkgs/sing-box-beta { };
    tonghuashun = final.callPackage ../pkgs/tonghuashun { };
  };
}
