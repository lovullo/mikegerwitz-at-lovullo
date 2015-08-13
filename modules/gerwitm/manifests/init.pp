#
# Personal GNU/Linux configuration
#
class gerwitm ( $group   =-'domain users',
                $homedir = '/home/LOVULLO/gerwitm' ) {
    class { 'mikegerwitz':
        user    => 'gerwitm',
        group   => $group,
        homedir => $homedir,
        manage  => false
    }
}

