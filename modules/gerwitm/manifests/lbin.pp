#
# = Define: lovullo::people:gerwitm::lbin
#
# Simple /usr/local/bin copy
#
# == Parameters:
#
# None
#
# == Requires:
#
# Nothing
#
# == Sample Usage:
#
# lbin { 'foo': }
#

define gerwitm::lbin ( $id = $title ) {
    $gitdir = "/home/gerwitm/gitrepos/people/gerwitm"

    file { "/usr/local/bin/${name}":
        ensure  => link,
        target  => "${gitdir}/files/bin/${name}",
        require => Vcsrepo[ $gitdir ],
    }
}
