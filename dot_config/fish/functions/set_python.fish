function set_python
    if test (count $argv) -eq 0
        echo "Usage: set_python <version>"
        return 1
    end

    set version $argv[1]
    set python_path (command -v python$version)

    if test -z "$python_path"
        echo "Installing python$version..."
        sudo dnf install -y python$version
        set python_path (command -v python$version)
    end

    sudo alternatives --install /usr/bin/python3 python3 $python_path 1
    sudo alternatives --config python3
end
