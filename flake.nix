{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv/6a30b674fb5a54eff8c422cc7840257227e0ead2";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;

              modules = [
                {
                  # https://devenv.sh/reference/options/

                  env = { };

                  packages = with pkgs; [
                  ];

                  languages.javascript = {
                    enable = true;
                  };

                  processes = {
                    monerod = {
                      exec = "${pkgs.monero-cli}/bin/monerod --non-interactive --stagenet --data-dir $DEVENV_STATE/.bitmonero";
                    };
                  };

                  enterShell = ''
                  '';
                }
              ];
            };
          });
    };

}
