use 5.010;
use strict;
use warnings;

package Games::Pandemic::Disease;
# ABSTRACT: pandemic disease object

use File::Spec::Functions qw{ catfile };
use Moose;
use MooseX::AttributeHelpers;
use MooseX::SemiAffordanceAccessor;

use Games::Pandemic::Utils;


# -- attributes

has 'colors' => (
    metaclass  => 'Collection::List',
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    required   => 1,
    provides   => { get => 'color' },
);
has id    => ( is => 'ro', isa => 'Int', required   => 1 );
has name  => ( is => 'ro', isa => 'Str', required   => 1 );
has nbleft => (
    metaclass  => 'Number',
    is         => 'ro',
    isa        => 'Int',
    lazy       => 1,
    builder    => '_build_nb',
    provides   => {
        add => 'return',
        sub => 'take',
    },
);
has nbmax => ( is => 'ro', isa => 'Int', required   => 1 );
has _map  => ( is => 'ro', isa => 'Games::Pandemic::Map',required => 1, weak_ref => 1 );

has has_cure => (
    metaclass => 'Bool',
    is        => 'ro',
    isa       => 'Bool',
    default   => 0,
    provides  => {
        set     => 'find_cure',
    }
);

has is_eradicated => (
    metaclass => 'Bool',
    is        => 'ro',
    isa       => 'Bool',
    default   => 0,
    provides  => {
        set     => 'eradicate',
    }
);

# -- default builders / finishers

sub DEMOLISH {
    my $self = shift;
    debug( "~disease: " . $self->name . "\n" );
}

sub _build_nb { $_[0]->nbmax }


# -- public methods

=method my $path = $disease->image($what);

Return the C<$path> to an image for the disease. C<$what> can be either
C<cube> or C<cure>.

=cut

sub image {
    my ($self, $what, $size) = @_;
    return catfile( $self->_map->sharedir, $what . '-' . $self->id . "-$size.png" );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=begin Pod::Coverage

DEMOLISH

=end Pod::Coverage

