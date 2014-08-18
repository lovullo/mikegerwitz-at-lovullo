
node 'gerwitm-vm1.lovullo.local' {
    include gerwitm

    # we need to keep modest to ensure that the environment differs very little
    # from the other developers
    include mikegerwitz::dev::vim
}

node 'gerwitm-ubuntu2.lovullo.local' {
    include gerwitm
    include gerwitm::desktop

    class { 'mikegerwitz::dev':
        repos => false,
    }
    class { 'mikegerwitz::typesetting':
        repos => false,
    }
}
