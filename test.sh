cd ~/bin

vi sample.sh
#!/bin/bash
#: Title	: Sample bash script
#: Date		: 2024-04-03
#: Author	: "hwicheon Kim" <ghwicheon@gmail.com>
#: Description	: Print Hello World
echo "Today : $(date +%Y-%m-%d)"
echo "Hello, Linux World!"

chmod +x sample.sh
sample.sh
