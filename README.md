    git clone https://github.com/broom9/pbup.git
    cd pbup/
    echo "Put some sample text in clipboard" | pbcopy
    pbup
    open `pbpaste` # Pastie.org URL should be ready in your clipboard
