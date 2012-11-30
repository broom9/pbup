A small tool to upload clipboard content to pastie.org and copy pastie URL.

The name "pbup" is from the convenient "pbcopy" and "pbpaste" methods in OS X. This one is to "upload" your clipboard content.

Ruby is required. The "pbup" command is OS X only.

Install and Usage:

    git clone https://github.com/broom9/pbup.git
    cd pbup/
    echo "Put some sample text in clipboard" | pbcopy
    pbup
    open `pbpaste` # Pastie.org URL should be ready in your clipboard
