# Prepare all stacks for local development
develop:
    #!/usr/bin/env bash
    set -euo pipefail
    ROOT_DIR="modules"
    # Iterate through likely module directories (two and three levels deep)
    for dir in $(ls -d "$ROOT_DIR"/* "$ROOT_DIR"/*/* 2>/dev/null); do
        base="$(basename "$dir")"
        # Skip directories starting with '_'
        if [[ "$base" == _* ]]; then
            continue
        fi
        if ls "$dir"/*.tofu >/dev/null 2>&1; then
            echo "Initializing tofu module in: $dir"
            (cd "$dir" && tofu init -upgrade)
        fi
    done

test:
    cd test && go test -v
