{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          system,
          ...
        }:
        {
          treefmt = {
            flakeCheck = true;
            settings.excludes = [
              "*.sops.*"
            ];
            programs = {
              nixfmt.enable = true;
              hclfmt.enable = true;
              just.enable = true;
              terraform.enable = true;
              terraform.includes = [
                "*.tofu"
                "*.tfvars"
                "*.tftest.hcl"
              ];
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              just
              expect
              opentofu
              tofu-ls
              terragrunt
            ];

            inputsFrom = [ config.treefmt.build.devShell ];
          };
        };
    };
}
