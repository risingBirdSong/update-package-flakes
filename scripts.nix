{s}: rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:aaa' --allow-eval --warnings";
  allScripts = [ghcidScript];
}
