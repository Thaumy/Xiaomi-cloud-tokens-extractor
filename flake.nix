{
  inputs = {
    pkgs.url = "github:NixOS/nixpkgs/fa1c3479a64ddf680c846dc1af05d3c0e64172f3"; # 26-2-11
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b"; # 24-11-14
    rust-overlay = {
      url = "github:oxalica/rust-overlay/095c394bb91342882f27f6c73f64064fb9de9f2a"; # 26-2-4
      inputs.nixpkgs.follows = "pkgs";
    };
  };

  outputs = inputs: inputs.flake-utils.lib.eachSystem
    [ "x86_64-linux" ]
    (system:
      let
        pkgs = import inputs.pkgs {
          inherit system;
          overlays = [ (import inputs.rust-overlay) ];
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
      in
      {
        devShells.default = with pkgs; pkgs.mkShell {
          name = "xm-token-extractor";

          venvDir = "./.venv";

          buildInputs = [
            python313
            python313Packages.pip
            python313Packages.python
            python313Packages.venvShellHook
          ];

          # Run this command, only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -r requirements.txt
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
          '';
        };
      }
    );
}
