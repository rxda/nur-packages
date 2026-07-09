{ writeShellApplication }:

writeShellApplication {
  name = "hello-nur";

  text = ''
    echo "Hello from NUR"
  '';
}
