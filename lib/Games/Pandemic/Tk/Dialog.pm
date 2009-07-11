package Games::Pandemic::Tk::Dialog;
# ABSTRACT: base class for Games::Pandemic dialog windows

use 5.010;
use strict;
use warnings;

use Moose;
use MooseX::SemiAffordanceAccessor;
use Tk;

use Games::Pandemic::Utils;
use Games::Pandemic::Tk::Utils;


# -- accessors

has parent => ( is=>'ro', required=>1, weak_ref=>1, isa=>'Tk::Widget' );
has title  => ( is=>'rw', isa=>'Str', lazy_build=>1 );
has header => ( is=>'rw', isa=>'Str', lazy_build=>1 );
has _toplevel => ( is=>'rw', isa=>'Tk::Toplevel' );


# -- initialization / finalization

#
# BUILD()
#
# called as constructor initialization
#
sub BUILD {
    my $self = shift;
    $self->_build_gui;
}


#
# DEMOLISH()
#
# called as destructor
#
sub DEMOLISH {
    my $self = shift;
    debug( "~dialog: $self\n" );
}

# lazy builders
sub _build_title  { T('Pandemic') }
sub _build_header { '' }


# -- gui methods

#
# $dialog->_close;
#
# request to destroy the dialog.
#
sub _close {
    my $self = shift;
    $self->_toplevel->destroy;
}


# -- private methods

#
# dialog->_build_gui;
#
# create the various gui elements.
#
sub _build_gui {
    my $self = shift;
    my $parent = $self->parent;

    my $top = $parent->Toplevel;
    $self->_set_toplevel($top);
    $top->withdraw;

    # window title
    $top->title( $self->title );
    $top->iconimage( pandemic_icon($top) );

    # dialog name
    if ( $self->header ) {
        my $font = $top->Font(-size=>16);
        $top->Label(
            -text => $self->header,
            -bg   => 'black',
            -fg   => 'white',
            -font => $font,
        )->pack(@TOP, @PAD10, @FILL2);
    }

    # build sub-class gui elems
    inner();

    # center window & make it appear
    $top->Popup( -popover => $parent );
    $top->resizable(0,0);
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=begin Pod::Coverage

BUILD

=end Pod::Coverage


=head1 DESCRIPTION

C<Games::Pandemic::Tk::Dialog> is meant to be used as a base class for
Pandemic dialogs, and should not be used directly.

It will create a new toplevel with the Pandemic icon, a title and
possibly a header.

It accepts the following attributes:

=over 4

=item * parent - the parent window of the dialog, required

=item * title - the dialog title, default to C<Pandemic>

=item * header - a header to display at the top of the window, no default

=back

To subclass it, declare your own attributes, create the lazy builders
for the attributes, and C<augment> the C<_build_gui()> method to create
the bottom of the dialog window.

