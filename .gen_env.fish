#!/usr/bin/env fish

# Set the path to the environment JSON file
set -g ENV_FILE "$HOME/.env.json"

# Check if the environment file exists
if test -f $ENV_FILE
    # Parse the JSON file using jq if available
    if type -q jq
        # Set variables defined in the JSON file
        for var in (jq -r '.variables | keys[]' $ENV_FILE)
            set -gx $var (jq -r ".variables.$var" $ENV_FILE)
        end

        # Add paths from the JSON file to the PATH
        if jq -e '.paths_to_add' $ENV_FILE >/dev/null
            for path_entry in (jq -r '.paths_to_add[]' $ENV_FILE)
                # Replace any variables in the path
                set expanded_path (eval echo $path_entry)

                # Add to PATH if it's not already there and the directory exists
                if test -d $expanded_path; and not contains $expanded_path $PATH
                    set -gx PATH $expanded_path $PATH
                    echo "Added to PATH: $expanded_path"
                end
            end
        end
    else
        echo "jq is not installed. Cannot parse JSON environment file."
        echo "Install jq with: brew install jq"
    end
else
    echo "Environment file not found: $ENV_FILE"
end
