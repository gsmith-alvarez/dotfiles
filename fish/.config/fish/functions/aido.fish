function aido --description "Select a local Ollama model via fzf and launch aider"
    set -l model (ollama list | awk 'NR>1 {print $1}' | fzf --prompt="Select Ollama Model: ")

    if test -n "$model"
        aider --model "ollama_chat/$model" $argv
    end
end
