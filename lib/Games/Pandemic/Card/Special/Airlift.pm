use 5.010;
use strict;
use warnings;

package Games::Pandemic::Card::Special::Airlift;
# ABSTRACT: airlift event card for pandemic

use File::Spec::Functions qw{ catfile };
use Moose;
use MooseX::SemiAffordanceAccessor;

use Games::Pandemic::Utils;

extends 'Games::Pandemic::Card::Special';

# -- default builders

sub _build_icon  { catfile($SHAREDIR, 'cards', 'airlift-16.png' ) }
sub _build_label { T('Airlift') }
sub _build_description {
    T( 'This event allows to move a player to any city for free.' );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__


=head1 DESCRIPTION

This package implements the special event card C<airlift>. When
played, this event allows to move a player to any city for free.
