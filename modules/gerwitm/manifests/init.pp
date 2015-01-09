#
# Personal GNU/Linux configuration
#
class gerwitm {
    class { 'mikegerwitz':
        user    => 'gerwitm',
        group   => 'domain users',
        homedir => '/home/LOVULLO/gerwitm',
    }
}

