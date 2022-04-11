#!/usr/bin/perl

use IO::Dir;

my %dir;

tie %dir, 'IO::Dir', '/home/ozawacup/cgi-bin/sessions';

my @head = qw/INVOICE PAYMENT dinners passes kitsat adultsun kidsun adultsat participants/;
my @part = qw/name gender kata shobu wukf kobudo seminarA seminarB seminarC seminarD seminarE seminarF seminarG/;
use Data::Dumper;

foreach ( sort { $b cmp $a } keys %dir) {
  next if (/^\./);
  my $data = eval `cat /home/ozawacup/cgi-bin/sessions/$_ `;
next unless (defined $data);
next unless (defined $data->{paypal});
  push @list, my $row = [];
  push @{$row}, $data->{paypal}{invoice}."<br>".scalar(localtime $data->{paypal}{invoice}) || 0;
  push @{$row}, $data->{paypal}{mc_gross} || 0;
  push @{$row}, $data->{extras}{dinners} || 0;
  push @{$row}, $data->{extras}{passes} || 0;
  push @{$row}, $data->{extras}{kidsat} || 0;
  push @{$row}, $data->{extras}{adultsun} || 0;
  push @{$row}, $data->{extras}{kidsun} || 0;
  push @{$row}, $data->{extras}{adultsat} || 0;
  push @{$row}, [ map { [ $_->{name}, $_->{gender}, $_->{events}{kata}, $_->{events}{shobu}, $_->{events}{wukf}, $_->{events}{kobudo},
  $_->{seminarA}, $_->{seminarB}, $_->{events}{seminarC}, $_->{events}{seminarD}, $_->{events}{seminarE}, $_->{events}{seminarF}, $_->{events}{seminarG} ] } @{$data->{participants}} ];
  push @{$row}, map { { team => $_, members => $data->{teams}{$_}{members}, divisions => [ $data->{teams}{$_}{katadiv}, $data->{teams}{$_}{kumitediv} ] } } keys %{$data->{teams}};
}


print "Content-type: text/html\n\n";
print "<style>td, th { background-color: white }</style>\n";
print "<table style='border=1px solid black; background-color:black;' cellspacing=1px>";
print "<tr>";
foreach (@head) {
  print "<th>$_</th>\n";
}
print "</tr>";
foreach (@list) {
  print "<tr>\n";
foreach (@{$_}) {
  if ('ARRAY' eq ref $_ ) {
    print "<td>";
    print "<table style='border=1px solid black; background-color:black;' cellspacing=1px>";
    print "<tr>";
    foreach (@part) {
      print "<th>$_</th>\n";
    }
    print "</tr>";
    foreach (@{$_}) {
      print "<tr>";
      foreach (@{$_}) {
        print "<td>$_</td>\n";
      }
      print "</tr>";
    }
    print "</table>";
    print "</td>";
  } elsif ('HASH' eq ref $_ ) {
    print "<td>";
    print "<table style='border=1px solid black; background-color:black;' cellspacing=1px>";
    print "<tr>";
    print "<th>TEAM</th><th>$_->{team}</th>\n";
    print "</tr>";
    print "<tr>";
    print "<th>DIVISIONS</th>\n";
    print "<td>\n";
    print "<table style='border=1px solid black; background-color:black;' cellspacing=1px>";
    foreach (@{$_->{divisions}}) {
      print "<th>$_</th>\n";
    }
    print "</table>\n";
    print "</td>\n";
    print "</tr>";
    print "<tr><th>TEAM MEMBERS</th><td>";
    print "<table style='border=1px solid black; background-color:black;' cellspacing=1px>\n";
    foreach (@{$_->{members}}) {
        print "<tr><td>$_</td></tr>\n";
    }
    print "</table></td></tr>";
    print "</table>";
    print "</td>";
  } else {
    print "<td>$_</td>\n";
  }
}
  print "</tr>\n";
}
print "</table>";

