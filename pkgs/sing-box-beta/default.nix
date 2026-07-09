{
  buildGoModule,
  coreutils,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "sing-box";
  version = "1.13.4-beta.3";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    hash = "sha256-lAieNuT8A4Ip3zRgNH2iyAoiGMJ4RUoVXX8kfv9yswE=";
  };

  GOEXPERIMENT = "greenteagc,jsonv2";

  overrideModAttrs = (
    _: {
      GOEXPERIMENT = "greenteagc,jsonv2";
    }
  );

  vendorHash = "sha256-mfgCwTXwd6T1mzmHR3tTF4aKtfn4ehztVyeXrtEKDsk=";

  tags = [
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_gvisor"
    "with_tailscale"
  ];

  subPackages = [ "cmd/sing-box" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X github.com/sagernet/sing-box/constant.Version=${version}"
  ];

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf
  '';
}
