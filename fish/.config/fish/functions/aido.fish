function aido --description "Select a local Ollama model via fzf and launch aider"
    # Make sure the tools we rely on are actually available
    for tool in ollama fzf aider
        command -q "$tool" || return 127
    end

    set -l model (ollama list | awk 'NR>1 {print $1}' | fzf --prompt="Select Ollama Model: ")

    if test -n "$model"
        aider --model "ollama_chat/$model" $argv
    else
        echo "No Ollama model selected."
        return 1
    end
end
