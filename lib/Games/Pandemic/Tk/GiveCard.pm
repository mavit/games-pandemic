package Games::Pandemic::Tk::GiveCard;
# ABSTRACT: sharing dialog window for Games::Pandemic

use 5.010;
use strict;
use warnings;

use Moose;
use MooseX::SemiAffordanceAccessor;
use POE;
use Readonly;
use Tk;

use Games::Pandemic::Utils;
use Games::Pandemic::Tk::Utils;

Readonly my $K  => $poe_kernel;


# -- accessors

has cards => (
    is         => 'ro',
    isa        => 'ArrayRef',
    required   => 1,
    auto_deref => 1,
);

has parent => ( is=>'ro', required=>1, weak_ref=>1, isa=>'Tk::Widget' );

has _toplevel => ( is=>'rw', isa=>'Tk::Toplevel' );

has players => (
    is         => 'ro',
    isa        => 'ArrayRef',
    required   => 1,
    auto_deref => 1,
);

has _card   => ( is=>'rw', weak_ref=>1, isa=>'Games::Pandemic::Card::City' );
has _player => ( is=>'rw', weak_ref=>1, isa=>'Games::Pandemic::Player' );

# it's not usually a good idea to retain a reference on a poe session,
# since poe is already taking care of the references for us. however, we
# need the session to call ->postback() to set the various gui callbacks
# that will be fired upon gui events.
has _session => ( is=>'rw', isa=>'POE::Session', weak_ref=>1 );


# -- initialization

#
# BUILD()
#
# called as constructor initialization
#
sub BUILD {
    my $self = shift;
    $self->_build_gui;
}


# -- gui methods

#
# $dialog->_cancel;
#
# destroy the dialog without performing any action.
#
sub _cancel {
    my $self = shift;
    $self->_toplevel->destroy;
}


# -- private methods

#
# $main->_build_gui;
#
# create the various gui elements.
#
sub _build_gui {
    my $self = shift;
    my $parent = $self->parent;

    my $top = $parent->Toplevel;
    $self->_set_toplevel($top);
    $top->withdraw;

    # set windowtitle
    $top->title(T('Sharing...'));
    $top->iconimage( pandemic_icon($top) );


    my $fcenter = $top->Frame->pack(@TOP, @XFILL2);


    # if more than one player, select which one will receive the card
    my @players = $self->players;
    $self->_set_player( $players[0] );
    if ( @players > 1 ) {
        # enclose players in their own frame
        my $f = $fcenter->Frame->pack(@LEFT, @PAD10, -anchor=>'nw');
        $f->Label(
            -text   => T('Select player receiving the card:'),
            -anchor => 'w',
        )->pack(@TOP, @FILLX);

        # display cards
        my $selplayer = $self->_player->role;
        foreach my $player ( @players ) {
            # to display a radiobutton with image + text, we need to
            # create a radiobutton with a label just next to it.
            my $fplayer = $f->Frame->pack(@TOP, @FILLX);
            $fplayer->Radiobutton(
                -text     => $player->role,
                -variable => \$selplayer,
                -value    => $player->role,
                -anchor   => 'w',
                -command  => sub{ $self->_set_player($player); },
            )->pack(@LEFT, @XFILLX);
            my $lab = $fplayer->Label(
                -image    => image( $player->image('icon', 32), $top ),
            )->pack(@LEFT);
            $lab->bind( '<1>', sub { $self->_set_player($player); $selplayer=$player->role; } );
        }
    }

    # if more than one card, select which one to give
    my @cards = $self->cards;
    $self->_set_card( $cards[0] );
    if ( @cards > 1 ) {
        # enclosed cards in their own frame
        my $f = $fcenter->Frame->pack(@LEFT, @FILLX, @PAD10, -anchor=>'nw');
        $f->Label(
            -text   => T('Select city card to give:'),
            -anchor => 'w',
        )->pack(@TOP, @FILLX);

        # display cards
        my $selcard = $self->_card->label;
        foreach my $card ( @cards ) {
            # to display a radiobutton with image + text, we need to
            # create a radiobutton with a label just next to it.
            my $fcity = $f->Frame->pack(@TOP, @FILLX);
            $fcity->Radiobutton(
                -image    => image($card->icon, $top),
                -variable => \$selcard,
                -value    => $card->label,
                -command  => sub { $self->_set_card($card); },
            )->pack(@LEFT);
            my $lab = $fcity->Label(
                -text   => $card->label,
                -anchor => 'w',
            )->pack(@LEFT, @FILLX);
            $lab->bind( '<1>', sub { $self->_set_card($card); $selcard=$card->label; } );
        }
    }



    # the dialog buttons.
    # note that we specify a bogus width in order for both buttons to be
    # the same width. since we pack them with expand set to true, their
    # width will grow - but equally. otherwise, their size would be
    # proportional to their english text.
    my $fbuttons = $top->Frame->pack(@TOP, @FILLX);
    $fbuttons->Button(
        -text  => T('Give'),
        -width => 10,
    )->pack(@LEFT, @XFILL2);
    $fbuttons->Button(
        -text    => T('Cancel'),
        -width   => 10,
        -command => sub { $self->_cancel },
    )->pack(@LEFT, @XFILL2);

    # center window & make it appear
    $top->Popup( -popover => $parent);
    $top->grab; # make it modal
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=begin Pod::Coverage

BUILD

=end Pod::Coverage


