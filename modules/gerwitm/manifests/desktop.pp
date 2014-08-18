#
# Personal GNU/Linux desktop configuration
#
class gerwitm::desktop
{
    class { 'mikegerwitz::desktop':
        anon => false,
    }

    class { '::apt': }

    # up-to-date browsers
    apt::ppa { 'ppa:chromium-daily/stable': }
    apt::ppa { 'ppa:mozillateam/firefox-next': }

    package { [
            # communication
            'minbif',

            # web browsing
            'firefox',
            'chromium-browser',

            # misc.
            'xtightvncviewer',
        ]:
        ensure => latest,
    }

    File {
        owner => 'gerwitm',
        group => 'gerwitm',
    }

    $home    = "/home/gerwitm"
    $gitdir  = "${home}/gitrepos/people/gerwitm"
    $gitfile = "${gitdir}/files"

    # contains various scripts and configuration data for developers
    vcsrepo { $gitdir:
        ensure   => 'present',
        provider => 'git',
        source   => 'git@git.lovullo.com:config/people/gerwitm.git',
        user     => 'gerwitm',
    }


    # X configuration
    file { "${home}/.Xresources.d/60_xscreensaver-lv":
        ensure  => link,
        target  => "${gitfile}/Xresources.d/60_xscreensaver-lv",
        require => Vcsrepo[ $gitdir ],
    }


    # GNU screen config
    file { "${home}/.screenrc-local":
        ensure  => link,
        target  => "${gitfile}/screenrc-local",
        require => Vcsrepo[ $gitdir ],
    }
    file { "${home}/.screen/lv":
        ensure  => link,
        target  => "${gitfile}/screen/lv",
        require => Vcsrepo[ $gitdir ],
    }

    # GTK+
    file { "${home}/.gtkrc-2.0":
        ensure  => link,
        target  => "${gitfile}/gtkrc-2.0",
        require => Vcsrepo[ $gitdir ],
    }

    # XMonad
    file { "${home}/.xmonad":
        ensure => directory,
    }
    file { "${home}/.xmonad/xmonad.hs":
        ensure  => link,
        target  => "${gitfile}/xmonad/xmonad.hs",
        require => [ File["${home}/.xmonad"], Vcsrepo[ $gitdir ] ],
    }

    # cron jobs used by screen session
    cron { 'cron-nodelog-err-count':
        ensure  => present,
        command => "~/.screen/lv/bin/nodelog-err-count \
            >~/.screen/lv/.nodelog-err-count 2>/dev/null",
        user    => 'gerwitm',
        minute  => '*',
        hour    => '*',
        require => File["${home}/.screen/lv"],
    }
    cron { 'cron-jenkins-failures':
        ensure  => present,
        command => "~/.screen/lv/bin/get-jenkins-failures \
            > ~/.screen/lv/.jenkins-last.xml",
        user    => 'gerwitm',
        minute  => '*',
        hour    => '*',
        require => File["${home}/.screen/lv"],
    }
    cron { 'cron-weather':
        ensure  => present,
        command => 'weather -ikbuf >/tmp/.weather 2>/dev/null',
        user    => 'gerwitm',
        minute  => '*/5',
        hour    => '*',
    }

    # /usr/local/bin
    lbin { 'afd': }
    lbin { 'extmon': }
    lbin { 'jenkins-exec-status': }
    lbin { 'lpfmt': }
    lbin { 'rdc': }
    lbin { 'remind': }
    lbin { 'screenshot': }
    lbin { 'sshkey-add': }
    lbin { 'wins': }
}

