
{ stdenv, buildGoPackage, fetchFromGitHub, go-bindata }:

buildGoPackage rec {
  name = "kops-${version}";
  version = "1.9.0";

  goPackagePath = "k8s.io/kops";

  src = fetchFromGitHub {
    rev = version;
    owner = "kubernetes";
    repo = "kops";
    sha256 = "03avkm7gk2dqyvd7245qsca1sbhwk41j9yhc208gcmjgjhkx2vn7";
  };

  buildInputs = [go-bindata];
  subPackages = ["cmd/kops"];

  buildFlagsArray = ''
    -ldflags=
        -X k8s.io/kops.Version=${version}
        -X k8s.io/kops.GitVersion=${version}
  '';

  preBuild = ''
    (cd go/src/k8s.io/kops
     go-bindata -o upup/models/bindata.go -pkg models -prefix upup/models/ upup/models/...)
  '';

  postInstall = ''
    mkdir -p $bin/share/bash-completion/completions
    mkdir -p $bin/share/zsh/site-functions
    $bin/bin/kops completion bash > $bin/share/bash-completion/completions/kops
    $bin/bin/kops completion zsh > $bin/share/zsh/site-functions/_kops
  '';

  meta = with stdenv.lib; {
    description = "Easiest way to get a production Kubernetes up and running";
    homepage = https://github.com/kubernetes/kops;
    license = licenses.asl20;
    maintainers = with maintainers; [offline zimbatm];
    platforms = platforms.unix;
  };
}
