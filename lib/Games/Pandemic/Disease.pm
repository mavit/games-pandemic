package Games::Pandemic::Disease;
# ABSTRACT: disease object for Games::Pandemic

use 5.010;
use strict;
use warnings;

use File::Spec::Functions qw{ catfile };
use Moose;
use MooseX::AttributeHelpers;
use MooseX::SemiAffordanceAccessor;

# -- attributes

has 'colors' => (
    metaclass  => 'Collection::List',
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    required   => 1,
    provides   => { get => 'color' },
);
has id      => ( is => 'ro', required => 1, isa => 'Int' );
has 'name'  => ( is => 'ro', required => 1 );
has nb    => ( is => 'rw', lazy_build => 1, isa => 'Int' );
has 'nbmax' => ( is => 'ro', required => 1, isa => 'Int' );
has '_map'  => ( is => 'ro', required => 1, isa => 'Games::Pandemic::Map', weak_ref => 1 );


# -- default builders

sub _build_nb { $_[0]->nbmax }


# -- public methods

=method my $path = $disease->image($what);

Return the C<$path> to an image for the disease. C<$what> can be either
C<cube> or C<cure>.

=cut

sub image {
    my ($self, $what) = @_;
    return catfile( $self->_map->sharedir, $what . '-' . $self->id . '.png' );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__