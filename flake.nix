# SPDX-FileCopyrightText: 2022 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: CC0-1.0

{
  nixConfig = {
    flake-registry = "https://github.com/serokell/flake-registry/raw/master/flake-registry.json";
  };

  inputs = {
    flake-compat = {
      flake = false;
    };
    haskell-nix = {
      inputs.hackage.follows = "hackage";
      inputs.stackage.follows = "stackage";
    };
    hackage = {
      flake = false;
    };
    stackage = {
      flake = false;
    };
  };

  outputs = { self, nixpkgs, haskell-nix, hackage, stackage, serokell-nix, flake-compat, ... }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.extend
          (nixpkgs.lib.composeManyExtensions [ serokell-nix.overlay haskell-nix.overlay ]);

      lib = pkgs.lib;

      hs-package-name = "customerio-client";

      # invoke haskell.nix
      hs-pkgs = pkgs.haskell-nix.stackProject {
        src = pkgs.haskell-nix.haskellLib.cleanGit {
          name = hs-package-name;
          src = ./.;
        };

        # haskell.nix configuration
        modules = [{
          packages.${hs-package-name} = {
            ghcOptions = [
              # fail on warnings
              "-Werror"
              # disable optimisations, we don't need them if we don't package or deploy the executable
              "-O0"

              # for weeder: produce *.dump-hi files
              ##"-ddump-to-file" "-ddump-hi"
            ];

            # for weeder: collect all *.dump-hi files
            ##postInstall = weeder-hacks.collect-dump-hi-files;
          };

        }];
      };

      hs-pkg = hs-pkgs.${hs-package-name};

      # returns the list of all components for a package
      get-package-components = pkg:
        # library
        lib.optional (pkg ? library) pkg.library
        # haddock
        ++ lib.optional (pkg ? library) pkg.library.haddock
        # exes, tests and benchmarks
        ++ lib.attrValues pkg.exes
        ++ lib.attrValues pkg.tests
        ++ lib.attrValues pkg.benchmarks;

      # all components for the current haskell package
      all-components = pkgs.linkFarmFromDrvs "all-components" (get-package-components hs-pkg.components);

    in {
      # nixpkgs revision pinned by this flake
      legacyPackages.x86_64-linux = pkgs;

      # derivations that we can run from CI
      checks.x86_64-linux = {
        # builds all haskell components
        build-all = all-components;

        # runs the test
        # test = hs-pkg.checks.pataq-test;

        trailing-whitespace = pkgs.build.checkTrailingWhitespace ./.;
        reuse-lint = pkgs.build.reuseLint ./.;
      };
    };
}
